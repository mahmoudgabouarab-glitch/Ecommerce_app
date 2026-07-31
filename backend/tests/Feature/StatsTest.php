<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StatsTest extends TestCase
{
    use RefreshDatabase;

    public function test_revenue_counts_only_paid_non_cancelled_orders(): void
    {
        Order::factory()->create(['payment_status' => 'paid', 'status' => 'delivered', 'total' => 100]);
        Order::factory()->create(['payment_status' => 'unpaid', 'status' => 'pending', 'total' => 200]);
        Order::factory()->create(['payment_status' => 'failed', 'status' => 'pending', 'total' => 400]);
        Order::factory()->create(['payment_status' => 'paid', 'status' => 'cancelled', 'total' => 800]);

        Sanctum::actingAs(User::factory()->admin()->create());

        $this->getJson('/api/admin/stats')
            ->assertOk()
            ->assertJsonPath('revenue', 100);
    }

    public function test_top_products_ignores_cancelled_orders(): void
    {
        $live = Order::factory()->create(['status' => 'delivered']);
        $live->items()->create(['product_title' => 'Live Item', 'unit_price' => 10, 'quantity' => 3]);

        $cancelled = Order::factory()->create(['status' => 'cancelled']);
        $cancelled->items()->create(['product_title' => 'Cancelled Item', 'unit_price' => 10, 'quantity' => 9]);

        Sanctum::actingAs(User::factory()->admin()->create());

        $response = $this->getJson('/api/admin/stats')->assertOk();
        $titles = array_column($response->json('top_products'), 'product_title');

        $this->assertContains('Live Item', $titles);
        $this->assertNotContains('Cancelled Item', $titles);
    }
}
