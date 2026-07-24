<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class PasswordController extends Controller
{
    /**
     * POST /api/password/forgot — issue a 6-digit reset code.
     *
     * In production this code would be emailed. For this project (no SMTP set up)
     * it is returned in the response so the flow can be demoed end-to-end.
     */
    public function forgot(Request $request)
    {
        $request->validate(['email' => ['required', 'email']]);

        $user = User::where('email', $request->email)->first();
        if (! $user) {
            return response()->json(['message' => 'No account with that email.'], 404);
        }

        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $request->email],
            ['token' => Hash::make($otp), 'created_at' => now()]
        );

        return response()->json([
            'message' => 'A reset code has been generated.',
            'otp' => $otp, // demo only — normally sent by email
        ]);
    }

    /**
     * POST /api/password/reset — verify the code and set a new password.
     */
    public function reset(Request $request)
    {
        $request->validate([
            'email' => ['required', 'email'],
            'otp' => ['required', 'string'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $row = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (! $row || now()->diffInMinutes($row->created_at) > 60) {
            return response()->json(['message' => 'Reset code expired. Request a new one.'], 422);
        }
        if (! Hash::check($request->otp, $row->token)) {
            return response()->json(['message' => 'Invalid reset code.'], 422);
        }

        User::where('email', $request->email)->update([
            'password' => Hash::make($request->password),
        ]);
        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        return response()->json(['message' => 'Password reset successfully.']);
    }

    /**
     * POST /api/password/change — change password for the logged-in user.
     */
    public function change(Request $request)
    {
        $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = $request->user();
        if (! Hash::check($request->current_password, $user->password)) {
            return response()->json(['message' => 'Current password is incorrect.'], 422);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json(['message' => 'Password changed successfully.']);
    }
}
