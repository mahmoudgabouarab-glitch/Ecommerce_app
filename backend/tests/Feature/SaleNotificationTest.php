<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SaleNotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_adding_a_sale_notifies_all_customers(): void
    {
        $c1 = User::factory()->create(['role' => 'customer']);
        $c2 = User::factory()->create(['role' => 'customer']);
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);

        Sanctum::actingAs(User::factory()->admin()->create());

        $this->putJson('/api/admin/products/'.$product->id, [
            'title' => $product->title,
            'price' => 100,
            'sale_price' => 70,
        ])->assertOk();

        $this->assertDatabaseHas('app_notifications', ['user_id' => $c1->id, 'type' => 'sale']);
        $this->assertDatabaseHas('app_notifications', ['user_id' => $c2->id, 'type' => 'sale']);
    }

    public function test_admins_are_not_notified_of_sales(): void
    {
        $admin = User::factory()->admin()->create();
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);

        Sanctum::actingAs($admin);

        $this->putJson('/api/admin/products/'.$product->id, [
            'title' => $product->title,
            'price' => 100,
            'sale_price' => 70,
        ])->assertOk();

        $this->assertDatabaseMissing('app_notifications', ['user_id' => $admin->id, 'type' => 'sale']);
    }

    public function test_update_without_a_price_drop_sends_no_notification(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $product = Product::factory()->create(['price' => 100, 'sale_price' => null]);

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
}
