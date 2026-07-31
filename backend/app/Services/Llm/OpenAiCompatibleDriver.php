<?php

namespace App\Services\Llm;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

abstract class OpenAiCompatibleDriver implements LlmDriver
{
    private const MAX_TURNS = 6;

    protected ?string $lastError = null;

    abstract protected function key(): ?string;

    abstract protected function model(): string;

    abstract protected function baseUrl(): string;

    public function lastError(): ?string
    {
        return $this->lastError;
    }

    public function configured(): bool
    {
        return ! empty($this->key());
    }

    public function run(array $messages, array $tools, string $system, callable $runTool): ?string
    {
        $thread = [['role' => 'system', 'content' => $system]];
        foreach ($messages as $m) {
            $thread[] = ['role' => $m['role'], 'content' => $m['content']];
        }

        $functions = array_map(fn ($t) => [
            'type' => 'function',
            'function' => [
                'name' => $t['name'],
                'description' => $t['description'],
                'parameters' => $t['schema'],
            ],
        ], $tools);

        for ($turn = 0; $turn < self::MAX_TURNS; $turn++) {
            $response = $this->call($thread, $functions);
            if ($response === null) {
                return null;
            }

            $message = $response['choices'][0]['message'] ?? [];
            $finish = $response['choices'][0]['finish_reason'] ?? 'stop';
            $thread[] = $message;

            $toolCalls = $message['tool_calls'] ?? [];
            if ($finish !== 'tool_calls' || empty($toolCalls)) {
                return trim($message['content'] ?? '');
            }

            foreach ($toolCalls as $call) {
                $args = json_decode($call['function']['arguments'] ?? '{}', true) ?: [];
                $result = $runTool($call['function']['name'], $args);
                $thread[] = [
                    'role' => 'tool',
                    'tool_call_id' => $call['id'],
                    'content' => json_encode($result),
                ];
            }
        }

        return null;
    }

    private function call(array $messages, array $tools): ?array
    {
        try {
            $response = Http::withToken($this->key())
                ->timeout(60)
                ->post(
                    rtrim($this->baseUrl(), '/').'/v1/chat/completions',
                    [
                        'model' => $this->model(),
                        'max_tokens' => 1024,
                        'messages' => $messages,
                        'tools' => $tools,
                        'tool_choice' => 'auto',
                    ]
                );

            if ($response->successful()) {
                return $response->json();
            }

            $this->lastError = 'HTTP '.$response->status().': '.substr($response->body(), 0, 300);
            Log::warning('Genie '.class_basename(static::class).' error: '.$this->lastError);

            return null;
        } catch (\Throwable $e) {
            $this->lastError = $e->getMessage();
            Log::warning('Genie '.class_basename(static::class).' exception: '.$this->lastError);

            return null;
        }
    }
}
