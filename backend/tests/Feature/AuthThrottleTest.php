<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthThrottleTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_is_rate_limited_after_repeated_attempts(): void
    {
        User::factory()->create(['email' => 'target@example.com']);

        for ($i = 0; $i < 6; $i++) {
            $response = $this->postJson('/api/login', [
                'email' => 'target@example.com',
                'password' => 'wrong-password',
            ]);
            $this->assertNotSame(429, $response->status(), "attempt {$i} should not be throttled");
        }

        $this->postJson('/api/login', [
            'email' => 'target@example.com',
            'password' => 'wrong-password',
        ])->assertStatus(429);
    }

    public function test_throttle_is_scoped_per_email(): void
    {
        for ($i = 0; $i < 6; $i++) {
            $this->postJson('/api/login', [
                'email' => 'victim@example.com',
                'password' => 'x',
            ]);
        }

        $this->postJson('/api/login', [
            'email' => 'someone-else@example.com',
            'password' => 'x',
        ])->assertStatus(422);
    }

    public function test_password_forgot_is_rate_limited(): void
    {
        for ($i = 0; $i < 6; $i++) {
            $this->postJson('/api/password/forgot', ['email' => 'spam@example.com']);
        }

        $this->postJson('/api/password/forgot', ['email' => 'spam@example.com'])
            ->assertStatus(429);
    }
}
