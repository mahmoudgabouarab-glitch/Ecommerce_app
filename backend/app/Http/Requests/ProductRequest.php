<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $required = $this->isMethod('post') ? 'required' : 'sometimes';

        return [
            'category_id' => ['nullable', 'exists:categories,id'],
            'title' => [$required, 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'brand' => ['nullable', 'string', 'max:255'],
            'price' => [$required, 'numeric', 'min:0'],
            'sale_price' => ['nullable', 'numeric', 'min:0', 'lte:price'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'image' => ['nullable', 'image', 'max:2048'],
            'images' => ['nullable', 'array'],
            'images.*' => ['url'],
            'photos' => ['nullable', 'array'],
            'photos.*' => ['image', 'max:2048'],
            'existing_images' => ['nullable', 'array'],
            'existing_images.*' => ['string'],
            'sync_images' => ['nullable', 'boolean'],
            'sync_variants' => ['nullable', 'boolean'],
            'is_featured' => ['boolean'],
            'variants' => ['nullable', 'array'],
            'variants.*.id' => ['nullable', 'integer'],
            'variants.*.size' => ['nullable', 'string', 'max:50'],
            'variants.*.color' => ['nullable', 'string', 'max:50'],
            'variants.*.stock' => ['nullable', 'integer', 'min:0'],
            'variants.*.price_diff' => ['nullable', 'numeric'],
        ];
    }
}
