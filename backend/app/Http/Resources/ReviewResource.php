<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'rating' => $this->rating,
            'comment' => $this->comment,
            'user_id' => $this->user_id,
            'user_name' => $this->whenLoaded('user', fn () => $this->user->name),
            'user_avatar' => $this->whenLoaded('user', fn () => str_starts_with((string) $this->user->avatar, 'http') ? $this->user->avatar : null),
            'created_at' => $this->created_at,
        ];
    }
}
