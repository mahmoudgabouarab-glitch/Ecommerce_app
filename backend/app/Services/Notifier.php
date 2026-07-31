<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\DeviceToken;
use Illuminate\Support\Facades\DB;

class Notifier
{
    public static function order(int $userId, string $title, string $body, int $orderId, ?string $key = null): void
    {
        $image = DB::table('order_items')
            ->where('order_id', $orderId)
            ->value('product_image');

        AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => 'order',
            'key' => $key,
            'order_id' => $orderId,
            'image_url' => $image,
        ]);

        $tokens = DeviceToken::where('user_id', $userId)->pluck('token')->all();
        FcmSender::send($tokens, $title, $body, [
            'type' => 'order',
            'order_id' => $orderId,
        ], $image);
    }

    public static function sale(int $userId, string $title, string $body, int $productId, ?string $image = null): void
    {
        AppNotification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => 'sale',
            'key' => 'sale_drop',
            'order_id' => null,
            'image_url' => $image,
            'product_id' => $productId,
        ]);

        $tokens = DeviceToken::where('user_id', $userId)->pluck('token')->all();
        FcmSender::send($tokens, $title, $body, [
            'type' => 'sale',
            'product_id' => $productId,
        ], $image);
    }
}
