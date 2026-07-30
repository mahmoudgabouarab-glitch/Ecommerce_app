<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $this->role,
            'phone' => $this->phone,
            'show_phone' => (bool) $this->show_phone,
            'gender' => $this->gender,
            'birth_date' => $this->birth_date?->format('Y-m-d'),
            'bio' => $this->bio,
            'avatar' => str_starts_with((string) $this->avatar, 'http') ? $this->avatar : null,
            'created_at' => $this->created_at,
        ];
    }
}
