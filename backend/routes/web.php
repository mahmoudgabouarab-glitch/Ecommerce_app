<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'ShopSphere API',
        'status' => 'running',
        'docs' => '/api/products',
    ]);
});

Route::get('storage/{path}', function (string $path) {
    abort_if(str_contains($path, '..'), 404);
    $full = storage_path('app/public/'.$path);
    abort_unless(is_file($full), 404);

    $mime = match (strtolower(pathinfo($full, PATHINFO_EXTENSION))) {
        'jpg', 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'svg' => 'image/svg+xml',
        default => 'application/octet-stream',
    };

    return response(file_get_contents($full), 200, [
        'Content-Type' => $mime,
        'Cache-Control' => 'public, max-age=31536000',
    ]);
})->where('path', '.*');
