<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'ShopSphere API',
        'status' => 'running',
        'docs' => '/api/products',
    ]);
});

Route::get('/_diag', function () {
    $link = public_path('storage');
    $dir = storage_path('app/public/banners');

    return response()->json([
        'link_exists' => file_exists($link),
        'is_link' => is_link($link),
        'link_target' => is_link($link) ? readlink($link) : null,
        'banners_is_dir' => is_dir($dir),
        'banners_files' => is_dir($dir) ? array_values(array_slice(scandir($dir), 2, 8)) : [],
        'sample_isfile' => is_file(storage_path('app/public/banners/gJ9bBU4slG7VZi9ijkWCrQ6CVVz9a9M5enxoScr6.jpg')),
    ]);
});

Route::get('storage/{path}', function (string $path) {
    try {
        if (str_contains($path, '..')) {
            return response('bad path', 404);
        }
        $full = storage_path('app/public/'.$path);
        if (! is_file($full)) {
            return response('missing: '.$full, 404);
        }

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
    } catch (\Throwable $e) {
        return response('ERR '.$e->getMessage().' @ '.basename($e->getFile()).':'.$e->getLine(), 500);
    }
})->where('path', '.*');
