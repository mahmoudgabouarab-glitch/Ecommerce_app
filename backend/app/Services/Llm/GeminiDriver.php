<?php

namespace App\Services\Llm;

class GeminiDriver extends OpenAiCompatibleDriver
{
    protected function key(): ?string
    {
        return config('services.gemini.key');
    }

    protected function model(): string
    {
        return config('services.gemini.model');
    }

    protected function baseUrl(): string
    {
        return config('services.gemini.base_url');
    }
}
