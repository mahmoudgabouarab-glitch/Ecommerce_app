<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use App\Models\User;
use App\Services\Notifier;
use App\Support\ImageUploader;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query()->with('category');

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('brand', 'like', "%{$search}%");
            });
        }

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

        match ($request->query('sort')) {
            'price_asc' => $query->orderBy('price'),
            'price_desc' => $query->orderByDesc('price'),
            'rating' => $query->orderByDesc('rating'),
            'newest' => $query->orderByDesc('created_at'),
            default => $query->orderByDesc('created_at'),
        };

        $products = $query->paginate($request->integer('per_page', 12));

        return ProductResource::collection($products)->additional([
            'max_price' => (float) (Product::max('price') ?? 0),
        ]);
    }

    public function show(Product $product)
    {
        $product->load(['category', 'variants', 'reviews.user']);

        $counts = $product->reviews()
            ->selectRaw('rating, count(*) as total')
            ->groupBy('rating')
            ->pluck('total', 'rating');

        $breakdown = [];
        for ($star = 5; $star >= 1; $star--) {
            $breakdown[$star] = (int) ($counts[$star] ?? 0);
        }

        return (new ProductResource($product))
            ->additional(['ratings_breakdown' => $breakdown]);
    }

    public function deals()
    {
        $deals = Product::query()
            ->with('category')
            ->whereNotNull('sale_price')
            ->whereNotNull('deal_ends_at')
            ->where('deal_ends_at', '>', now())
            ->orderBy('deal_ends_at')
            ->limit(10)
            ->get();

        return ProductResource::collection($deals);
    }

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

    public function store(ProductRequest $request)
    {
        $this->assertVariantStockWithinTotal($request, null);
        $data = $this->buildData($request, null);
        $product = Product::create($data);
        $this->syncVariants($request, $product);

        return new ProductResource($product->load(['category', 'variants']));
    }

    public function update(ProductRequest $request, Product $product)
    {
        $this->assertVariantStockWithinTotal($request, $product);
        $oldSalePrice = $product->sale_price;
        $data = $this->buildData($request, $product);
        $product->update($data);
        $this->syncVariants($request, $product);
        $this->notifySaleIfDropped($product, $oldSalePrice);

        return new ProductResource($product->load(['category', 'variants']));
    }

    private function assertVariantStockWithinTotal(ProductRequest $request, ?Product $product): void
    {
        if (! $request->boolean('sync_variants')) {
            return;
        }

        $variants = $request->input('variants', []);
        if (empty($variants)) {
            return;
        }

        $variantTotal = array_sum(array_map(
            fn ($v) => (int) ($v['stock'] ?? 0),
            $variants,
        ));
        $productStock = $request->has('stock')
            ? (int) $request->input('stock')
            : (int) ($product->stock ?? 0);

        if ($variantTotal > $productStock) {
            throw ValidationException::withMessages([
                'variants' => ["Total option stock ({$variantTotal}) exceeds the product stock ({$productStock})."],
            ]);
        }
    }

    private function notifySaleIfDropped(Product $product, $oldSalePrice): void
    {
        $newSale = $product->sale_price;
        if ($newSale === null || (float) $newSale >= (float) $product->price) {
            return;
        }
        if ($oldSalePrice !== null && (float) $oldSalePrice <= (float) $newSale) {
            return;
        }

        $userIds = User::where('role', 'customer')->pluck('id');
        $price = (int) round((float) $newSale);
        foreach ($userIds as $userId) {
            Notifier::sale(
                $userId,
                'Price drop!',
                "{$product->title} is now on sale for {$price} EGP.",
                $product->id,
            );
        }
    }

    private function buildData(ProductRequest $request, ?Product $product): array
    {
        $data = $request->validated();

        $hasImageInput = $request->boolean('sync_images')
            || $request->hasFile('image')
            || $request->hasFile('photos');

        if ($hasImageInput) {
            $images = $request->boolean('sync_images')
                ? array_values($request->input('existing_images', []))
                : ($product?->images ?? []);

            if ($request->hasFile('image')) {
                $images[] = ImageUploader::upload($request->file('image'), 'products');
            }
            foreach ($request->file('photos', []) as $photo) {
                $images[] = ImageUploader::upload($photo, 'products');
            }

            $data['images'] = $images;
        }

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

    private function syncVariants(ProductRequest $request, Product $product): void
    {
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

        $product->variants()->whereNotIn('id', $keepIds)->delete();
    }

    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json(['message' => 'Product deleted.']);
    }
}
