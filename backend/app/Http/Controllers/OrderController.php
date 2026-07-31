<?php

namespace App\Http\Controllers;

use App\Http\Resources\OrderResource;
use App\Models\Coupon;
use App\Models\Order;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\Notifier;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    private const SHIPPING_FEE = 50.0;

    public function index(Request $request)
    {
        $orders = $request->user()->orders()
            ->with('items')
            ->latest()
            ->paginate(10);

        return OrderResource::collection($orders);
    }

    public function show(Request $request, Order $order)
    {
        abort_if($order->user_id !== $request->user()->id && ! $request->user()->isAdmin(), 403);

        return new OrderResource($order->load(['items', 'address']));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'address_id' => ['required', 'exists:addresses,id'],
            'payment_method' => ['required', 'in:cash,card'],
            'coupon_code' => ['nullable', 'string'],
        ]);

        abort_unless(
            $request->user()->addresses()->whereKey($data['address_id'])->exists(),
            403,
            'Invalid address.'
        );

        $items = $request->user()->cartItems()->with(['product', 'variant'])->get();
        if ($items->isEmpty()) {
            return response()->json(['message' => 'Your cart is empty.'], 422);
        }

        $order = DB::transaction(function () use ($request, $items, $data) {
            $subtotal = 0.0;

            $productQty = [];
            $variantQty = [];
            foreach ($items as $item) {
                $productQty[$item->product_id] =
                    ($productQty[$item->product_id] ?? 0) + $item->quantity;
                if ($item->variant_id) {
                    $variantQty[$item->variant_id] =
                        ($variantQty[$item->variant_id] ?? 0) + $item->quantity;
                }
                $subtotal += $item->lineTotal();
            }
            $subtotal = round($subtotal, 2);

            foreach ($productQty as $productId => $qty) {
                $product = Product::whereKey($productId)->lockForUpdate()->first();
                if (! $product || $product->stock < $qty) {
                    abort(422, "Not enough stock for {$product?->title}.");
                }
            }
            foreach ($variantQty as $variantId => $qty) {
                $variant = ProductVariant::whereKey($variantId)->lockForUpdate()->first();
                if (! $variant || $variant->stock < $qty) {
                    abort(422, 'Not enough stock for the selected option.');
                }
            }

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
                'payment_status' => 'unpaid',
                'subtotal' => $subtotal,
                'discount' => $discount,
                'shipping_fee' => self::SHIPPING_FEE,
                'total' => $total,
                'coupon_code' => $couponCode,
            ]);

            foreach ($items as $item) {
                $order->items()->create([
                    'product_id' => $item->product_id,
                    'variant_id' => $item->variant_id,
                    'product_title' => $item->product->title,
                    'product_image' => $item->product->images[0] ?? null,
                    'unit_price' => $item->unitPrice(),
                    'quantity' => $item->quantity,
                ]);
            }

            foreach ($productQty as $productId => $qty) {
                Product::whereKey($productId)->decrement('stock', $qty);
            }
            foreach ($variantQty as $variantId => $qty) {
                ProductVariant::whereKey($variantId)->decrement('stock', $qty);
            }

            $request->user()->cartItems()->delete();

            return $order;
        });

        Notifier::order(
            $order->user_id,
            "Order #{$order->id} placed",
            'Your order has been placed and is pending confirmation.',
            $order->id,
            'order_placed',
        );

        return new OrderResource($order->load(['items', 'address']));
    }

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
            $this->adjustStock($order->load('items'), +1);
            $updates = ['status' => 'cancelled'];
            if ($order->payment_status === 'paid') {
                $updates['payment_status'] = 'refunded';
            }
            $order->update($updates);
        });

        return new OrderResource($order->load(['items', 'address']));
    }

    public function updateStatus(Request $request, Order $order)
    {
        $data = $request->validate([
            'status' => ['required', 'in:pending,processing,shipped,delivered,cancelled'],
        ]);

        $from = $order->status;
        $to = $data['status'];

        DB::transaction(function () use ($order, $from, $to) {
            if ($to === 'cancelled' && $from !== 'cancelled') {
                $this->adjustStock($order->load('items'), +1);
            } elseif ($from === 'cancelled' && $to !== 'cancelled') {
                $this->adjustStock($order->load('items'), -1);
            }

            $updates = ['status' => $to];
            if ($to === 'delivered'
                && $order->payment_method === 'cash'
                && $order->payment_status !== 'paid') {
                $updates['payment_status'] = 'paid';
            }
            if ($to === 'cancelled' && $order->payment_status === 'paid') {
                $updates['payment_status'] = 'refunded';
            }
            $order->update($updates);
        });

        if ($from !== $to) {
            Notifier::order(
                $order->user_id,
                "Order #{$order->id} {$to}",
                $this->statusMessage($to, $order->id),
                $order->id,
                'order_'.$to,
            );
        }

        return new OrderResource($order->load('items'));
    }

    private function statusMessage(string $status, int $orderId): string
    {
        return match ($status) {
            'processing' => "Your order #{$orderId} is being prepared.",
            'shipped' => "Good news! Order #{$orderId} is on its way.",
            'delivered' => "Order #{$orderId} has been delivered. Enjoy!",
            'cancelled' => "Order #{$orderId} has been cancelled.",
            default => "Order #{$orderId} is now pending.",
        };
    }

    private function adjustStock(Order $order, int $sign): void
    {
        foreach ($order->items as $item) {
            if ($item->product_id) {
                Product::whereKey($item->product_id)->increment('stock', $sign * $item->quantity);
            }
            if ($item->variant_id) {
                ProductVariant::whereKey($item->variant_id)->increment('stock', $sign * $item->quantity);
            }
        }
    }

    public function adminIndex(Request $request)
    {
        $query = Order::with(['items', 'user'])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        return OrderResource::collection($query->paginate(15));
    }
}
