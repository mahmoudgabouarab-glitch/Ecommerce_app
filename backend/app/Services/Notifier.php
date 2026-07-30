<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\DeviceToken;

class Notifier
{
    public static function order(int $userId, string $title, string $body, int $orderId, ?string $key = null): void
    {
        AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => 'order',
            'key' => $key,
            'order_id' => $orderId,
        ]);

        $tokens = DeviceToken::where('user_id', $userId)->pluck('token')->all();
        FcmSender::send($tokens, $title, $body, [
            'type' => 'order',
            'order_id' => $orderId,
        ]);
    }

    public static function sale(int $userId, string $title, string $body, int $productId): void
    {
        AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => 'sale',
            'key' => 'sale_drop',
            'order_id' => null,
        ]);

        $tokens = DeviceToken::where('user_id', $userId)->pluck('token')->all();
        FcmSender::send($tokens, $title, $body, [
            'type' => 'sale',
            'product_id' => $productId,
        ]);
    }
}
