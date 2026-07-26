<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Sends transactional email through the Brevo HTTP API (port 443), because
 * cloud hosts such as Railway block outbound SMTP ports. Never throws.
 */
class Mailer
{
    public static function sendOtp(string $to, string $subject, string $intro, string $code): void
    {
        $html = view('emails.otp', [
            'subjectLine' => $subject,
            'intro' => $intro,
            'code' => $code,
        ])->render();

        self::send($to, $subject, $html);
    }

    private static function send(string $to, string $subject, string $html): void
    {
        $key = config('services.brevo.key');
        if (empty($key)) {
            Log::warning('BREVO_API_KEY not configured — email not sent.');

            return;
        }

        try {
            $response = Http::withHeaders(['api-key' => $key, 'accept' => 'application/json'])
                ->timeout(20)
                ->post('https://api.brevo.com/v3/smtp/email', [
                    'sender' => [
                        'email' => config('mail.from.address'),
                        'name' => config('mail.from.name') ?? 'ShopSphere',
                    ],
                    'to' => [['email' => $to]],
                    'subject' => $subject,
                    'htmlContent' => $html,
                ]);

            if (! $response->successful()) {
                Log::warning('Brevo email failed: '.$response->status().' '.$response->body());
            }
        } catch (\Throwable $e) {
            Log::warning('Email send failed: '.$e->getMessage());
        }
    }
}
