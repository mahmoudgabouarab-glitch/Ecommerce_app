<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductVariantAndDealsTest extends TestCase
{
    use RefreshDatabase;

    public function test_deals_endpoint_returns_only_active_deals(): void
    {
        Product::factory()->create(['sale_price' => 80, 'price' => 100, 'deal_ends_at' => now()->addDay()]);
        Product::factory()->create(['sale_price' => 80, 'price' => 100, 'deal_ends_at' => now()->subDay()]);
        Product::factory()->create(['sale_price' => null, 'deal_ends_at' => null]);

        $this->getJson('/api/products/deals')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_effective_price_uses_sale_price_when_on_sale(): void
    {
        $product = Product::factory()->create([
            'price' => 100,
            'sale_price' => 70,
            'deal_ends_at' => now()->addDay(),
        ]);

        $this->getJson('/api/products/'.$product->id)
            ->assertOk()
            ->assertJsonPath('data.effective_price', 70)
            ->assertJsonPath('data.on_sale', true)
            ->assertJsonPath('data.on_deal', true);
    }

    public function test_effective_price_falls_back_to_base_price_when_not_on_sale(): void
    {
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);

        $this->getJson('/api/products/'.$product->id)
            ->assertOk()
            ->assertJsonPath('data.effective_price', 100)
            ->assertJsonPath('data.on_sale', false)
            ->assertJsonPath('data.on_deal', false);
    }

    public function test_sale_price_without_active_deal_window_is_not_on_deal(): void
    {
        $product = Product::factory()->create([
            'price' => 100,
            'sale_price' => 70,
            'deal_ends_at' => now()->subDay(),
        ]);

        $this->getJson('/api/products/'.$product->id)
            ->assertOk()
            ->assertJsonPath('data.on_sale', true)
            ->assertJsonPath('data.on_deal', false);
    }

    public function test_adding_a_variant_to_cart_respects_variant_stock(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 100]);
        $variant = ProductVariant::factory()->create(['product_id' => $product->id, 'stock' => 2]);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart', [
            'product_id' => $product->id,
            'variant_id' => $variant->id,
            'quantity' => 5,
        ])->assertStatus(422)->assertJsonPath('message', 'Not enough stock.');
    }

    public function test_adding_a_variant_from_another_product_is_rejected(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 100]);
        $foreignVariant = ProductVariant::factory()->create(['stock' => 50]);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart', [
            'product_id' => $product->id,
            'variant_id' => $foreignVariant->id,
            'quantity' => 1,
        ])->assertStatus(422)->assertJsonPath('message', 'Invalid option for this product.');
    }

    public function test_variant_price_diff_is_added_to_cart_unit_price(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null, 'stock' => 100]);
        $variant = ProductVariant::factory()->create([
            'product_id' => $product->id,
            'stock' => 10,
            'price_diff' => 15,
        ]);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart', [
            'product_id' => $product->id,
            'variant_id' => $variant->id,
            'quantity' => 1,
        ])->assertCreated()->assertJsonPath('data.unit_price', 115);
    }
}
