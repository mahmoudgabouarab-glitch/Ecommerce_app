<?php

namespace App\Http\Controllers;

use App\Http\Resources\OrderResource;
use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    // Flat shipping fee (could be moved to config/DB later).
    private const SHIPPING_FEE = 50.0;

    // GET /api/orders  — the authenticated user's orders
    public function index(Request $request)
    {
        $orders = $request->user()->orders()
            ->with('items')
            ->latest()
            ->paginate(10);

        return OrderResource::collection($orders);
    }

    // GET /api/orders/{order}
    public function show(Request $request, Order $order)
    {
        abort_if($order->user_id !== $request->user()->id && ! $request->user()->isAdmin(), 403);

        return new OrderResource($order->load(['items', 'address']));
    }

    /**
     * POST /api/orders  — checkout the current cart.
     * Body: { address_id, payment_method: cash|card, coupon_code? }
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'address_id' => ['required', 'exists:addresses,id'],
            'payment_method' => ['required', 'in:cash,card'],
            'coupon_code' => ['nullable', 'string'],
        ]);

        // Address must belong to the user.
        abort_unless(
            $request->user()->addresses()->whereKey($data['address_id'])->exists(),
            403,
            'Invalid address.'
        );

        $items = $request->user()->cartItems()->with(['product', 'variant'])->get();
        if ($items->isEmpty()) {
            return response()->json(['message' => 'Your cart is empty.'], 422);
        }

        // Run the whole checkout atomically so partial orders never persist.
        $order = DB::transaction(function () use ($request, $items, $data) {
            $subtotal = 0.0;

            // Verify stock and lock product rows.
            foreach ($items as $item) {
                $product = $item->product()->lockForUpdate()->first();
                if (! $product || $product->stock < $item->quantity) {
                    abort(422, "Not enough stock for {$item->product->title}.");
                }
                $subtotal += $item->lineTotal();
            }
            $subtotal = round($subtotal, 2);

            // Apply coupon if provided and valid.
            $discount = 0.0;
            $couponCode = null;
            if (! empty($data['coupon_code'])) {
                $coupon = Coupon::where('code', $data['coupon_code'])->first();
                if ($coupon && $coupon->isValidFor($subtotal)) {
                    $discount = $coupon->discountFor($subtotal);
                    $couponCode = $coupon->code;
                }
            }

            $total = round($subtotal - $discount + self::SHIPPING_FEE, 2);

            $order = Order::create([
                'user_id' => $request->user()->id,
                'address_id' => $data['address_id'],
                'status' => 'pending',
                'payment_method' => $data['payment_method'],
                'subtotal' => $subtotal,
                'discount' => $discount,
                'shipping_fee' => self::SHIPPING_FEE,
                'total' => $total,
                'coupon_code' => $couponCode,
            ]);

            // Snapshot each line into order_items and decrement stock.
            foreach ($items as $item) {
                $order->items()->create([
                    'product_id' => $item->product_id,
                    'product_title' => $item->product->title,
                    'product_image' => $item->product->images[0] ?? null,
                    'unit_price' => $item->unitPrice(),
                    'quantity' => $item->quantity,
                ]);
                $item->product()->decrement('stock', $item->quantity);
            }

            // Empty the cart.
            $request->user()->cartItems()->delete();

            return $order;
        });

        return new OrderResource($order->load(['items', 'address']));
    }

    // PATCH /api/orders/{order}/cancel  — customer cancels their own pending order
    public function cancel(Request $request, Order $order)
    {
        abort_if($order->user_id !== $request->user()->id, 403);

        if ($order->status !== 'pending') {
            return response()->json(
                ['message' => 'Only pending orders can be cancelled.'],
                422
            );
        }

        DB::transaction(function () use ($order) {
            // Return stock for each line.
            foreach ($order->items as $item) {
                if ($item->product_id) {
                    $item->product()->increment('stock', $item->quantity);
                }
            }
            $order->update(['status' => 'cancelled']);
        });

        return new OrderResource($order->load(['items', 'address']));
    }

    // PATCH /api/admin/orders/{order}/status  { status }  (admin)
    public function updateStatus(Request $request, Order $order)
    {
        $data = $request->validate([
            'status' => ['required', 'in:pending,processing,shipped,delivered,cancelled'],
        ]);

        $order->update(['status' => $data['status']]);

        return new OrderResource($order->load('items'));
    }

    // GET /api/admin/orders  — all orders (admin)
    public function adminIndex(Request $request)
    {
        $query = Order::with(['items', 'user'])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        return OrderResource::collection($query->paginate(15));
    }
}
