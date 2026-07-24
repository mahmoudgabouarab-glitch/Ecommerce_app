<?php

namespace App\Http\Controllers;

use App\Models\CartItem;
use App\Models\Coupon;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    // POST /api/coupons/apply  { code }
    // Validates a coupon against the user's current cart subtotal.
    public function apply(Request $request)
    {
        $request->validate(['code' => ['required', 'string']]);

        $coupon = Coupon::where('code', $request->code)->first();
        if (! $coupon) {
            return response()->json(['message' => 'Invalid coupon code.'], 404);
        }

        $items = $request->user()->cartItems()->with(['product', 'variant'])->get();
        $subtotal = round($items->sum(fn (CartItem $i) => $i->lineTotal()), 2);

        if (! $coupon->isValidFor($subtotal)) {
            return response()->json([
                'message' => "Coupon not applicable. Minimum order is {$coupon->min_total}.",
            ], 422);
        }

        $discount = $coupon->discountFor($subtotal);

        return response()->json([
            'code' => $coupon->code,
            'discount' => $discount,
            'subtotal' => $subtotal,
            'total' => round($subtotal - $discount, 2),
        ]);
    }

    // --- Admin CRUD ---

    // GET /api/admin/coupons
    public function index()
    {
        return response()->json(Coupon::latest()->get());
    }

    // POST /api/admin/coupons
    public function store(Request $request)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'unique:coupons,code'],
            'discount_type' => ['required', 'in:percent,fixed'],
            'amount' => ['required', 'numeric', 'min:0'],
            'min_total' => ['nullable', 'numeric', 'min:0'],
            'expires_at' => ['nullable', 'date'],
            'is_active' => ['boolean'],
        ]);

        return response()->json(Coupon::create($data), 201);
    }

    // DELETE /api/admin/coupons/{coupon}
    public function destroy(Coupon $coupon)
    {
        $coupon->delete();

        return response()->json(['message' => 'Coupon deleted.']);
    }
}
