<?php

namespace App\Services\Llm;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GroqDriver implements LlmDriver
{
    private const MAX_TURNS = 6;

    public function configured(): bool
    {
        return ! empty(config('services.groq.key'));
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
            $response = Http::withToken(config('services.groq.key'))
                ->timeout(60)
                ->post(
                    rtrim(config('services.groq.base_url'), '/').'/v1/chat/completions',
                    [
                        'model' => config('services.groq.model'),
                        'max_tokens' => 1024,
                        'messages' => $messages,
                        'tools' => $tools,
                        'tool_choice' => 'auto',
                    ]
                );

            if ($response->successful()) {
                return $response->json();
            }

            Log::warning('Genie Groq error: HTTP '.$response->status().': '.substr($response->body(), 0, 300));

            return null;
        } catch (\Throwable $e) {
            Log::warning('Genie Groq exception: '.$e->getMessage());

            return null;
        }
    }
}
