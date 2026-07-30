<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Services\Notifier;
use App\Services\PaymobService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    public function __construct(private readonly PaymobService $paymob)
    {
    }

    public function pay(Request $request, Order $order)
    {
        abort_if($order->user_id !== $request->user()->id, 403);

        if ($order->payment_method !== 'card') {
            return response()->json(['message' => 'This order is not paid by card.'], 422);
        }
        if ($order->payment_status === 'paid') {
            return response()->json(['message' => 'This order is already paid.'], 422);
        }

        try {
            $iframeUrl = $this->paymob->startPayment($order);
        } catch (\Throwable $e) {
            Log::warning('Paymob start payment failed: '.$e->getMessage());

            return response()->json(['message' => 'Could not start the payment. Try again.'], 502);
        }

        return response()->json(['iframe_url' => $iframeUrl]);
    }

    public function webhook(Request $request)
    {
        $obj = $request->input('obj', []);
        $received = $request->query('hmac') ?? $request->input('hmac');

        if (! is_array($obj) || ! PaymobService::verifyHmac($obj, $received)) {
            return response()->json(['message' => 'Invalid signature.'], 403);
        }

        $paymobOrderId = (string) data_get($obj, 'order.id');
        $order = Order::where('paymob_order_id', $paymobOrderId)->first();

        if (! $order) {
            return response()->json(['message' => 'Order not found.'], 200);
        }

        $success = data_get($obj, 'success') === true;

        if ($order->payment_status !== 'paid') {
            $order->update(['payment_status' => $success ? 'paid' : 'failed']);

            if ($success) {
                Notifier::order(
                    $order->user_id,
                    "Payment received for order #{$order->id}",
                    'Your card payment was successful. Your order is confirmed.',
                    $order->id,
                    'payment_paid',
                );
            }
        }

        return response()->json(['message' => 'ok'], 200);
    }
}
