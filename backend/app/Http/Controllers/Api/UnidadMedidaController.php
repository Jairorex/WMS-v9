<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UnidadMedida;
use Illuminate\Http\Request;

class UnidadMedidaController extends Controller
{
    public function index(Request $request)
    {
        $query = UnidadMedida::query();

        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('codigo', 'like', "%{$search}%")
                  ->orWhere('nombre', 'like', "%{$search}%");
            });
        }

        $unidades = $query->orderBy('nombre')->get();

        return response()->json([
            'data' => $unidades
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'codigo' => 'required|string|max:10|unique:unidad_de_medida,codigo',
            'nombre' => 'required|string|max:50',
        ]);

        $unidad = UnidadMedida::create([
            'codigo' => strtoupper($request->codigo),
            'nombre' => $request->nombre,
        ]);

        return response()->json([
            'data' => $unidad,
            'message' => 'Unidad de medida creada exitosamente'
        ], 201);
    }

    public function show(UnidadMedida $unidadMedida)
    {
        return response()->json([
            'data' => $unidadMedida
        ]);
    }

    public function update(Request $request, UnidadMedida $unidadMedida)
    {
        $request->validate([
            'codigo' => 'sometimes|required|string|max:10|unique:unidad_de_medida,codigo,' . $unidadMedida->id,
            'nombre' => 'sometimes|required|string|max:50',
        ]);

        $unidadMedida->update([
            'codigo' => $request->has('codigo') ? strtoupper($request->codigo) : $unidadMedida->codigo,
            'nombre' => $request->has('nombre') ? $request->nombre : $unidadMedida->nombre,
        ]);

        return response()->json([
            'data' => $unidadMedida,
            'message' => 'Unidad de medida actualizada exitosamente'
        ]);
    }

    public function destroy(UnidadMedida $unidadMedida)
    {
        // Verificar si hay productos usando esta unidad
        if ($unidadMedida->productos()->count() > 0) {
            return response()->json([
                'message' => 'No se puede eliminar la unidad de medida porque está siendo utilizada por productos'
            ], 422);
        }

        $unidadMedida->delete();

        return response()->json([
            'message' => 'Unidad de medida eliminada exitosamente'
        ]);
    }

    public function catalogos()
    {
        $unidades = UnidadMedida::orderBy('nombre')->get(['id', 'codigo', 'nombre']);

        return response()->json($unidades);
    }
}
