<?php

return [
    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'fcm' => [
        'credentials' => env('FCM_CREDENTIALS'),
    ],

    'anthropic' => [
        'key' => env('ANTHROPIC_API_KEY'),
        'model' => env('ANTHROPIC_MODEL', 'claude-haiku-4-5-20251001'),
        'base_url' => env('ANTHROPIC_BASE_URL', 'https://api.anthropic.com'),
    ],

    'brevo' => [
        'key' => env('BREVO_API_KEY'),
    ],

    'cloudinary' => [
        'url' => env('CLOUDINARY_URL'),
    ],

    'paymob' => [
        'base_url' => env('PAYMOB_BASE_URL', 'https://accept.paymob.com'),
        'api_key' => env('PAYMOB_API_KEY'),
        'card_integration_id' => env('PAYMOB_CARD_INTEGRATION_ID'),
        'iframe_id' => env('PAYMOB_IFRAME_ID'),
        'hmac_secret' => env('PAYMOB_HMAC_SECRET'),
    ],
];
