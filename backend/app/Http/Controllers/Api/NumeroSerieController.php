<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\NumeroSerie;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class NumeroSerieController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = NumeroSerie::with(['producto', 'ubicacion', 'usuario']);

        // Filtros
        if ($request->filled('producto_id')) {
            $query->where('producto_id', $request->producto_id);
        }

        if ($request->filled('ubicacion_id')) {
            $query->where('ubicacion_id', $request->ubicacion_id);
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('numero_serie')) {
            $query->where('numero_serie', 'like', '%' . $request->numero_serie . '%');
        }

        $numeroSerie = $query->paginate($request->get('per_page', 15));

        return response()->json($numeroSerie);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'producto_id' => 'required|exists:productos,id',
            'ubicacion_id' => 'required|exists:ubicaciones,id',
            'numero_serie' => 'required|string|max:100|unique:numeros_serie,numero_serie',
            'estado' => 'required|in:disponible,reservado,en_uso,defectuoso,perdido',
            'fecha_fabricacion' => 'nullable|date',
            'fecha_garantia' => 'nullable|date',
            'observaciones' => 'nullable|string|max:500',
        ]);

        $validated['usuario_id'] = auth()->id();

        $numeroSerie = NumeroSerie::create($validated);

        return response()->json($numeroSerie->load(['producto', 'ubicacion', 'usuario']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(NumeroSerie $numeroSerie): JsonResponse
    {
        return response()->json($numeroSerie->load(['producto', 'ubicacion', 'usuario']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, NumeroSerie $numeroSerie): JsonResponse
    {
        $validated = $request->validate([
            'producto_id' => 'sometimes|exists:productos,id',
            'ubicacion_id' => 'sometimes|exists:ubicaciones,id',
            'numero_serie' => 'sometimes|string|max:100|unique:numeros_serie,numero_serie,' . $numeroSerie->id,
            'estado' => 'sometimes|in:disponible,reservado,en_uso,defectuoso,perdido',
            'fecha_fabricacion' => 'nullable|date',
            'fecha_garantia' => 'nullable|date',
            'observaciones' => 'nullable|string|max:500',
        ]);

        $numeroSerie->update($validated);

        return response()->json($numeroSerie->load(['producto', 'ubicacion', 'usuario']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(NumeroSerie $numeroSerie): JsonResponse
    {
        $numeroSerie->delete();

        return response()->json(null, 204);
    }

    /**
     * Cambiar estado del número de serie
     */
    public function cambiarEstado(Request $request, NumeroSerie $numeroSerie): JsonResponse
    {
        $validated = $request->validate([
            'estado' => 'required|in:disponible,reservado,en_uso,defectuoso,perdido',
            'observaciones' => 'nullable|string|max:500',
        ]);

        $numeroSerie->update([
            'estado' => $validated['estado'],
            'observaciones' => $validated['observaciones'] ?? $numeroSerie->observaciones,
        ]);

        return response()->json($numeroSerie->load(['producto', 'ubicacion', 'usuario']));
    }

    /**
     * Mover número de serie a otra ubicación
     */
    public function mover(Request $request, NumeroSerie $numeroSerie): JsonResponse
    {
        $validated = $request->validate([
            'ubicacion_id' => 'required|exists:ubicaciones,id',
            'observaciones' => 'nullable|string|max:500',
        ]);

        $numeroSerie->update([
            'ubicacion_id' => $validated['ubicacion_id'],
            'observaciones' => $validated['observaciones'] ?? $numeroSerie->observaciones,
        ]);

        return response()->json($numeroSerie->load(['producto', 'ubicacion', 'usuario']));
    }

    /**
     * Buscar número de serie por número
     */
    public function buscar(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'numero_serie' => 'required|string',
        ]);

        $numeroSerie = NumeroSerie::with(['producto', 'ubicacion', 'usuario'])
            ->where('numero_serie', $validated['numero_serie'])
            ->first();

        if (!$numeroSerie) {
            return response()->json(['message' => 'Número de serie no encontrado'], 404);
        }

        return response()->json($numeroSerie);
    }

    /**
     * Obtener estadísticas de números de serie
     */
    public function estadisticas(): JsonResponse
    {
        $estadisticas = [
            'total' => NumeroSerie::count(),
            'por_estado' => NumeroSerie::selectRaw('estado, COUNT(*) as cantidad')
                ->groupBy('estado')
                ->get(),
            'por_producto' => NumeroSerie::with('producto')
                ->selectRaw('producto_id, COUNT(*) as cantidad')
                ->groupBy('producto_id')
                ->get(),
            'por_ubicacion' => NumeroSerie::with('ubicacion')
                ->selectRaw('ubicacion_id, COUNT(*) as cantidad')
                ->groupBy('ubicacion_id')
                ->get(),
        ];

        return response()->json($estadisticas);
    }
}
