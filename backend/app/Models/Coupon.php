<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'discount_type',
        'amount',
        'min_total',
        'expires_at',
        'is_active',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'min_total' => 'decimal:2',
        'expires_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    /**
     * Whether this coupon can currently be applied to the given subtotal.
     */
    public function isValidFor(float $subtotal): bool
    {
        if (! $this->is_active) {
            return false;
        }
        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }

        return $subtotal >= (float) $this->min_total;
    }

    /**
     * Discount amount (in currency) for the given subtotal.
     */
    public function discountFor(float $subtotal): float
    {
        $discount = $this->discount_type === 'percent'
            ? $subtotal * ((float) $this->amount / 100)
            : (float) $this->amount;

        // Never discount more than the subtotal itself.
        return round(min($discount, $subtotal), 2);
    }
}
