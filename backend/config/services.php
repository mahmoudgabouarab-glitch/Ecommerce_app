<?php

return [
    // Third-party service credentials (Stripe, mail, etc.) go here.
    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    // Firebase Cloud Messaging — the service-account JSON, as a single-line
    // string in the FCM_CREDENTIALS env var. Empty = push disabled (in-app
    // notifications still work).
    'fcm' => [
        'credentials' => env('FCM_CREDENTIALS'),
    ],

    // Brevo transactional email (HTTP API — SMTP ports are blocked on Railway).
    'brevo' => [
        'key' => env('BREVO_API_KEY'),
    ],
];
