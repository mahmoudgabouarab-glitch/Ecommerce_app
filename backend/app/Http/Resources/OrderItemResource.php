<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product_title' => $this->product_title,
            'product_image' => $this->product_image,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'line_total' => round((float) $this->unit_price * $this->quantity, 2),
        ];
    }
}
