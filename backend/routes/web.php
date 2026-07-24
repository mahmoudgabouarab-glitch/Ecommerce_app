<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'ShopSphere API',
        'status' => 'running',
        'docs' => '/api/products',
    ]);
});
