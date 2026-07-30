<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class EmailVerificationTest extends TestCase
{
    use RefreshDatabase;

    private function seedCode(string $email, string $code = '123456', ?\DateTimeInterface $createdAt = null): void
    {
        DB::table('email_verifications')->updateOrInsert(
            ['email' => $email],
            ['code' => Hash::make($code), 'created_at' => $createdAt ?? now()],
        );
    }

    public function test_registration_stores_a_verification_code(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Jane',
            'email' => 'jane@example.com',
            'password' => 'secret123',
            'password_confirmation' => 'secret123',
        ])->assertCreated();

        $this->assertDatabaseHas('email_verifications', ['email' => 'jane@example.com']);
    }

    public function test_correct_code_verifies_the_user_and_returns_a_token(): void
    {
        $user = User::factory()->unverified()->create(['email' => 'jane@example.com']);
        $this->seedCode('jane@example.com', '123456');

        $response = $this->postJson('/api/email/verify', [
            'email' => 'jane@example.com',
            'code' => '123456',
        ]);

        $response->assertOk()->assertJsonStructure(['user', 'token']);
        $this->assertNotNull($user->fresh()->email_verified_at);
        $this->assertDatabaseMissing('email_verifications', ['email' => 'jane@example.com']);
    }

    public function test_wrong_code_is_rejected(): void
    {
        User::factory()->unverified()->create(['email' => 'jane@example.com']);
        $this->seedCode('jane@example.com', '123456');

        $this->postJson('/api/email/verify', [
            'email' => 'jane@example.com',
            'code' => '000000',
        ])->assertStatus(422);

        $this->assertDatabaseHas('email_verifications', ['email' => 'jane@example.com']);
    }

    public function test_expired_code_is_rejected(): void
    {
        User::factory()->unverified()->create(['email' => 'jane@example.com']);
        $this->seedCode('jane@example.com', '123456', now()->subMinutes(20));

        $this->postJson('/api/email/verify', [
            'email' => 'jane@example.com',
            'code' => '123456',
        ])->assertStatus(422)->assertJsonPath('message', 'The code has expired. Request a new one.');
    }

    public function test_verifying_without_a_pending_code_is_rejected(): void
    {
        User::factory()->unverified()->create(['email' => 'jane@example.com']);

        $this->postJson('/api/email/verify', [
            'email' => 'jane@example.com',
            'code' => '123456',
        ])->assertStatus(422);
    }

    public function test_resend_issues_a_code_for_an_unverified_user(): void
    {
        User::factory()->unverified()->create(['email' => 'pending@example.com']);

        $this->postJson('/api/email/resend', ['email' => 'pending@example.com'])->assertOk();

        $this->assertDatabaseHas('email_verifications', ['email' => 'pending@example.com']);
    }

    public function test_resend_does_nothing_for_an_already_verified_user(): void
    {
        User::factory()->create(['email' => 'done@example.com']);

        $this->postJson('/api/email/resend', ['email' => 'done@example.com'])->assertOk();

        $this->assertDatabaseMissing('email_verifications', ['email' => 'done@example.com']);
    }

    public function test_user_can_login_after_verifying(): void
    {
        User::factory()->unverified()->create([
            'email' => 'jane@example.com',
        ]);
        $this->seedCode('jane@example.com', '123456');

        $this->postJson('/api/email/verify', ['email' => 'jane@example.com', 'code' => '123456'])->assertOk();

        $this->postJson('/api/login', ['email' => 'jane@example.com', 'password' => 'password'])
            ->assertOk()
            ->assertJsonStructure(['token']);
    }
}
