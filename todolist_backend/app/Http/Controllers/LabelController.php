<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Label;
use Illuminate\Http\Request;

class LabelController extends Controller
{
    public function index()
    {
        try {
            $labels = Label::all(); // Pastikan tabel "labels" ada di database
            return response()->json($labels, 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Server Error: ' . $e->getMessage()], 500);
        }
    }


    public function store(Request $request)
    {
        $request->validate(['title' => 'required']);
        $label = Label::create($request->all());
        return response()->json($label, 201);
    }

    public function show(label $label)
    {
        return response()->json($label);
    }

    public function update(Request $request, $id)
    {
        $label = Label::findOrFail($id);

        $validatedData = $request->validate([
            'title' => 'required|string|max:255|unique:labels,title,' . $id,
        ]);

        // Update hanya jika data valid
        $label->update($validatedData);

        // Return response JSON dengan data yang telah diperbarui
        return response()->json([
            'success' => true,
            'message' => 'Label updated successfully',
            'data' => $label,
        ], 200);
    }


    public function destroy(label $label)
    {
        $label->delete();
        return response()->json(['message' => 'label deleted']);
    }
}
