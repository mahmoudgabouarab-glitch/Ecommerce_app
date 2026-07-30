<?php

namespace Tests\Feature;

use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    private function makeNotification(User $user, array $overrides = []): AppNotification
    {
        return AppNotification::create(array_merge([
            'user_id' => $user->id,
            'title' => 'Hello',
            'body' => 'A message',
            'type' => 'order',
        ], $overrides));
    }

    public function test_guest_cannot_list_notifications(): void
    {
        $this->getJson('/api/notifications')->assertUnauthorized();
    }

    public function test_index_returns_own_notifications_with_unread_count(): void
    {
        $user = User::factory()->create();
        $this->makeNotification($user);
        $this->makeNotification($user, ['read_at' => now()]);
        $this->makeNotification(User::factory()->create());
        Sanctum::actingAs($user);

        $this->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('unread_count', 1);
    }

    public function test_marking_a_notification_read_sets_read_at(): void
    {
        $user = User::factory()->create();
        $notification = $this->makeNotification($user);
        Sanctum::actingAs($user);

        $this->patchJson('/api/notifications/'.$notification->id.'/read')->assertOk();

        $this->assertNotNull($notification->fresh()->read_at);
    }

    public function test_cannot_mark_another_users_notification_read(): void
    {
        $notification = $this->makeNotification(User::factory()->create());
        Sanctum::actingAs(User::factory()->create());

        $this->patchJson('/api/notifications/'.$notification->id.'/read')->assertForbidden();
        $this->assertNull($notification->fresh()->read_at);
    }

    public function test_read_all_marks_every_unread_notification(): void
    {
        $user = User::factory()->create();
        $this->makeNotification($user);
        $this->makeNotification($user);
        Sanctum::actingAs($user);

        $this->postJson('/api/notifications/read-all')->assertOk();

        $this->assertSame(0, $user->appNotifications()->whereNull('read_at')->count());
    }
}
