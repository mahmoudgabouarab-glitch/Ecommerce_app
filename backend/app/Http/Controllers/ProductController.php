<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * GET /api/products
     * Supports: ?search= &category_id= &brand= &min_price= &max_price=
     *           &min_rating= &featured=1 &sort=price_asc|price_desc|rating|newest
     *           &per_page=
     */
    public function index(Request $request)
    {
        $query = Product::query()->with('category');

        // --- Search ---
        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('brand', 'like', "%{$search}%");
            });
        }

        // --- Filters ---
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->query('category_id'));
        }
        if ($request->filled('brand')) {
            $query->where('brand', $request->query('brand'));
        }
        if ($request->filled('min_price')) {
            $query->where('price', '>=', $request->query('min_price'));
        }
        if ($request->filled('max_price')) {
            $query->where('price', '<=', $request->query('max_price'));
        }
        if ($request->filled('min_rating')) {
            $query->where('rating', '>=', $request->query('min_rating'));
        }
        if ($request->boolean('featured')) {
            $query->where('is_featured', true);
        }

        // --- Sorting ---
        match ($request->query('sort')) {
            'price_asc' => $query->orderBy('price'),
            'price_desc' => $query->orderByDesc('price'),
            'rating' => $query->orderByDesc('rating'),
            'newest' => $query->orderByDesc('created_at'),
            default => $query->orderByDesc('created_at'),
        };

        $products = $query->paginate($request->integer('per_page', 12));

        // Expose the most expensive product so the client can size its price
        // filter to the real catalogue range instead of a hard-coded max.
        return ProductResource::collection($products)->additional([
            'max_price' => (float) (Product::max('price') ?? 0),
        ]);
    }

    // GET /api/products/{product}
    public function show(Product $product)
    {
        $product->load(['category', 'variants', 'reviews.user']);

        return new ProductResource($product);
    }

    /**
     * GET /api/products/{product}/related — "You may also like".
     * Prefers same-category products; falls back to newest if the category
     * has nothing else to show.
     */
    public function related(Product $product)
    {
        $query = Product::query()
            ->with('category')
            ->where('id', '!=', $product->id);

        if ($product->category_id) {
            $query->where('category_id', $product->category_id);
        }

        $related = $query->orderByDesc('rating')->limit(10)->get();

        if ($related->isEmpty()) {
            $related = Product::query()
                ->with('category')
                ->where('id', '!=', $product->id)
                ->orderByDesc('created_at')
                ->limit(10)
                ->get();
        }

        return ProductResource::collection($related);
    }

    // POST /api/admin/products
    public function store(ProductRequest $request)
    {
        $data = $this->buildData($request, null);
        $product = Product::create($data);
        $this->syncVariants($request, $product);

        return new ProductResource($product->load(['category', 'variants']));
    }

    // PUT /api/admin/products/{product}  (or POST with _method=PUT for file upload)
    public function update(ProductRequest $request, Product $product)
    {
        $data = $this->buildData($request, $product);
        $product->update($data);
        $this->syncVariants($request, $product);

        return new ProductResource($product->load(['category', 'variants']));
    }

    /**
     * Build the validated payload and resolve the final `images` list from:
     * kept existing URLs (`existing_images`) + newly uploaded files
     * (`photos[]`, and the legacy single `image`).
     */
    private function buildData(ProductRequest $request, ?Product $product): array
    {
        $data = $request->validated();

        // `sync_images` = the client is sending the full desired image set
        // (kept URLs + new uploads), so an empty result means "remove all".
        $hasImageInput = $request->boolean('sync_images')
            || $request->hasFile('image')
            || $request->hasFile('photos');

        if ($hasImageInput) {
            // Start from the URLs the admin kept (empty array = removed all).
            $images = $request->boolean('sync_images')
                ? array_values($request->input('existing_images', []))
                : ($product?->images ?? []);

            if ($request->hasFile('image')) {
                $images[] = url('storage/'.$request->file('image')->store('products', 'public'));
            }
            foreach ($request->file('photos', []) as $photo) {
                $images[] = url('storage/'.$photo->store('products', 'public'));
            }

            $data['images'] = $images;
        }

        // These are handled separately (or not persisted directly on the product).
        unset(
            $data['image'],
            $data['photos'],
            $data['existing_images'],
            $data['variants'],
            $data['sync_images'],
            $data['sync_variants'],
        );

        return $data;
    }

    /**
     * Create/update/delete a product's variants to match the submitted list.
     * No-op when the request doesn't include a `variants` key at all, so
     * partial updates that don't touch variants leave them intact.
     */
    private function syncVariants(ProductRequest $request, Product $product): void
    {
        // Only touch variants when the client opts in, so partial updates that
        // don't include a `variants` payload leave existing ones intact.
        if (! $request->boolean('sync_variants')) {
            return;
        }

        $keepIds = [];
        foreach ($request->input('variants', []) as $variant) {
            $attributes = [
                'size' => $variant['size'] ?? null,
                'color' => $variant['color'] ?? null,
                'stock' => (int) ($variant['stock'] ?? 0),
                'price_diff' => (float) ($variant['price_diff'] ?? 0),
            ];

            if (! empty($variant['id'])) {
                $product->variants()->whereKey($variant['id'])->update($attributes);
                $keepIds[] = (int) $variant['id'];
            } else {
                $keepIds[] = $product->variants()->create($attributes)->id;
            }
        }

        // Remove variants that were deleted in the form.
        $product->variants()->whereNotIn('id', $keepIds)->delete();
    }

    // DELETE /api/admin/products/{product}
    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json(['message' => 'Product deleted.']);
    }
}
