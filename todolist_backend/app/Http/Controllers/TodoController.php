<?php

namespace App\Http\Controllers;

use App\Models\Todo;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class TodoController extends Controller
{
    public function index()
    {
        $todos = Todo::with(['category', 'label'])
            ->orderByRaw("
                CASE
                    WHEN status = 'tinggi' THEN 1
                    WHEN status = 'sedang' THEN 2
                    WHEN status = 'rendah' THEN 3
                END
            ")->get();

        return response()->json($todos);
    }


    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required',
            'category_id' => 'required|exists:categories,id',
            'label_id' => 'required|exists:labels,id',
            'status' => 'required|in:rendah,sedang,tinggi',
            'deadline' => 'required',
        ]);

        $todo = Todo::create($request->all());
        return response()->json($todo, 201);
    }

    public function show(Todo $todo)
    {
        return response()->json($todo->load('category'));
    }

    public function update(Request $request, Todo $todo)
    {
        $todo->update($request->only(['title', 'description', 'category_id', 'label_id', 'status', 'deadline']));

        return response()->json([
            'message' => 'Todo berhasil diperbarui',
            'data' => $todo
        ], 200);
    }

    public function destroy(Todo $todo)
    {
        $todo->delete();
        return response()->json(['message' => 'Todo deleted']);
    }
}
