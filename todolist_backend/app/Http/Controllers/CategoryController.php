<?php

namespace App\Http\Controllers;

use App\Models\Categorie;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index()
    {
        return response()->json(Categorie::all());
    }

    public function store(Request $request)
    {
        $request->validate(['title' => 'required']);
        $Categorie = Categorie::create($request->all());
        return response()->json($Categorie, 201);
    }

    public function show(Categorie $Categorie)
    {
        return response()->json($Categorie);
    }

    public function update(Request $request, $id)
    {
        $Categorie = Categorie::findOrFail($id);


        // Update hanya jika data valid
        $Categorie->update([
            'title' => $request->title,
        ]);
        // Return response JSON dengan data yang telah diperbarui
        return response()->json([
            'success' => true,
            'message' => 'Categorie updated successfully',
            'data' => $Categorie,
        ], 200);
    }
    public function destroy(Categorie $Categorie)
    {
        $Categorie->delete();
        return response()->json(['message' => 'Categorie deleted']);
    }
}
