<?php

namespace Tests\Feature;

use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DeviceTokenTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_register_a_device_token(): void
    {
        $this->postJson('/api/device-tokens', ['token' => 'abc'])->assertUnauthorized();
    }

    public function test_user_can_register_a_device_token(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/device-tokens', ['token' => 'fcm-token-1', 'platform' => 'android'])
            ->assertOk();

        $this->assertDatabaseHas('device_tokens', [
            'token' => 'fcm-token-1',
            'user_id' => $user->id,
            'platform' => 'android',
        ]);
    }

    public function test_registering_an_existing_token_reassigns_it_to_the_new_user(): void
    {
        $first = User::factory()->create();
        DeviceToken::create(['token' => 'shared-token', 'user_id' => $first->id, 'platform' => 'ios']);

        $second = User::factory()->create();
        Sanctum::actingAs($second);

        $this->postJson('/api/device-tokens', ['token' => 'shared-token'])->assertOk();

        $this->assertDatabaseHas('device_tokens', ['token' => 'shared-token', 'user_id' => $second->id]);
        $this->assertDatabaseCount('device_tokens', 1);
    }

    public function test_token_is_required(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/device-tokens', [])
            ->assertStatus(422)->assertJsonValidationErrors('token');
    }

    public function test_platform_must_be_valid(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/device-tokens', ['token' => 't', 'platform' => 'windows'])
            ->assertStatus(422)->assertJsonValidationErrors('platform');
    }

    public function test_user_can_unregister_their_token(): void
    {
        $user = User::factory()->create();
        DeviceToken::create(['token' => 'to-remove', 'user_id' => $user->id]);
        Sanctum::actingAs($user);

        $this->deleteJson('/api/device-tokens', ['token' => 'to-remove'])->assertOk();

        $this->assertDatabaseMissing('device_tokens', ['token' => 'to-remove']);
    }
}
