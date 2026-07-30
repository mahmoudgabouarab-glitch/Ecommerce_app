<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PaymentTest extends TestCase
{
    use RefreshDatabase;

    private function fakePaymob(): void
    {
        Http::fake([
            '*/api/auth/tokens' => Http::response(['token' => 'auth-123']),
            '*/api/ecommerce/orders' => Http::response(['id' => 999]),
            '*/api/acceptance/payment_keys' => Http::response(['token' => 'paykey-456']),
        ]);
    }

    private function signedObj(array $overrides = []): array
    {
        return array_merge([
            'amount_cents' => 25000,
            'created_at' => '2026-07-30T00:00:00',
            'currency' => 'EGP',
            'error_occured' => false,
            'has_parent_transaction' => false,
            'id' => 111,
            'integration_id' => 222,
            'is_3d_secure' => true,
            'is_auth' => false,
            'is_capture' => false,
            'is_refunded' => false,
            'is_standalone_payment' => true,
            'is_voided' => false,
            'order' => ['id' => 999],
            'owner' => 333,
            'pending' => false,
            'source_data' => ['pan' => '2345', 'sub_type' => 'MasterCard', 'type' => 'card'],
            'success' => true,
        ], $overrides);
    }

    private function hmacFor(array $obj, string $secret): string
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

        return hash_hmac('sha512', $concatenated, $secret);
    }

    public function test_guest_cannot_start_a_payment(): void
    {
        $order = Order::factory()->create(['payment_method' => 'card']);

        $this->postJson('/api/orders/'.$order->id.'/pay')->assertUnauthorized();
    }

    public function test_cannot_pay_another_users_order(): void
    {
        $order = Order::factory()->create([
            'user_id' => User::factory()->create()->id,
            'payment_method' => 'card',
        ]);
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/orders/'.$order->id.'/pay')->assertForbidden();
    }

    public function test_cannot_start_payment_for_a_cash_order(): void
    {
        $user = User::factory()->create();
        $order = Order::factory()->create(['user_id' => $user->id, 'payment_method' => 'cash']);
        Sanctum::actingAs($user);

        $this->postJson('/api/orders/'.$order->id.'/pay')->assertStatus(422);
    }

    public function test_cannot_pay_an_already_paid_order(): void
    {
        $user = User::factory()->create();
        $order = Order::factory()->create([
            'user_id' => $user->id,
            'payment_method' => 'card',
            'payment_status' => 'paid',
        ]);
        Sanctum::actingAs($user);

        $this->postJson('/api/orders/'.$order->id.'/pay')->assertStatus(422);
    }

    public function test_card_order_returns_an_iframe_url_and_stores_paymob_order_id(): void
    {
        $this->fakePaymob();
        $user = User::factory()->create();
        $order = Order::factory()->create([
            'user_id' => $user->id,
            'payment_method' => 'card',
            'total' => 250,
        ]);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/orders/'.$order->id.'/pay');

        $response->assertOk();
        $this->assertStringContainsString('payment_token=paykey-456', $response->json('iframe_url'));
        $this->assertSame('999', $order->fresh()->paymob_order_id);
        Http::assertSentCount(3);
    }

    public function test_webhook_rejects_an_invalid_signature(): void
    {
        config(['services.paymob.hmac_secret' => 'secret']);
        $order = Order::factory()->create(['paymob_order_id' => '999', 'payment_method' => 'card']);

        $this->postJson('/api/paymob/webhook?hmac=deadbeef', ['obj' => $this->signedObj()])
            ->assertStatus(403);

        $this->assertNotSame('paid', $order->fresh()->payment_status);
    }

    public function test_webhook_marks_the_order_paid_on_success(): void
    {
        config(['services.paymob.hmac_secret' => 'secret']);
        $order = Order::factory()->create(['paymob_order_id' => '999', 'payment_method' => 'card']);
        $obj = $this->signedObj(['success' => true]);
        $hmac = $this->hmacFor($obj, 'secret');

        $this->postJson('/api/paymob/webhook?hmac='.$hmac, ['obj' => $obj])->assertOk();

        $this->assertSame('paid', $order->fresh()->payment_status);
        $this->assertDatabaseHas('app_notifications', [
            'order_id' => $order->id,
            'key' => 'payment_paid',
        ]);
    }

    public function test_webhook_marks_the_order_failed_on_decline(): void
    {
        config(['services.paymob.hmac_secret' => 'secret']);
        $order = Order::factory()->create(['paymob_order_id' => '999', 'payment_method' => 'card']);
        $obj = $this->signedObj(['success' => false]);
        $hmac = $this->hmacFor($obj, 'secret');

        $this->postJson('/api/paymob/webhook?hmac='.$hmac, ['obj' => $obj])->assertOk();

        $this->assertSame('failed', $order->fresh()->payment_status);
    }

    public function test_webhook_ignores_an_unknown_order(): void
    {
        config(['services.paymob.hmac_secret' => 'secret']);
        $obj = $this->signedObj(['order' => ['id' => 55555]]);
        $hmac = $this->hmacFor($obj, 'secret');

        $this->postJson('/api/paymob/webhook?hmac='.$hmac, ['obj' => $obj])->assertOk();
    }
}
