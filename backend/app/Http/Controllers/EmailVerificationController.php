<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\Mailer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class EmailVerificationController extends Controller
{
    /**
     * Generate a 6-digit code, store it hashed, and email it to the address.
     * Never throws — a mail failure is logged so the calling flow continues.
     */
    public static function sendCode(string $email): void
    {
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        DB::table('email_verifications')->updateOrInsert(
            ['email' => $email],
            ['code' => Hash::make($code), 'created_at' => now()],
        );

        Mailer::sendOtp(
            $email,
            'Verify your email',
            'Use the code below to verify your email address:',
            $code,
        );
    }

    // POST /api/email/verify  { email, code }
    public function verify(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'code' => ['required', 'string'],
        ]);

        $row = DB::table('email_verifications')->where('email', $data['email'])->first();

        if (! $row || now()->diffInMinutes($row->created_at) > 15) {
            return response()->json(['message' => 'The code has expired. Request a new one.'], 422);
        }
        if (! Hash::check($data['code'], $row->code)) {
            return response()->json(['message' => 'Invalid verification code.'], 422);
        }

        $user = User::where('email', $data['email'])->firstOrFail();
        $user->forceFill(['email_verified_at' => now()])->save();
        DB::table('email_verifications')->where('email', $data['email'])->delete();

        return response()->json([
            'user' => new UserResource($user),
            'token' => $user->createToken('mobile')->plainTextToken,
        ]);
    }

    // POST /api/email/resend  { email }
    public function resend(Request $request)
    {
        $data = $request->validate(['email' => ['required', 'email']]);

        $user = User::where('email', $data['email'])->first();
        if ($user && ! $user->email_verified_at) {
            self::sendCode($data['email']);
        }

        return response()->json(['message' => 'A new code has been sent if the account needs verification.']);
    }
}
