<?php

namespace App\Http\Controllers;

use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    // GET /api/wishlist
    public function index(Request $request)
    {
        $products = Product::whereIn(
            'id',
            $request->user()->wishlistItems()->pluck('product_id')
        )->with('category')->get();

        return ProductResource::collection($products);
    }

    // POST /api/wishlist/{product}  — toggle
    public function toggle(Request $request, Product $product)
    {
        $existing = $request->user()->wishlistItems()
            ->where('product_id', $product->id)->first();

        if ($existing) {
            $existing->delete();

            return response()->json(['in_wishlist' => false]);
        }

        $request->user()->wishlistItems()->create(['product_id' => $product->id]);

        return response()->json(['in_wishlist' => true]);
    }
}
