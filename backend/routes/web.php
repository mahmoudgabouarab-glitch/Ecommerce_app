<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'Bazar API',
        'status' => 'running',
        'docs' => '/api/products',
    ]);
});
