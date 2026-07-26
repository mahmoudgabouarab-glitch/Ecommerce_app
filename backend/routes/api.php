<?php

use App\Http\Controllers\AddressController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CouponController;
use App\Http\Controllers\DeviceTokenController;
use App\Http\Controllers\EmailVerificationController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\PasswordController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\StatsController;
use App\Http\Controllers\WishlistController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public routes
|--------------------------------------------------------------------------
*/
Route::get('/_mailtest', function (\Illuminate\Http\Request $request) {
    $key = config('services.brevo.key');
    $config = [
        'brevo_key_set' => (bool) $key,
        'from' => config('mail.from.address'),
        'from_name' => config('mail.from.name'),
    ];
    if (! $key) {
        return response()->json(['ok' => false, 'reason' => 'BREVO_API_KEY not set', 'config' => $config], 500);
    }

    $res = \Illuminate\Support\Facades\Http::withHeaders(['api-key' => $key, 'accept' => 'application/json'])
        ->timeout(20)
        ->post('https://api.brevo.com/v3/smtp/email', [
            'sender' => ['email' => config('mail.from.address'), 'name' => config('mail.from.name') ?? 'ShopSphere'],
            'to' => [['email' => $request->query('email', 'test@example.com')]],
            'subject' => 'ShopSphere test',
            'htmlContent' => '<p>ShopSphere Brevo test — it works.</p>',
        ]);

    return response()->json([
        'ok' => $res->successful(),
        'status' => $res->status(),
        'body' => $res->json() ?? $res->body(),
        'config' => $config,
    ], $res->successful() ? 200 : 500);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/email/verify', [EmailVerificationController::class, 'verify']);
Route::post('/email/resend', [EmailVerificationController::class, 'resend']);
Route::post('/password/forgot', [PasswordController::class, 'forgot']);
Route::post('/password/reset', [PasswordController::class, 'reset']);

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{category}', [CategoryController::class, 'show']);

Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{product}', [ProductController::class, 'show']);
Route::get('/products/{product}/related', [ProductController::class, 'related']);
Route::get('/products/{product}/reviews', [ReviewController::class, 'index']);

/*
|--------------------------------------------------------------------------
| Authenticated routes (Sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // Account
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::post('/password/change', [PasswordController::class, 'change']);

    // Reviews
    Route::post('/products/{product}/reviews', [ReviewController::class, 'store']);
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);

    // Wishlist
    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist/{product}', [WishlistController::class, 'toggle']);

    // Cart
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{cartItem}', [CartController::class, 'update']);
    Route::delete('/cart/{cartItem}', [CartController::class, 'destroy']);
    Route::delete('/cart', [CartController::class, 'clear']);

    // Coupons
    Route::post('/coupons/apply', [CouponController::class, 'apply']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/read-all', [NotificationController::class, 'readAll']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'read']);

    // FCM device tokens (push notifications)
    Route::post('/device-tokens', [DeviceTokenController::class, 'store']);
    Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);

    // Addresses
    Route::apiResource('addresses', AddressController::class)->except(['show']);

    // Orders
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::patch('/orders/{order}/cancel', [OrderController::class, 'cancel']);

    /*
    |----------------------------------------------------------------------
    | Admin routes
    |----------------------------------------------------------------------
    */
    Route::middleware('admin')->prefix('admin')->group(function () {
        // Products
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{product}', [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);

        // Categories
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{category}', [CategoryController::class, 'update']);
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);

        // Coupons
        Route::get('/coupons', [CouponController::class, 'index']);
        Route::post('/coupons', [CouponController::class, 'store']);
        Route::delete('/coupons/{coupon}', [CouponController::class, 'destroy']);

        // Orders
        Route::get('/orders', [OrderController::class, 'adminIndex']);
        Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);

        // Dashboard stats
        Route::get('/stats', [StatsController::class, 'index']);
    });
});
