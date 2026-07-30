<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CheckoutTest extends TestCase
{
    use RefreshDatabase;

    private function seedCart(User $user, float $price = 200, int $qty = 1, int $stock = 10): Product
    {
        $product = Product::factory()->create(['price' => $price, 'sale_price' => null, 'stock' => $stock]);
        CartItem::create(['user_id' => $user->id, 'product_id' => $product->id, 'quantity' => $qty]);

        return $product;
    }

    public function test_guest_cannot_place_an_order(): void
    {
        $this->postJson('/api/orders', [])->assertUnauthorized();
    }

    public function test_cannot_checkout_with_an_empty_cart(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create(['user_id' => $user->id]);
        Sanctum::actingAs($user);

        $this->postJson('/api/orders', [
            'address_id' => $address->id,
            'payment_method' => 'cash',
        ])->assertStatus(422)->assertJsonPath('message', 'Your cart is empty.');
    }

    public function test_cannot_checkout_with_another_users_address(): void
    {
        $user = User::factory()->create();
        $this->seedCart($user);
        $foreignAddress = Address::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/orders', [
            'address_id' => $foreignAddress->id,
            'payment_method' => 'cash',
        ])->assertForbidden();
    }

    public function test_user_can_place_an_order_and_cart_is_cleared(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create(['user_id' => $user->id]);
        $product = $this->seedCart($user, price: 200, qty: 2, stock: 10);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/orders', [
            'address_id' => $address->id,
            'payment_method' => 'cash',
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.subtotal', 400)
            ->assertJsonPath('data.shipping_fee', 50)
            ->assertJsonPath('data.total', 450);

        $this->assertDatabaseHas('order_items', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);
        $this->assertSame(8, $product->fresh()->stock);
        $this->assertDatabaseCount('cart_items', 0);
        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $user->id,
            'key' => 'order_placed',
        ]);
    }

    public function test_order_applies_a_valid_coupon(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create(['user_id' => $user->id]);
        $this->seedCart($user, price: 200, qty: 1, stock: 10);
        Coupon::factory()->create(['code' => 'SAVE10', 'discount_type' => 'percent', 'amount' => 10]);
        Sanctum::actingAs($user);

        $this->postJson('/api/orders', [
            'address_id' => $address->id,
            'payment_method' => 'card',
            'coupon_code' => 'SAVE10',
        ])->assertCreated()
            ->assertJsonPath('data.discount', 20)
            ->assertJsonPath('data.subtotal', 200)
            ->assertJsonPath('data.total', 230);
    }

    public function test_insufficient_stock_rolls_back_the_whole_order(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create(['user_id' => $user->id]);
        $product = $this->seedCart($user, price: 100, qty: 5, stock: 3);
        Sanctum::actingAs($user);

        $this->postJson('/api/orders', [
            'address_id' => $address->id,
            'payment_method' => 'cash',
        ])->assertStatus(422);

        $this->assertDatabaseCount('orders', 0);
        $this->assertSame(3, $product->fresh()->stock);
        $this->assertDatabaseCount('cart_items', 1);
    }

    public function test_index_returns_only_the_users_own_orders(): void
    {
        $user = User::factory()->create();
        $other = User::factory()->create();
        Order::factory()->create(['user_id' => $user->id]);
        Order::factory()->create(['user_id' => $other->id]);
        Sanctum::actingAs($user);

        $this->getJson('/api/orders')->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_user_cannot_view_another_users_order(): void
    {
        $order = Order::factory()->create(['user_id' => User::factory()->create()->id]);
        Sanctum::actingAs(User::factory()->create());

        $this->getJson('/api/orders/'.$order->id)->assertForbidden();
    }

    public function test_user_can_cancel_a_pending_order_and_stock_is_restored(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 8]);
        $order = Order::factory()->create(['user_id' => $user->id, 'status' => 'pending']);
        $order->items()->create([
            'product_id' => $product->id,
            'product_title' => $product->title,
            'unit_price' => $product->price,
            'quantity' => 2,
        ]);
        Sanctum::actingAs($user);

        $this->patchJson('/api/orders/'.$order->id.'/cancel')
            ->assertOk()
            ->assertJsonPath('data.status', 'cancelled');

        $this->assertSame(10, $product->fresh()->stock);
    }

    public function test_cannot_cancel_a_non_pending_order(): void
    {
        $user = User::factory()->create();
        $order = Order::factory()->create(['user_id' => $user->id, 'status' => 'shipped']);
        Sanctum::actingAs($user);

        $this->patchJson('/api/orders/'.$order->id.'/cancel')->assertStatus(422);
    }

    public function test_user_cannot_cancel_another_users_order(): void
    {
        $order = Order::factory()->create(['user_id' => User::factory()->create()->id, 'status' => 'pending']);
        Sanctum::actingAs(User::factory()->create());

        $this->patchJson('/api/orders/'.$order->id.'/cancel')->assertForbidden();
    }

    public function test_admin_can_update_order_status(): void
    {
        $admin = User::factory()->admin()->create();
        $order = Order::factory()->create(['user_id' => User::factory()->create()->id, 'status' => 'pending']);
        Sanctum::actingAs($admin);

        $this->patchJson('/api/admin/orders/'.$order->id.'/status', ['status' => 'shipped'])
            ->assertOk()
            ->assertJsonPath('data.status', 'shipped');

        $this->assertDatabaseHas('app_notifications', [
            'order_id' => $order->id,
            'key' => 'order_shipped',
        ]);
    }

    public function test_customer_cannot_access_admin_status_endpoint(): void
    {
        $order = Order::factory()->create(['user_id' => User::factory()->create()->id]);
        Sanctum::actingAs(User::factory()->create());

        $this->patchJson('/api/admin/orders/'.$order->id.'/status', ['status' => 'shipped'])
            ->assertForbidden();
    }
}
