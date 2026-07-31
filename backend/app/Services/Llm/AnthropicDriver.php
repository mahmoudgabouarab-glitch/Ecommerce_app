<?php

namespace App\Services\Llm;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AnthropicDriver implements LlmDriver
{
    private const MAX_TURNS = 6;

    private ?string $lastError = null;

    public function lastError(): ?string
    {
        return $this->lastError;
    }

    public function configured(): bool
    {
        return ! empty(config('services.anthropic.key'));
    }

    public function run(array $messages, array $tools, string $system, callable $runTool): ?string
    {
        $thread = array_map(fn ($m) => [
            'role' => $m['role'],
            'content' => $m['content'],
        ], $messages);

        $toolDefs = array_map(fn ($t) => [
            'name' => $t['name'],
            'description' => $t['description'],
            'input_schema' => $t['schema'],
        ], $tools);

        for ($turn = 0; $turn < self::MAX_TURNS; $turn++) {
            $response = $this->call($thread, $toolDefs, $system);
            if ($response === null) {
                return null;
            }

            $content = $response['content'] ?? [];
            $thread[] = ['role' => 'assistant', 'content' => $content];

            if (($response['stop_reason'] ?? null) !== 'tool_use') {
                return $this->text($content);
            }

            $results = [];
            foreach ($content as $block) {
                if (($block['type'] ?? null) !== 'tool_use') {
                    continue;
                }
                $results[] = [
                    'type' => 'tool_result',
                    'tool_use_id' => $block['id'],
                    'content' => json_encode($runTool($block['name'], $block['input'] ?? [])),
                ];
            }
            $thread[] = ['role' => 'user', 'content' => $results];
        }

        return null;
    }

    private function text(array $content): string
    {
        foreach ($content as $block) {
            if (($block['type'] ?? null) === 'text') {
                return trim($block['text']);
            }
        }

        return '';
    }

    private function call(array $messages, array $tools, string $system): ?array
    {
        try {
            $response = Http::withHeaders([
                'x-api-key' => config('services.anthropic.key'),
                'anthropic-version' => '2023-06-01',
                'content-type' => 'application/json',
            ])->timeout(60)->post(
                rtrim(config('services.anthropic.base_url'), '/').'/v1/messages',
                [
                    'model' => config('services.anthropic.model'),
                    'max_tokens' => 1024,
                    'system' => $system,
                    'tools' => $tools,
                    'messages' => $messages,
                ]
            );

            if ($response->successful()) {
                return $response->json();
            }

            $this->lastError = 'HTTP '.$response->status().': '.substr($response->body(), 0, 300);
            Log::warning('Genie Anthropic error: '.$this->lastError);

            return null;
        } catch (\Throwable $e) {
            $this->lastError = $e->getMessage();
            Log::warning('Genie Anthropic exception: '.$this->lastError);

            return null;
        }
    }
}
