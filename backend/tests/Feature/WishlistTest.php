<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WishlistTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_toggle_wishlist(): void
    {
        $product = Product::factory()->create();

        $this->postJson('/api/wishlist/'.$product->id)->assertUnauthorized();
    }

    public function test_toggle_adds_product_to_wishlist(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/wishlist/'.$product->id)
            ->assertOk()
            ->assertJsonPath('in_wishlist', true);

        $this->assertDatabaseHas('wishlist_items', [
            'user_id' => $user->id,
            'product_id' => $product->id,
        ]);
    }

    public function test_toggle_twice_removes_product_from_wishlist(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/wishlist/'.$product->id);
        $this->postJson('/api/wishlist/'.$product->id)
            ->assertOk()
            ->assertJsonPath('in_wishlist', false);

        $this->assertDatabaseMissing('wishlist_items', [
            'user_id' => $user->id,
            'product_id' => $product->id,
        ]);
    }
}
