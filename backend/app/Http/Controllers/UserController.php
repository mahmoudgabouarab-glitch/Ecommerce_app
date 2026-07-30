<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    private const PRIMARY_ADMIN = 'admin@shopsphere.com';

    public function publicProfile(User $user)
    {
        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'avatar' => str_starts_with((string) $user->avatar, 'http') ? $user->avatar : null,
            'gender' => $user->gender,
            'birth_date' => $user->birth_date?->format('Y-m-d'),
            'phone' => $user->show_phone ? $user->phone : null,
            'bio' => $user->bio,
            'member_since' => $user->created_at?->format('Y-m'),
            'reviews_count' => $user->reviews()->count(),
        ]);
    }

    public function index(Request $request)
    {
        $search = trim((string) $request->query('search', ''));

        $users = User::query()
            ->when($search !== '', fn ($q) => $q->where(
                fn ($w) => $w->where('email', 'like', "%{$search}%")
                    ->orWhere('name', 'like', "%{$search}%")
            ))
            ->orderByDesc('created_at')
            ->limit(50)
            ->get();

        return UserResource::collection($users);
    }

    public function updateRole(Request $request, User $user)
    {
        $data = $request->validate(['role' => ['required', 'in:admin,customer']]);

        if ($user->id === $request->user()->id) {
            return response()->json(['message' => 'You cannot change your own role.'], 422);
        }
        if ($user->email === self::PRIMARY_ADMIN && $data['role'] !== 'admin') {
            return response()->json(['message' => 'The primary admin cannot be demoted.'], 422);
        }

        $user->update(['role' => $data['role']]);

        return response()->json(new UserResource($user));
    }

    public function destroy(Request $request, User $user)
    {
        if ($user->id === $request->user()->id) {
            return response()->json(['message' => 'You cannot delete your own account.'], 422);
        }
        if ($user->email === self::PRIMARY_ADMIN) {
            return response()->json(['message' => 'The primary admin cannot be deleted.'], 422);
        }

        $user->delete();

        return response()->json(['message' => 'User deleted.']);
    }
}
