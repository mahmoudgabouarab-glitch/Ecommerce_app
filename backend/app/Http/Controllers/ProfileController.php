<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function update(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'show_phone' => ['sometimes', 'boolean'],
            'gender' => ['nullable', 'in:male,female,other'],
            'birth_date' => ['nullable', 'date'],
            'bio' => ['nullable', 'string', 'max:500'],
            'avatar' => ['nullable', 'image', 'max:2048'],
        ]);

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $user->avatar = $request->file('avatar')->store('avatars', 'public');
        }

        foreach (['name', 'phone', 'gender', 'birth_date', 'bio'] as $field) {
            if (array_key_exists($field, $data)) {
                $user->{$field} = $data[$field];
            }
        }
        if ($request->has('show_phone')) {
            $user->show_phone = $request->boolean('show_phone');
        }
        $user->save();

        return new UserResource($user);
    }
}
