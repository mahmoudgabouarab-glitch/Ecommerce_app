<?php

namespace Tests\Feature;

use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CouponTest extends TestCase
{
    use RefreshDatabase;

    private function userWithCart(float $unitPrice, int $qty = 1): User
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['price' => $unitPrice, 'sale_price' => null, 'stock' => 100]);
        CartItem::create(['user_id' => $user->id, 'product_id' => $product->id, 'quantity' => $qty]);

        return $user;
    }

    public function test_percentage_coupon_applies_discount(): void
    {
        $user = $this->userWithCart(200);
        Coupon::factory()->create(['code' => 'SAVE10', 'discount_type' => 'percent', 'amount' => 10]);
        Sanctum::actingAs($user);

        $this->postJson('/api/coupons/apply', ['code' => 'SAVE10'])
            ->assertOk()
            ->assertJsonPath('discount', 20)
            ->assertJsonPath('subtotal', 200)
            ->assertJsonPath('total', 180);
    }

    public function test_fixed_coupon_applies_discount(): void
    {
        $user = $this->userWithCart(200);
        Coupon::factory()->fixed(50)->create(['code' => 'MINUS50']);
        Sanctum::actingAs($user);

        $this->postJson('/api/coupons/apply', ['code' => 'MINUS50'])
            ->assertOk()
            ->assertJsonPath('discount', 50)
            ->assertJsonPath('total', 150);
    }

    public function test_unknown_coupon_returns_404(): void
    {
        Sanctum::actingAs($this->userWithCart(200));

        $this->postJson('/api/coupons/apply', ['code' => 'NOPE'])->assertNotFound();
    }

    public function test_coupon_below_minimum_total_is_rejected(): void
    {
        $user = $this->userWithCart(50);
        Coupon::factory()->create(['code' => 'BIG', 'min_total' => 100]);
        Sanctum::actingAs($user);

        $this->postJson('/api/coupons/apply', ['code' => 'BIG'])->assertStatus(422);
    }

    public function test_expired_coupon_is_rejected(): void
    {
        $user = $this->userWithCart(200);
        Coupon::factory()->expired()->create(['code' => 'OLD']);
        Sanctum::actingAs($user);

        $this->postJson('/api/coupons/apply', ['code' => 'OLD'])->assertStatus(422);
    }

    public function test_inactive_coupon_is_rejected(): void
    {
        $user = $this->userWithCart(200);
        Coupon::factory()->create(['code' => 'OFF', 'is_active' => false]);
        Sanctum::actingAs($user);

        $this->postJson('/api/coupons/apply', ['code' => 'OFF'])->assertStatus(422);
    }
}
