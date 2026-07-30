<?php

namespace App\Support;

use Cloudinary\Cloudinary;
use Illuminate\Http\UploadedFile;

class ImageUploader
{
    public static function upload(UploadedFile $file, string $folder): string
    {
        $result = self::client()->uploadApi()->upload(
            $file->getRealPath(),
            ['folder' => 'bazar/'.$folder]
        );

        return (string) $result['secure_url'];
    }

    public static function delete(?string $url): void
    {
        $publicId = self::publicIdFromUrl($url);

        if ($publicId !== null) {
            self::client()->uploadApi()->destroy($publicId);
        }
    }

    private static function client(): Cloudinary
    {
        return new Cloudinary(config('services.cloudinary.url'));
    }

    private static function publicIdFromUrl(?string $url): ?string
    {
        if (! $url || ! str_contains($url, 'res.cloudinary.com')) {
            return null;
        }

        $path = parse_url($url, PHP_URL_PATH);
        if (! $path) {
            return null;
        }

        $parts = explode('/upload/', $path, 2);
        if (count($parts) < 2) {
            return null;
        }

        $withoutVersion = preg_replace('#^v\d+/#', '', $parts[1]);

        return preg_replace('#\.[^./]+$#', '', $withoutVersion);
    }
}
