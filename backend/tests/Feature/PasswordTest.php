<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PasswordTest extends TestCase
{
    use RefreshDatabase;

    private function seedResetToken(string $email, string $otp = '123456', ?\DateTimeInterface $createdAt = null): void
    {
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            ['token' => Hash::make($otp), 'created_at' => $createdAt ?? now()],
        );
    }

    public function test_forgot_returns_404_for_unknown_email(): void
    {
        $this->postJson('/api/password/forgot', ['email' => 'nobody@example.com'])
            ->assertNotFound();
    }

    public function test_forgot_issues_a_reset_token_for_a_known_email(): void
    {
        User::factory()->create(['email' => 'jane@example.com']);

        $this->postJson('/api/password/forgot', ['email' => 'jane@example.com'])->assertOk();

        $this->assertDatabaseHas('password_reset_tokens', ['email' => 'jane@example.com']);
    }

    public function test_reset_with_valid_otp_changes_the_password(): void
    {
        User::factory()->create(['email' => 'jane@example.com']);
        $this->seedResetToken('jane@example.com', '654321');

        $this->postJson('/api/password/reset', [
            'email' => 'jane@example.com',
            'otp' => '654321',
            'password' => 'newpass123',
            'password_confirmation' => 'newpass123',
        ])->assertOk();

        $this->assertDatabaseMissing('password_reset_tokens', ['email' => 'jane@example.com']);
        $this->postJson('/api/login', ['email' => 'jane@example.com', 'password' => 'newpass123'])
            ->assertOk()->assertJsonStructure(['token']);
    }

    public function test_reset_rejects_a_wrong_otp(): void
    {
        User::factory()->create(['email' => 'jane@example.com']);
        $this->seedResetToken('jane@example.com', '654321');

        $this->postJson('/api/password/reset', [
            'email' => 'jane@example.com',
            'otp' => '000000',
            'password' => 'newpass123',
            'password_confirmation' => 'newpass123',
        ])->assertStatus(422);
    }

    public function test_reset_rejects_an_expired_otp(): void
    {
        User::factory()->create(['email' => 'jane@example.com']);
        $this->seedResetToken('jane@example.com', '654321', now()->subMinutes(90));

        $this->postJson('/api/password/reset', [
            'email' => 'jane@example.com',
            'otp' => '654321',
            'password' => 'newpass123',
            'password_confirmation' => 'newpass123',
        ])->assertStatus(422);
    }

    public function test_reset_requires_matching_password_confirmation(): void
    {
        User::factory()->create(['email' => 'jane@example.com']);
        $this->seedResetToken('jane@example.com', '654321');

        $this->postJson('/api/password/reset', [
            'email' => 'jane@example.com',
            'otp' => '654321',
            'password' => 'newpass123',
            'password_confirmation' => 'different',
        ])->assertStatus(422)->assertJsonValidationErrors('password');
    }

    public function test_guest_cannot_change_password(): void
    {
        $this->postJson('/api/password/change', [])->assertUnauthorized();
    }

    public function test_change_password_with_correct_current_password(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/password/change', [
            'current_password' => 'password',
            'password' => 'brandnew123',
            'password_confirmation' => 'brandnew123',
        ])->assertOk();

        $this->assertTrue(Hash::check('brandnew123', $user->fresh()->password));
    }

    public function test_change_password_rejects_wrong_current_password(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/password/change', [
            'current_password' => 'wrong-one',
            'password' => 'brandnew123',
            'password_confirmation' => 'brandnew123',
        ])->assertStatus(422);

        $this->assertTrue(Hash::check('password', $user->fresh()->password));
    }
}
