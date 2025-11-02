<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Rol;
use Illuminate\Http\Request;

class RolController extends Controller
{
    public function index()
    {
        $roles = Rol::orderBy('nombre')->get();

        return response()->json($roles);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:100|unique:roles,nombre',
            'descripcion' => 'nullable|string|max:255',
        ]);

        $rol = Rol::create([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
        ]);

        return response()->json([
            'data' => $rol,
            'message' => 'Rol creado exitosamente'
        ], 201);
    }

    public function show(Rol $rol)
    {
        return response()->json([
            'data' => $rol
        ]);
    }

    public function update(Request $request, Rol $rol)
    {
        $request->validate([
            'nombre' => 'required|string|max:100|unique:roles,nombre,' . $rol->id_rol . ',id_rol',
            'descripcion' => 'nullable|string|max:255',
        ]);

        $rol->update([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
        ]);

        return response()->json([
            'data' => $rol,
            'message' => 'Rol actualizado exitosamente'
        ]);
    }

    public function destroy(Rol $rol)
    {
        $rol->delete();

        return response()->json([
            'message' => 'Rol eliminado exitosamente'
        ]);
    }
}
