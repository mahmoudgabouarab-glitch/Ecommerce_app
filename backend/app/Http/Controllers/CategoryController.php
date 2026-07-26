<?php

namespace App\Http\Controllers;

use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    // GET /api/categories
    public function index()
    {
        $categories = Category::withCount('products')->orderBy('name')->get();

        return CategoryResource::collection($categories);
    }

    // GET /api/categories/{category}
    public function show(Category $category)
    {
        return new CategoryResource($category->loadCount('products'));
    }

    // POST /api/admin/categories
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', 'unique:categories,slug'],
            'image' => ['nullable', 'image', 'max:4096'],
        ]);

        unset($data['image']);
        if ($request->hasFile('image')) {
            $data['image_url'] = url('storage/'.$request->file('image')->store('categories', 'public'));
        }

        return new CategoryResource(Category::create($data));
    }

    // PUT /api/admin/categories/{category}
    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'slug' => ['sometimes', 'string', 'max:255', 'unique:categories,slug,'.$category->id],
            'image' => ['nullable', 'image', 'max:4096'],
        ]);

        unset($data['image']);
        if ($request->hasFile('image')) {
            $data['image_url'] = url('storage/'.$request->file('image')->store('categories', 'public'));
        }

        $category->update($data);

        return new CategoryResource($category);
    }

    // DELETE /api/admin/categories/{category}
    public function destroy(Category $category)
    {
        $category->delete();

        return response()->json(['message' => 'Category deleted.']);
    }
}
