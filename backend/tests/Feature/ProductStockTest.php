<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductStockTest extends TestCase
{
    use RefreshDatabase;

    public function test_option_stock_cannot_exceed_product_stock(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/admin/products', [
            'title' => 'Shirt',
            'price' => 100,
            'stock' => 50,
            'sync_variants' => true,
            'variants' => [
                ['size' => 'S', 'stock' => 30],
                ['size' => 'M', 'stock' => 20],
                ['size' => 'L', 'stock' => 10],
            ],
        ])->assertStatus(422)->assertJsonValidationErrors('variants');
    }

    public function test_option_stock_within_product_stock_is_accepted(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $this->postJson('/api/admin/products', [
            'title' => 'Shirt',
            'price' => 100,
            'stock' => 50,
            'sync_variants' => true,
            'variants' => [
                ['size' => 'S', 'stock' => 30],
                ['size' => 'M', 'stock' => 20],
            ],
        ])->assertCreated();
    }
}
