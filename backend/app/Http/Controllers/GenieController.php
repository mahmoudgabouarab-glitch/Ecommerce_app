<?php

namespace App\Http\Controllers;

use App\Services\Genie;
use Illuminate\Http\Request;

class GenieController extends Controller
{
    public function chat(Request $request, Genie $genie)
    {
        $data = $request->validate([
            'messages' => ['required', 'array', 'min:1', 'max:40'],
            'messages.*.role' => ['required', 'in:user,assistant'],
            'messages.*.content' => ['required', 'string', 'max:4000'],
        ]);

        $messages = array_map(fn ($m) => [
            'role' => $m['role'],
            'content' => $m['content'],
        ], $data['messages']);

        $result = $genie->chat($request->user(), $messages);

        return response()->json($result);
    }
}
