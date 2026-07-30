<?php

namespace App\Services;

use App\Models\Order;
use Illuminate\Support\Facades\Http;

class PaymobService
{
    public function startPayment(Order $order): string
    {
        $amountCents = (int) round((float) $order->total * 100);

        $authToken = $this->authenticate();
        $paymobOrderId = $this->registerOrder($authToken, $amountCents, $order);

        $order->update(['paymob_order_id' => (string) $paymobOrderId]);

        $paymentToken = $this->paymentKey(
            $authToken,
            $amountCents,
            $paymobOrderId,
            $this->billingData($order),
        );

        return $this->iframeUrl($paymentToken);
    }

    private function authenticate(): string
    {
        $response = Http::acceptJson()
            ->post($this->url('/api/auth/tokens'), [
                'api_key' => config('services.paymob.api_key'),
            ])
            ->throw();

        return $response->json('token');
    }

    private function registerOrder(string $authToken, int $amountCents, Order $order): int
    {
        $response = Http::acceptJson()
            ->post($this->url('/api/ecommerce/orders'), [
                'auth_token' => $authToken,
                'delivery_needed' => false,
                'amount_cents' => $amountCents,
                'currency' => 'EGP',
                'merchant_order_id' => $order->id.'-'.uniqid(),
                'items' => [],
            ])
            ->throw();

        return (int) $response->json('id');
    }

    private function paymentKey(string $authToken, int $amountCents, int $paymobOrderId, array $billing): string
    {
        $response = Http::acceptJson()
            ->post($this->url('/api/acceptance/payment_keys'), [
                'auth_token' => $authToken,
                'amount_cents' => $amountCents,
                'expiration' => 3600,
                'order_id' => $paymobOrderId,
                'billing_data' => $billing,
                'currency' => 'EGP',
                'integration_id' => config('services.paymob.card_integration_id'),
            ])
            ->throw();

        return $response->json('token');
    }

    private function iframeUrl(string $paymentToken): string
    {
        $iframeId = config('services.paymob.iframe_id');

        return $this->url("/api/acceptance/iframes/{$iframeId}?payment_token={$paymentToken}");
    }

    private function billingData(Order $order): array
    {
        $user = $order->user;
        $address = $order->address;
        $fullName = $address->full_name ?? $user->name ?? 'NA';
        $parts = explode(' ', trim($fullName), 2);

        return [
            'first_name' => $parts[0] ?: 'NA',
            'last_name' => $parts[1] ?? 'NA',
            'email' => $user->email ?? 'NA',
            'phone_number' => $address->phone ?? $user->phone ?? 'NA',
            'street' => $address->line1 ?? 'NA',
            'city' => $address->city ?? 'NA',
            'country' => $address->country ?? 'NA',
            'apartment' => 'NA',
            'floor' => 'NA',
            'building' => 'NA',
            'postal_code' => 'NA',
            'state' => 'NA',
            'shipping_method' => 'NA',
        ];
    }

    private function url(string $path): string
    {
        return rtrim((string) config('services.paymob.base_url'), '/').$path;
    }

    public static function verifyHmac(array $obj, ?string $received): bool
    {
        if (empty($received)) {
            return false;
        }

        return hash_equals(self::calculateHmac($obj), strtolower($received));
    }

    private static function calculateHmac(array $obj): string
    {
        $keys = [
            'amount_cents', 'created_at', 'currency', 'error_occured',
            'has_parent_transaction', 'id', 'integration_id', 'is_3d_secure',
            'is_auth', 'is_capture', 'is_refunded', 'is_standalone_payment',
            'is_voided', 'order.id', 'owner', 'pending', 'source_data.pan',
            'source_data.sub_type', 'source_data.type', 'success',
        ];

        $concatenated = '';
        foreach ($keys as $key) {
            $value = data_get($obj, $key);
            if (is_bool($value)) {
                $value = $value ? 'true' : 'false';
            }
            $concatenated .= $value;
        }

        return hash_hmac('sha512', $concatenated, (string) config('services.paymob.hmac_secret'));
    }
}
