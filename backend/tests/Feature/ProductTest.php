<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_returns_paginated_products(): void
    {
        Product::factory()->count(3)->create();

        $response = $this->getJson('/api/products');

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure(['data' => [['id', 'title', 'price', 'images']], 'meta', 'max_price']);
    }

    public function test_index_filters_by_search_term(): void
    {
        Product::factory()->create(['title' => 'Wireless Headphones']);
        Product::factory()->create(['title' => 'Cotton T-Shirt']);

        $response = $this->getJson('/api/products?search=headphones');

        $response->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Wireless Headphones');
    }

    public function test_index_filters_by_category(): void
    {
        $target = Category::factory()->create();
        Product::factory()->create(['category_id' => $target->id]);
        Product::factory()->create();

        $response = $this->getJson('/api/products?category_id='.$target->id);

        $response->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_index_filters_by_price_range(): void
    {
        Product::factory()->create(['price' => 50]);
        Product::factory()->create(['price' => 500]);

        $response = $this->getJson('/api/products?min_price=100&max_price=1000');

        $response->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.price', 500);
    }

    public function test_index_filters_featured_only(): void
    {
        Product::factory()->featured()->create();
        Product::factory()->create();

        $response = $this->getJson('/api/products?featured=1');

        $response->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_index_sorts_by_price_ascending(): void
    {
        Product::factory()->create(['price' => 300]);
        Product::factory()->create(['price' => 100]);
        Product::factory()->create(['price' => 200]);

        $response = $this->getJson('/api/products?sort=price_asc');

        $prices = array_column($response->json('data'), 'price');
        $this->assertSame([100, 200, 300], $prices);
    }

    public function test_show_returns_a_single_product(): void
    {
        $product = Product::factory()->create();

        $this->getJson('/api/products/'.$product->id)
            ->assertOk()
            ->assertJsonPath('data.id', $product->id);
    }

    public function test_show_returns_404_for_missing_product(): void
    {
        $this->getJson('/api/products/999999')->assertNotFound();
    }
}
