<?php

namespace Tests\Feature;

use App\Models\CartItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CartTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_access_cart(): void
    {
        $this->getJson('/api/cart')->assertUnauthorized();
    }

    public function test_user_can_add_a_product_to_the_cart(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 10]);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/cart', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('cart_items', [
            'user_id' => $user->id,
            'product_id' => $product->id,
            'quantity' => 2,
        ]);
    }

    public function test_adding_same_product_again_increments_quantity(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 10]);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 2]);
        $this->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 3]);

        $this->assertDatabaseHas('cart_items', [
            'user_id' => $user->id,
            'product_id' => $product->id,
            'quantity' => 5,
        ]);
    }

    public function test_cannot_add_more_than_available_stock(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 3]);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart', ['product_id' => $product->id, 'quantity' => 5])
            ->assertStatus(422)
            ->assertJsonPath('message', 'Not enough stock.');
    }

    public function test_user_can_update_cart_item_quantity(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['stock' => 10]);
        $item = CartItem::create(['user_id' => $user->id, 'product_id' => $product->id, 'quantity' => 1]);
        Sanctum::actingAs($user);

        $this->putJson('/api/cart/'.$item->id, ['quantity' => 4])->assertOk();
        $this->assertDatabaseHas('cart_items', ['id' => $item->id, 'quantity' => 4]);
    }

    public function test_user_can_remove_a_cart_item(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();
        $item = CartItem::create(['user_id' => $user->id, 'product_id' => $product->id, 'quantity' => 1]);
        Sanctum::actingAs($user);

        $this->deleteJson('/api/cart/'.$item->id)->assertOk();
        $this->assertDatabaseMissing('cart_items', ['id' => $item->id]);
    }

    public function test_user_can_clear_the_cart(): void
    {
        $user = User::factory()->create();
        $products = Product::factory()->count(2)->create();
        foreach ($products as $product) {
            CartItem::create(['user_id' => $user->id, 'product_id' => $product->id, 'quantity' => 1]);
        }
        Sanctum::actingAs($user);

        $this->deleteJson('/api/cart')->assertOk();
        $this->assertDatabaseCount('cart_items', 0);
    }

    public function test_user_cannot_modify_another_users_cart_item(): void
    {
        $owner = User::factory()->create();
        $product = Product::factory()->create(['stock' => 10]);
        $item = CartItem::create(['user_id' => $owner->id, 'product_id' => $product->id, 'quantity' => 1]);

        Sanctum::actingAs(User::factory()->create());

        $this->putJson('/api/cart/'.$item->id, ['quantity' => 9])->assertForbidden();
        $this->assertDatabaseHas('cart_items', ['id' => $item->id, 'quantity' => 1]);
    }
}
