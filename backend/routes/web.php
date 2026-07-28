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

    return response()->file($full);
})->where('path', '.*');
