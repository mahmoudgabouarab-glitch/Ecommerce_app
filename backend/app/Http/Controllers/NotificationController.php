<?php

namespace App\Http\Controllers;

use App\Http\Resources\NotificationResource;
use App\Models\AppNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    // GET /api/notifications — the user's notifications + unread count.
    public function index(Request $request)
    {
        $notifications = $request->user()->appNotifications()->paginate(20);

        return NotificationResource::collection($notifications)->additional([
            'unread_count' => $request->user()
                ->appNotifications()->whereNull('read_at')->count(),
        ]);
    }

    // POST /api/notifications/read-all
    public function readAll(Request $request)
    {
        $request->user()->appNotifications()
            ->whereNull('read_at')->update(['read_at' => now()]);

        return response()->json(['message' => 'All notifications marked as read.']);
    }

    // PATCH /api/notifications/{notification}/read
    public function read(Request $request, AppNotification $notification)
    {
        abort_if($notification->user_id !== $request->user()->id, 403);

        if ($notification->read_at === null) {
            $notification->update(['read_at' => now()]);
        }

        return new NotificationResource($notification);
    }
}
