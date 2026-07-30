<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        $subtotal = fake()->randomFloat(2, 100, 1000);

        return [
            'user_id' => User::factory(),
            'address_id' => null,
            'status' => 'pending',
            'payment_method' => 'cash',
            'subtotal' => $subtotal,
            'discount' => 0,
            'shipping_fee' => 50,
            'total' => $subtotal + 50,
            'coupon_code' => null,
        ];
    }
}
