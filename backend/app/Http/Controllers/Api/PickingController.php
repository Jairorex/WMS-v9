<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Picking;
use App\Models\OrdenSalida;
use App\Models\Usuario;
use Illuminate\Http\Request;

class PickingController extends Controller
{
    public function index(Request $request)
    {
        $query = Picking::with(['orden', 'asignadoA']);

        // Filtros
        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('asignado_a')) {
            $query->where('asignado_a', $request->asignado_a);
        }

        if ($request->filled('desde')) {
            $query->whereDate('created_at', '>=', $request->desde);
        }

        if ($request->filled('hasta')) {
            $query->whereDate('created_at', '<=', $request->hasta);
        }

        $pickings = $query->orderBy('created_at', 'desc')->get();

        // Transformar datos para el frontend
        $pickingsTransformados = $pickings->map(function($picking) {
            return [
                'id_picking' => $picking->id_picking,
                'id_orden' => $picking->id_orden,
                'estado' => $picking->estado,
                'asignado_a' => $picking->asignado_a,
                'creado_por' => 1, // Por ahora siempre 1
                'ts_asignado' => $picking->fecha_inicio,
                'ts_cierre' => $picking->fecha_fin,
                'orden' => [
                    'id_orden' => $picking->orden->id_orden,
                    'cliente' => $picking->orden->cliente,
                    'fecha_compromiso' => $picking->orden->fecha_entrega,
                ],
                'asignadoA' => [
                    'id_usuario' => $picking->asignadoA->id_usuario ?? null,
                    'nombre' => $picking->asignadoA->nombre ?? 'Sin asignar',
                ],
            ];
        });

        return response()->json([
            'data' => $pickingsTransformados
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_orden' => 'required|exists:orden_salida,id_orden',
            'asignado_a' => 'nullable|exists:usuarios,id_usuario',
        ]);

        $picking = Picking::create([
            'id_orden' => $request->id_orden,
            'estado' => 'Pendiente',
            'asignado_a' => $request->asignado_a,
            'fecha_inicio' => $request->asignado_a ? now() : null,
        ]);

        return response()->json([
            'data' => $picking->load(['orden', 'asignadoA']),
            'message' => 'Picking creado exitosamente'
        ], 201);
    }

    public function show(Picking $picking)
    {
        return response()->json([
            'data' => $picking->load(['orden', 'asignadoA', 'detalles.producto', 'detalles.ubicacion'])
        ]);
    }

    public function update(Request $request, Picking $picking)
    {
        $request->validate([
            'estado' => 'sometimes|required|string|in:Pendiente,En Proceso,Completado,Cancelado',
            'asignado_a' => 'nullable|exists:usuarios,id_usuario',
        ]);

        $picking->update($request->all());

        return response()->json([
            'data' => $picking->load(['orden', 'asignadoA']),
            'message' => 'Picking actualizado exitosamente'
        ]);
    }

    public function destroy(Picking $picking)
    {
        $picking->delete();

        return response()->json([
            'message' => 'Picking eliminado exitosamente'
        ]);
    }

    public function asignar(Request $request, Picking $picking)
    {
        $request->validate([
            'usuario_id' => 'required|exists:usuarios,id_usuario',
        ]);

        $picking->update([
            'asignado_a' => $request->usuario_id,
            'estado' => 'En Proceso',
            'fecha_inicio' => now(),
        ]);

        return response()->json([
            'data' => $picking->load(['orden', 'asignadoA']),
            'message' => 'Picking asignado exitosamente'
        ]);
    }

    public function completar(Picking $picking)
    {
        $picking->update([
            'estado' => 'Completado',
            'fecha_fin' => now(),
        ]);

        return response()->json([
            'data' => $picking->load(['orden', 'asignadoA']),
            'message' => 'Picking completado exitosamente'
        ]);
    }

    public function cancelar(Picking $picking)
    {
        $picking->update([
            'estado' => 'Cancelado',
            'fecha_fin' => now(),
        ]);

        return response()->json([
            'data' => $picking->load(['orden', 'asignadoA']),
            'message' => 'Picking cancelado exitosamente'
        ]);
    }
}