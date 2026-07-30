<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AddressTest extends TestCase
{
    use RefreshDatabase;

    private function payload(array $overrides = []): array
    {
        return array_merge([
            'full_name' => 'Jane Doe',
            'phone' => '01000000000',
            'line1' => '5 Main St',
            'city' => 'Cairo',
            'country' => 'Egypt',
        ], $overrides);
    }

    public function test_guest_cannot_list_addresses(): void
    {
        $this->getJson('/api/addresses')->assertUnauthorized();
    }

    public function test_index_returns_only_the_users_own_addresses(): void
    {
        $user = User::factory()->create();
        Address::factory()->count(2)->create(['user_id' => $user->id]);
        Address::factory()->create();
        Sanctum::actingAs($user);

        $this->getJson('/api/addresses')->assertOk()->assertJsonCount(2, 'data');
    }

    public function test_store_creates_an_address(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/addresses', $this->payload())->assertCreated();

        $this->assertDatabaseHas('addresses', [
            'user_id' => $user->id,
            'line1' => '5 Main St',
        ]);
    }

    public function test_first_address_is_marked_default_automatically(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/addresses', $this->payload(['is_default' => false]))->assertCreated();

        $this->assertSame(1, (int) $user->addresses()->first()->is_default);
    }

    public function test_setting_a_new_default_unsets_the_previous_default(): void
    {
        $user = User::factory()->create();
        $first = Address::factory()->create(['user_id' => $user->id, 'is_default' => true]);
        Sanctum::actingAs($user);

        $this->postJson('/api/addresses', $this->payload(['is_default' => true]))->assertCreated();

        $this->assertFalse((bool) $first->fresh()->is_default);
        $this->assertSame(1, $user->addresses()->where('is_default', true)->count());
    }

    public function test_store_validates_required_fields(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/addresses', ['full_name' => 'Only Name'])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['phone', 'line1', 'city']);
    }

    public function test_user_can_update_own_address(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create(['user_id' => $user->id]);
        Sanctum::actingAs($user);

        $this->putJson('/api/addresses/'.$address->id, $this->payload(['city' => 'Alexandria']))
            ->assertOk();

        $this->assertSame('Alexandria', $address->fresh()->city);
    }

    public function test_user_cannot_update_another_users_address(): void
    {
        $address = Address::factory()->create();
        Sanctum::actingAs(User::factory()->create());

        $this->putJson('/api/addresses/'.$address->id, $this->payload())->assertForbidden();
    }

    public function test_user_can_delete_own_address(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create(['user_id' => $user->id]);
        Sanctum::actingAs($user);

        $this->deleteJson('/api/addresses/'.$address->id)->assertOk();
        $this->assertDatabaseMissing('addresses', ['id' => $address->id]);
    }

    public function test_user_cannot_delete_another_users_address(): void
    {
        $address = Address::factory()->create();
        Sanctum::actingAs(User::factory()->create());

        $this->deleteJson('/api/addresses/'.$address->id)->assertForbidden();
        $this->assertDatabaseHas('addresses', ['id' => $address->id]);
    }
}
