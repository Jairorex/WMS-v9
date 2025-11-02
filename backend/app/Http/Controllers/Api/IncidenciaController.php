<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Incidencia;
use App\Models\Usuario;
use App\Models\Producto;
use App\Models\Tarea;
use Illuminate\Http\Request;

class IncidenciaController extends Controller
{
    public function index(Request $request)
    {
        $query = Incidencia::with(['operario', 'producto', 'tarea']);

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where('descripcion', 'like', "%{$search}%");
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('operario')) {
            $query->where('id_operario', $request->operario);
        }

        if ($request->filled('producto')) {
            $query->where('id_producto', $request->producto);
        }

        if ($request->filled('desde')) {
            $query->whereDate('fecha_reporte', '>=', $request->desde);
        }

        if ($request->filled('hasta')) {
            $query->whereDate('fecha_reporte', '<=', $request->hasta);
        }

        if ($request->boolean('pendientes')) {
            $query->pendientes();
        }

        $incidencias = $query->orderBy('fecha_reporte', 'desc')->get();

        return response()->json([
            'data' => $incidencias
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_tarea' => 'nullable|exists:tareas,id_tarea',
            'id_operario' => 'required|exists:usuarios,id_usuario',
            'id_producto' => 'required|exists:productos,id_producto',
            'descripcion' => 'required|string',
            'estado' => 'string|in:Pendiente,Resuelta',
        ]);

        $incidencia = Incidencia::create([
            'id_tarea' => $request->id_tarea,
            'id_operario' => $request->id_operario,
            'id_producto' => $request->id_producto,
            'descripcion' => $request->descripcion,
            'estado' => $request->estado ?? 'Pendiente',
            'fecha_reporte' => now(),
        ]);

        return response()->json([
            'data' => $incidencia->load(['operario', 'producto', 'tarea']),
            'message' => 'Incidencia creada exitosamente'
        ], 201);
    }

    public function show(Incidencia $incidencia)
    {
        return response()->json([
            'data' => $incidencia->load(['operario', 'producto', 'tarea'])
        ]);
    }

    public function update(Request $request, Incidencia $incidencia)
    {
        $request->validate([
            'id_tarea' => 'nullable|exists:tareas,id_tarea',
            'id_operario' => 'sometimes|required|exists:usuarios,id_usuario',
            'id_producto' => 'sometimes|required|exists:productos,id_producto',
            'descripcion' => 'sometimes|required|string',
            'estado' => 'sometimes|required|string|in:Pendiente,Resuelta',
        ]);

        $incidencia->update($request->all());

        return response()->json([
            'data' => $incidencia->load(['operario', 'producto', 'tarea']),
            'message' => 'Incidencia actualizada exitosamente'
        ]);
    }

    public function destroy(Incidencia $incidencia)
    {
        $incidencia->delete();

        return response()->json([
            'message' => 'Incidencia eliminada exitosamente'
        ]);
    }

    public function resolver(Incidencia $incidencia)
    {
        $incidencia->update([
            'estado' => 'Resuelta',
            'fecha_resolucion' => now()
        ]);

        return response()->json([
            'data' => $incidencia->load(['operario', 'producto', 'tarea']),
            'message' => 'Incidencia resuelta exitosamente'
        ]);
    }

    public function reabrir(Incidencia $incidencia)
    {
        $incidencia->update([
            'estado' => 'Pendiente',
            'fecha_resolucion' => null
        ]);

        return response()->json([
            'data' => $incidencia->load(['operario', 'producto', 'tarea']),
            'message' => 'Incidencia reabierta exitosamente'
        ]);
    }

    public function catalogos()
    {
        $estados = [
            ['codigo' => 'Pendiente', 'nombre' => 'Pendiente'],
            ['codigo' => 'Resuelta', 'nombre' => 'Resuelta'],
        ];

        $operarios = Usuario::where('activo', true)
                           ->whereHas('rol', function($q) {
                               $q->whereIn('nombre', ['Operario', 'Supervisor']);
                           })
                           ->get(['id_usuario', 'nombre']);

        $productos = Producto::with('estado')->get(['id_producto', 'nombre']);

        $tareas = Tarea::whereHas('estado', function($q) {
            $q->whereNotIn('codigo', ['COMPLETADA', 'CANCELADA']);
        })->get(['id_tarea', 'descripcion']);

        return response()->json([
            'estados' => $estados,
            'operarios' => $operarios,
            'productos' => $productos,
            'tareas' => $tareas
        ]);
    }
}