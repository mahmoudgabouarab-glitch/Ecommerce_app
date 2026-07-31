<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GenieTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_use_the_assistant(): void
    {
        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'hi']],
        ])->assertUnauthorized();
    }

    public function test_assistant_runs_a_tool_and_returns_a_reply(): void
    {
        config(['services.anthropic.key' => 'test-key']);
        Sanctum::actingAs(User::factory()->create());

        $product = Product::factory()->create(['stock' => 10]);

        Http::fake([
            'api.anthropic.com/*' => Http::sequence()
                ->push([
                    'stop_reason' => 'tool_use',
                    'content' => [
                        ['type' => 'text', 'text' => 'On it.'],
                        [
                            'type' => 'tool_use',
                            'id' => 'tu_1',
                            'name' => 'add_to_cart',
                            'input' => ['product_id' => $product->id, 'quantity' => 2],
                        ],
                    ],
                ], 200)
                ->push([
                    'stop_reason' => 'end_turn',
                    'content' => [['type' => 'text', 'text' => 'Added 2 to your cart.']],
                ], 200),
        ]);

        $response = $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'add two of that to my cart']],
        ]);

        $response->assertOk()
            ->assertJsonPath('reply', 'Added 2 to your cart.')
            ->assertJsonPath('products.0.id', $product->id);

        $this->assertDatabaseHas('cart_items', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);
    }

    public function test_search_tool_returns_product_cards(): void
    {
        config(['services.anthropic.key' => 'test-key']);
        Sanctum::actingAs(User::factory()->create());

        $match = Product::factory()->create(['title' => 'Blue Running Shoes']);
        Product::factory()->create(['title' => 'Ceramic Plate']);

        Http::fake([
            'api.anthropic.com/*' => Http::sequence()
                ->push([
                    'stop_reason' => 'tool_use',
                    'content' => [[
                        'type' => 'tool_use',
                        'id' => 'tu_1',
                        'name' => 'search_products',
                        'input' => ['query' => 'running shoes'],
                    ]],
                ], 200)
                ->push([
                    'stop_reason' => 'end_turn',
                    'content' => [['type' => 'text', 'text' => 'Here is a great option.']],
                ], 200),
        ]);

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'find me running shoes']],
        ])
            ->assertOk()
            ->assertJsonPath('products.0.id', $match->id)
            ->assertJsonCount(1, 'products');
    }

    public function test_missing_api_key_returns_a_friendly_message(): void
    {
        config(['services.anthropic.key' => null]);
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'hi']],
        ])
            ->assertOk()
            ->assertJsonPath('products', []);
    }
}
