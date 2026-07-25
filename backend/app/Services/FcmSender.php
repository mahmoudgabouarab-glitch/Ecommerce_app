<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Minimal Firebase Cloud Messaging (HTTP v1) sender. Signs a JWT with the
 * service-account key, exchanges it for an OAuth token, and posts to FCM.
 * Everything is wrapped so a push failure never breaks the calling flow.
 */
class FcmSender
{
    public static function send(array $tokens, string $title, string $body, array $data = []): void
    {
        $tokens = array_values(array_filter($tokens));
        if (empty($tokens)) {
            return;
        }

        $sa = self::credentials();
        if ($sa === null) {
            return; // FCM not configured — silently skip.
        }

        try {
            $accessToken = self::accessToken($sa);
            if ($accessToken === null) {
                return;
            }

            $url = "https://fcm.googleapis.com/v1/projects/{$sa['project_id']}/messages:send";
            $stringData = array_map(fn ($v) => (string) $v, $data);

            foreach ($tokens as $token) {
                Http::withToken($accessToken)->post($url, [
                    'message' => [
                        'token' => $token,
                        'notification' => ['title' => $title, 'body' => $body],
                        'data' => $stringData,
                        'android' => ['priority' => 'high'],
                    ],
                ]);
            }
        } catch (\Throwable $e) {
            Log::warning('FCM send failed: '.$e->getMessage());
        }
    }

    private static function credentials(): ?array
    {
        $raw = config('services.fcm.credentials');
        if (empty($raw)) {
            return null;
        }
        $sa = is_array($raw) ? $raw : json_decode($raw, true);

        return is_array($sa)
            && isset($sa['private_key'], $sa['client_email'], $sa['project_id'])
                ? $sa : null;
    }

    private static function accessToken(array $sa): ?string
    {
        $now = time();
        $header = self::b64url(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $claims = self::b64url(json_encode([
            'iss' => $sa['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ]));

        $signature = '';
        openssl_sign("{$header}.{$claims}", $signature, $sa['private_key'], OPENSSL_ALGO_SHA256);
        $jwt = "{$header}.{$claims}.".self::b64url($signature);

        $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ]);

        return $response->successful() ? $response->json('access_token') : null;
    }

    private static function b64url(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
