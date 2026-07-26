<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\DeviceToken;

class Notifier
{
    public static function order(int $userId, string $title, string $body, int $orderId): void
    {
        AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => 'order',
            'order_id' => $orderId,
        ]);

        $tokens = DeviceToken::where('user_id', $userId)->pluck('token')->all();
        FcmSender::send($tokens, $title, $body, [
            'type' => 'order',
            'order_id' => $orderId,
        ]);
    }
}
