<?php

namespace App\Http\Controllers;

use App\Http\Resources\CartItemResource;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $items = $this->cartQuery($request)->get();

        return response()->json([
            'items' => CartItemResource::collection($items),
            'subtotal' => $this->subtotal($items),
            'count' => $items->sum('quantity'),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => ['required', 'exists:products,id'],
            'variant_id' => ['nullable', 'exists:product_variants,id'],
            'quantity' => ['required', 'integer', 'min:1'],
        ]);

        $product = Product::findOrFail($data['product_id']);

        $variant = null;
        if (! empty($data['variant_id'])) {
            $variant = ProductVariant::find($data['variant_id']);
            if (! $variant || $variant->product_id !== $product->id) {
                return response()->json(['message' => 'Invalid option for this product.'], 422);
            }
        }

        $item = CartItem::firstOrNew([
            'user_id' => $request->user()->id,
            'product_id' => $data['product_id'],
            'variant_id' => $data['variant_id'] ?? null,
        ]);
        $newQuantity = ($item->exists ? $item->quantity : 0) + $data['quantity'];

        $available = $variant ? $variant->stock : $product->stock;
        if ($available < $newQuantity) {
            return response()->json(['message' => 'Not enough stock.'], 422);
        }

        $item->quantity = $newQuantity;
        $item->save();

        return new CartItemResource($item->load(['product', 'variant']));
    }

    public function update(Request $request, CartItem $cartItem)
    {
        $this->authorizeOwner($request, $cartItem);

        $data = $request->validate([
            'quantity' => ['required', 'integer', 'min:1'],
        ]);

        $cartItem->loadMissing(['product', 'variant']);
        $available = $cartItem->variant
            ? $cartItem->variant->stock
            : ($cartItem->product->stock ?? 0);
        if ($available < $data['quantity']) {
            return response()->json(['message' => 'Not enough stock.'], 422);
        }

        $cartItem->update(['quantity' => $data['quantity']]);

        return new CartItemResource($cartItem->load(['product', 'variant']));
    }

    public function destroy(Request $request, CartItem $cartItem)
    {
        $this->authorizeOwner($request, $cartItem);
        $cartItem->delete();

        return response()->json(['message' => 'Item removed.']);
    }

    public function clear(Request $request)
    {
        $request->user()->cartItems()->delete();

        return response()->json(['message' => 'Cart cleared.']);
    }

    private function cartQuery(Request $request)
    {
        return $request->user()->cartItems()->with(['product.category', 'variant']);
    }

    private function subtotal($items): float
    {
        return round($items->sum(fn (CartItem $i) => $i->lineTotal()), 2);
    }

    private function authorizeOwner(Request $request, CartItem $item): void
    {
        abort_if($item->user_id !== $request->user()->id, 403, 'Forbidden.');
    }
}
