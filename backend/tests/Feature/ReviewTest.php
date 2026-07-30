<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ReviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_post_a_review(): void
    {
        $product = Product::factory()->create();

        $this->postJson('/api/products/'.$product->id.'/reviews', ['rating' => 5])
            ->assertUnauthorized();
    }

    public function test_authenticated_user_can_post_a_review(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/products/'.$product->id.'/reviews', [
            'rating' => 4,
            'comment' => 'Solid product.',
        ])->assertCreated()->assertJsonPath('data.rating', 4);

        $this->assertDatabaseHas('reviews', [
            'product_id' => $product->id,
            'user_id' => $user->id,
            'rating' => 4,
        ]);
    }

    public function test_posting_again_updates_the_existing_review(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/products/'.$product->id.'/reviews', ['rating' => 2]);
        $this->postJson('/api/products/'.$product->id.'/reviews', ['rating' => 5]);

        $this->assertSame(1, Review::where('product_id', $product->id)->where('user_id', $user->id)->count());
        $this->assertDatabaseHas('reviews', [
            'product_id' => $product->id,
            'user_id' => $user->id,
            'rating' => 5,
        ]);
    }

    public function test_rating_must_be_between_1_and_5(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/products/'.$product->id.'/reviews', ['rating' => 6])
            ->assertStatus(422)->assertJsonValidationErrors('rating');

        $this->postJson('/api/products/'.$product->id.'/reviews', ['rating' => 0])
            ->assertStatus(422)->assertJsonValidationErrors('rating');
    }

    public function test_posting_a_review_refreshes_product_rating(): void
    {
        $user = User::factory()->create();
        $product = Product::factory()->create(['rating' => 0, 'rating_count' => 0]);
        Sanctum::actingAs($user);

        $this->postJson('/api/products/'.$product->id.'/reviews', ['rating' => 4]);

        $product->refresh();
        $this->assertSame(1, $product->rating_count);
        $this->assertEquals(4.0, (float) $product->rating);
    }
}
