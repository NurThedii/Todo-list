<?php

namespace App\Http\Controllers;

use App\Models\Todo;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class TodoController extends Controller
{
    public function index()
    {
        return response()->json(Todo::with(['category', 'label'])->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required',
            'category_id' => 'required|exists:categories,id',
            'label_id' => 'required|exists:categories,id',
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
        $request->validate([
            'title' => 'required',
            'category_id' => 'required|exists:categories,id',
            'label_id' => 'required|exists:categories,id',
            'status' => 'required|in:rendah,sedang,tinggi',
            'deadline' => 'required',
        ]);

        $todo->update($request->all());
        return response()->json($todo);
    }

    public function destroy(Todo $todo)
    {
        $todo->delete();
        return response()->json(['message' => 'Todo deleted']);
    }
}
