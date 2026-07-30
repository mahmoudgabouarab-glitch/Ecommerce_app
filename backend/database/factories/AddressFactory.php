<?php

namespace Database\Factories;

use App\Models\Address;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class AddressFactory extends Factory
{
    protected $model = Address::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'full_name' => fake()->name(),
            'phone' => fake()->numerify('01#########'),
            'line1' => fake()->streetAddress(),
            'city' => fake()->city(),
            'country' => 'Egypt',
            'is_default' => true,
        ];
    }
}
