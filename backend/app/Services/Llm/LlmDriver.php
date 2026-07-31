<?php

namespace App\Services\Llm;

interface LlmDriver
{
    public function configured(): bool;

    public function run(array $messages, array $tools, string $system, callable $runTool): ?string;

    public function lastError(): ?string;
}
