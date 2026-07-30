<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        return [
            'category_id' => Category::factory(),
            'title' => fake()->words(3, true),
            'description' => fake()->sentence(),
            'brand' => fake()->company(),
            'price' => fake()->randomFloat(2, 10, 1000),
            'sale_price' => null,
            'stock' => fake()->numberBetween(1, 100),
            'images' => [fake()->imageUrl(), fake()->imageUrl()],
            'rating' => 0,
            'rating_count' => 0,
            'is_featured' => false,
        ];
    }

    public function featured(): static
    {
        return $this->state(fn () => ['is_featured' => true]);
    }

    public function outOfStock(): static
    {
        return $this->state(fn () => ['stock' => 0]);
    }
}
