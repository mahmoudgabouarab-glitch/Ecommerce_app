<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /** The seeded primary admin — always kept as admin. */
    private const PRIMARY_ADMIN = 'admin@shopsphere.com';

    // GET /api/users/{user}/profile — public info about a reviewer.
    public function publicProfile(User $user)
    {
        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'avatar' => $user->avatar ? url('storage/'.$user->avatar) : null,
            'member_since' => $user->created_at?->format('Y-m'),
            'reviews_count' => $user->reviews()->count(),
        ]);
    }

    // GET /api/admin/users?search=
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

    // PATCH /api/admin/users/{user}/role  { role: admin|customer }
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
}
