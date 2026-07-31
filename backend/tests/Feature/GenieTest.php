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

    private function fakeGroq(array $first, array $second): void
    {
        Http::fake([
            'api.groq.com/*' => Http::sequence()->push($first, 200)->push($second, 200),
        ]);
    }

    private function groqToolCall(string $name, array $args): array
    {
        return [
            'choices' => [[
                'finish_reason' => 'tool_calls',
                'message' => [
                    'role' => 'assistant',
                    'content' => null,
                    'tool_calls' => [[
                        'id' => 'call_1',
                        'type' => 'function',
                        'function' => ['name' => $name, 'arguments' => json_encode($args)],
                    ]],
                ],
            ]],
        ];
    }

    private function groqText(string $text): array
    {
        return [
            'choices' => [[
                'finish_reason' => 'stop',
                'message' => ['role' => 'assistant', 'content' => $text],
            ]],
        ];
    }

    public function test_guest_cannot_use_the_assistant(): void
    {
        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'hi']],
        ])->assertUnauthorized();
    }

    public function test_assistant_runs_a_tool_and_returns_a_reply(): void
    {
        config(['services.groq.key' => 'test-key']);
        Sanctum::actingAs(User::factory()->create());

        $product = Product::factory()->create(['stock' => 10]);

        $this->fakeGroq(
            $this->groqToolCall('add_to_cart', ['product_id' => $product->id, 'quantity' => 2]),
            $this->groqText('Added 2 to your cart.'),
        );

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'add two of that to my cart']],
        ])
            ->assertOk()
            ->assertJsonPath('reply', 'Added 2 to your cart.')
            ->assertJsonPath('products.0.id', $product->id);

        $this->assertDatabaseHas('cart_items', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);
    }

    public function test_search_tool_returns_product_cards(): void
    {
        config(['services.groq.key' => 'test-key']);
        Sanctum::actingAs(User::factory()->create());

        $match = Product::factory()->create(['title' => 'Blue Running Shoes']);
        Product::factory()->create(['title' => 'Ceramic Plate']);

        $this->fakeGroq(
            $this->groqToolCall('search_products', ['query' => 'running shoes']),
            $this->groqText('Here is a great option.'),
        );

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'find me running shoes']],
        ])
            ->assertOk()
            ->assertJsonPath('products.0.id', $match->id)
            ->assertJsonCount(1, 'products');
    }

    public function test_missing_api_key_returns_a_friendly_message(): void
    {
        config(['services.groq.key' => null]);
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'hi']],
        ])
            ->assertOk()
            ->assertJsonPath('products', []);
    }

    public function test_gemini_provider_runs_tools(): void
    {
        config([
            'services.genie.provider' => 'gemini',
            'services.gemini.key' => 'test-key',
        ]);
        Sanctum::actingAs(User::factory()->create());

        $match = Product::factory()->create(['title' => 'Green Yoga Mat']);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::sequence()
                ->push($this->groqToolCall('search_products', ['query' => 'yoga mat']), 200)
                ->push($this->groqText('This one is perfect.'), 200),
        ]);

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'find a yoga mat']],
        ])
            ->assertOk()
            ->assertJsonPath('reply', 'This one is perfect.')
            ->assertJsonPath('products.0.id', $match->id);
    }

    public function test_anthropic_provider_also_runs_tools(): void
    {
        config([
            'services.genie.provider' => 'anthropic',
            'services.anthropic.key' => 'test-key',
        ]);
        Sanctum::actingAs(User::factory()->create());

        $product = Product::factory()->create(['stock' => 5]);

        Http::fake([
            'api.anthropic.com/*' => Http::sequence()
                ->push([
                    'stop_reason' => 'tool_use',
                    'content' => [[
                        'type' => 'tool_use',
                        'id' => 'tu_1',
                        'name' => 'add_to_cart',
                        'input' => ['product_id' => $product->id, 'quantity' => 1],
                    ]],
                ], 200)
                ->push([
                    'stop_reason' => 'end_turn',
                    'content' => [['type' => 'text', 'text' => 'Done.']],
                ], 200),
        ]);

        $this->postJson('/api/genie/chat', [
            'messages' => [['role' => 'user', 'content' => 'add it']],
        ])
            ->assertOk()
            ->assertJsonPath('reply', 'Done.');

        $this->assertDatabaseHas('cart_items', ['product_id' => $product->id, 'quantity' => 1]);
    }
}
