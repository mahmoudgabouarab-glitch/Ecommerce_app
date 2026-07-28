<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BannerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'image' => str_starts_with((string) $this->image, 'http')
                ? $this->image
                : url('storage/'.$this->image),
            'title' => $this->title,
            'subtitle' => $this->subtitle,
            'link_type' => $this->link_type,
            'link_value' => $this->link_value,
            'is_active' => (bool) $this->is_active,
            'sort_order' => $this->sort_order,
        ];
    }
}
