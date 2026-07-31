<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type,
            'key' => $this->key,
            'order_id' => $this->order_id,
            'product_id' => $this->product_id,
            'image_url' => $this->image_url,
            'is_read' => $this->read_at !== null,
            'created_at' => $this->created_at,
        ];
    }
}
