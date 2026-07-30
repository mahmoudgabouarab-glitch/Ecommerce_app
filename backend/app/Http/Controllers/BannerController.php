<?php

namespace App\Http\Controllers;

use App\Http\Resources\BannerResource;
use App\Models\Banner;
use App\Support\ImageUploader;
use Illuminate\Http\Request;

class BannerController extends Controller
{
    public function index()
    {
        $banners = Banner::where('is_active', true)
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get();

        return BannerResource::collection($banners);
    }

    public function adminIndex()
    {
        return BannerResource::collection(
            Banner::orderBy('sort_order')->orderByDesc('id')->get()
        );
    }

    public function store(Request $request)
    {
        $data = $this->validated($request, true);
        $data['image'] = ImageUploader::upload($request->file('image'), 'banners');

        return new BannerResource(Banner::create($data));
    }

    public function update(Request $request, Banner $banner)
    {
        $data = $this->validated($request, false);

        if ($request->hasFile('image')) {
            ImageUploader::delete($banner->image);
            $data['image'] = ImageUploader::upload($request->file('image'), 'banners');
        }

        $banner->update($data);

        return new BannerResource($banner);
    }

    public function destroy(Banner $banner)
    {
        ImageUploader::delete($banner->image);
        $banner->delete();

        return response()->json(['message' => 'Banner deleted.']);
    }

    private function validated(Request $request, bool $imageRequired): array
    {
        return $request->validate([
            'image' => [$imageRequired ? 'required' : 'nullable', 'image', 'max:4096'],
            'title' => ['nullable', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'link_type' => ['nullable', 'in:none,product,category'],
            'link_value' => ['nullable', 'integer'],
            'is_active' => ['nullable', 'boolean'],
            'sort_order' => ['nullable', 'integer'],
        ]);
    }
}
