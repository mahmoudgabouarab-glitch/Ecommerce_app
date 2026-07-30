<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\User;
use App\Models\WishlistItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SaleNotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_adding_a_sale_notifies_wishlist_users(): void
    {
        $customer = User::factory()->create();
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);
        WishlistItem::create(['user_id' => $customer->id, 'product_id' => $product->id]);

        Sanctum::actingAs(User::factory()->admin()->create());

        $this->putJson('/api/admin/products/'.$product->id, [
            'title' => $product->title,
            'price' => 100,
            'sale_price' => 70,
        ])->assertOk();

        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $customer->id,
            'type' => 'sale',
            'key' => 'sale_drop',
        ]);
    }

    public function test_update_without_a_price_drop_sends_no_notification(): void
    {
        $customer = User::factory()->create();
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);
        WishlistItem::create(['user_id' => $customer->id, 'product_id' => $product->id]);

        Sanctum::actingAs(User::factory()->admin()->create());

        $this->putJson('/api/admin/products/'.$product->id, [
            'title' => 'Renamed product',
            'price' => 100,
        ])->assertOk();

        $this->assertDatabaseMissing('app_notifications', [
            'user_id' => $customer->id,
            'type' => 'sale',
        ]);
    }

    public function test_non_wishlist_users_are_not_notified(): void
    {
        $bystander = User::factory()->create();
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);

        Sanctum::actingAs(User::factory()->admin()->create());

        $this->putJson('/api/admin/products/'.$product->id, [
            'title' => $product->title,
            'price' => 100,
            'sale_price' => 70,
        ])->assertOk();

        $this->assertDatabaseMissing('app_notifications', [
            'user_id' => $bystander->id,
            'type' => 'sale',
        ]);
    }
}
