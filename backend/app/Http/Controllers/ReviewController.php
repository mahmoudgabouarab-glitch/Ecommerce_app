<?php

namespace App\Http\Controllers;

use App\Http\Resources\ReviewResource;
use App\Models\Product;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    // GET /api/products/{product}/reviews
    public function index(Product $product)
    {
        $reviews = $product->reviews()->with('user')->latest()->paginate(10);

        return ReviewResource::collection($reviews);
    }

    // POST /api/products/{product}/reviews  (auth)
    public function store(Request $request, Product $product)
    {
        $data = $request->validate([
            'rating' => ['required', 'integer', 'between:1,5'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ]);

        // updateOrCreate enforces one review per user per product.
        $review = $product->reviews()->updateOrCreate(
            ['user_id' => $request->user()->id],
            ['rating' => $data['rating'], 'comment' => $data['comment'] ?? ''],
        );

        // Keep the product's cached rating in sync.
        $product->refreshRating();

        return new ReviewResource($review->load('user'));
    }

    // DELETE /api/reviews/{review} — owner or admin
    public function destroy(Request $request, \App\Models\Review $review)
    {
        if ($review->user_id !== $request->user()->id && ! $request->user()->isAdmin()) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $product = $review->product;
        $review->delete();
        $product->refreshRating();

        return response()->json(['message' => 'Review deleted.']);
    }
}
