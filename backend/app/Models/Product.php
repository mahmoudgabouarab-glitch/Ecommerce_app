<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'title',
        'description',
        'brand',
        'price',
        'sale_price',
        'deal_ends_at',
        'stock',
        'images',
        'rating',
        'rating_count',
        'is_featured',
    ];

    protected $casts = [
        'images' => 'array',
        'price' => 'decimal:2',
        'sale_price' => 'decimal:2',
        'deal_ends_at' => 'datetime',
        'rating' => 'decimal:1',
        'is_featured' => 'boolean',
    ];

    public function getEffectivePriceAttribute(): float
    {
        return (float) ($this->sale_price ?? $this->price);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function variants(): HasMany
    {
        return $this->hasMany(ProductVariant::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function refreshRating(): void
    {
        $this->rating = round((float) $this->reviews()->avg('rating'), 1);
        $this->rating_count = $this->reviews()->count();
        $this->save();
    }
}
