<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminUserManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_delete_a_customer(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
        $customer = User::factory()->create(['role' => 'customer']);

        $this->deleteJson('/api/admin/users/'.$customer->id)->assertOk();

        $this->assertDatabaseMissing('users', ['id' => $customer->id]);
    }

    public function test_admin_cannot_delete_their_own_account(): void
    {
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        $this->deleteJson('/api/admin/users/'.$admin->id)->assertStatus(422);
        $this->assertDatabaseHas('users', ['id' => $admin->id]);
    }

    public function test_primary_admin_cannot_be_deleted(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
        $primary = User::factory()->admin()->create(['email' => 'admin@shopsphere.com']);

        $this->deleteJson('/api/admin/users/'.$primary->id)->assertStatus(422);
        $this->assertDatabaseHas('users', ['id' => $primary->id]);
    }
}
