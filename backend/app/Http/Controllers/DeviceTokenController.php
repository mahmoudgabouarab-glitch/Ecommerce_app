<?php

namespace App\Http\Controllers;

use App\Models\DeviceToken;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    // POST /api/device-tokens  { token, platform? }
    // Registers (or re-assigns) an FCM token for the authenticated user.
    public function store(Request $request)
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'platform' => ['nullable', 'in:android,ios'],
        ]);

        // A token is unique to a device; make sure it belongs to this user only.
        DeviceToken::updateOrCreate(
            ['token' => $data['token']],
            ['user_id' => $request->user()->id, 'platform' => $data['platform'] ?? null],
        );

        return response()->json(['message' => 'Device registered.']);
    }

    // DELETE /api/device-tokens  { token }  — called on logout.
    public function destroy(Request $request)
    {
        $data = $request->validate(['token' => ['required', 'string']]);

        $request->user()->deviceTokens()->where('token', $data['token'])->delete();

        return response()->json(['message' => 'Device unregistered.']);
    }
}
