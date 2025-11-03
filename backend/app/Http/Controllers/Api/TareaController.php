<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tarea;
use App\Models\TipoTarea;
use App\Models\EstadoTarea;
use App\Models\Usuario;
use Illuminate\Http\Request;

class TareaController extends Controller
{
    public function index(Request $request)
    {
        $query = Tarea::with(['tipo', 'estado', 'creador', 'detalles.producto', 'usuarios']);

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where('descripcion', 'like', "%{$search}%");
        }

        if ($request->filled('tipo')) {
            // Validar que tipo sea un número (ID de tipo_tarea)
            // Si viene un string como 'picking' o 'packing', ignorarlo
            $tipo = $request->tipo;
            if (is_numeric($tipo)) {
                $query->where('tipo_tarea_id', (int)$tipo);
            } else {
                // Si viene un código, buscar por código del tipo
                $query->whereHas('tipo', function($q) use ($tipo) {
                    $q->where('codigo', $tipo);
                });
            }
        }

        if ($request->filled('estado')) {
            $query->where('estado_tarea_id', $request->estado);
        }

        if ($request->filled('prioridad')) {
            $query->where('prioridad', $request->prioridad);
        }

        if ($request->filled('desde')) {
            $query->whereDate('fecha_creacion', '>=', $request->desde);
        }

        if ($request->filled('hasta')) {
            $query->whereDate('fecha_creacion', '<=', $request->hasta);
        }

        if ($request->boolean('vencidas')) {
            $query->vencidas();
        }

        $tareas = $query->orderBy('fecha_creacion', 'desc')->get();

        return response()->json([
            'data' => $tareas
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'tipo_tarea_id' => 'required|exists:tipos_tarea,id_tipo_tarea',
            'prioridad' => 'required|string|in:Alta,Media,Baja',
            'descripcion' => 'required|string',
            'asignado_a' => 'nullable|exists:usuarios,id_usuario',
            'fecha_vencimiento' => 'nullable|date|after:today',
        ]);

        $tarea = Tarea::create([
            'tipo_tarea_id' => $request->tipo_tarea_id,
            'estado_tarea_id' => EstadoTarea::where('codigo', 'NUEVA')->first()->id_estado_tarea,
            'prioridad' => $request->prioridad,
            'descripcion' => $request->descripcion,
            'creado_por' => auth()->id(),
            'fecha_creacion' => now(),
            'fecha_vencimiento' => $request->fecha_vencimiento,
        ]);

        // Asignar usuario si se especifica
        if ($request->filled('asignado_a')) {
            $tarea->usuarios()->attach($request->asignado_a, [
                'es_responsable' => true,
                'asignado_desde' => now()
            ]);
        }

        return response()->json([
            'data' => $tarea->load(['tipo', 'estado', 'creador']),
            'message' => 'Tarea creada exitosamente'
        ], 201);
    }

    public function show(Tarea $tarea)
    {
        return response()->json([
            'data' => $tarea->load(['tipo', 'estado', 'creador', 'detalles.producto', 'usuarios'])
        ]);
    }

    public function update(Request $request, Tarea $tarea)
    {
        $request->validate([
            'tipo_tarea_id' => 'sometimes|required|exists:tipos_tarea,id_tipo_tarea',
            'estado_tarea_id' => 'sometimes|required|exists:estados_tarea,id_estado_tarea',
            'prioridad' => 'sometimes|required|string|in:Alta,Media,Baja',
            'descripcion' => 'sometimes|required|string',
            'asignado_a' => 'nullable|exists:usuarios,id_usuario',
            'fecha_vencimiento' => 'nullable|date',
        ]);

        // Actualizar datos básicos de la tarea
        $tarea->update($request->only(['tipo_tarea_id', 'estado_tarea_id', 'prioridad', 'descripcion', 'fecha_vencimiento']));

        // Manejar asignación de usuario
        if ($request->has('asignado_a')) {
            if ($request->asignado_a) {
                // Asignar usuario
                $tarea->usuarios()->sync([
                    $request->asignado_a => [
                        'es_responsable' => true,
                        'asignado_desde' => now()
                    ]
                ]);
            } else {
                // Desasignar todos los usuarios
                $tarea->usuarios()->detach();
            }
        }

        return response()->json([
            'data' => $tarea->load(['tipo', 'estado', 'creador', 'usuarios']),
            'message' => 'Tarea actualizada exitosamente'
        ]);
    }

    public function destroy(Tarea $tarea)
    {
        $tarea->delete();

        return response()->json([
            'message' => 'Tarea eliminada exitosamente'
        ]);
    }

    public function asignar(Request $request, Tarea $tarea)
    {
        $request->validate([
            'usuario_id' => 'required|exists:usuarios,id_usuario',
            'es_responsable' => 'boolean',
        ]);

        $tarea->usuarios()->syncWithoutDetaching([
            $request->usuario_id => [
                'es_responsable' => $request->boolean('es_responsable'),
                'asignado_desde' => now()
            ]
        ]);

        return response()->json([
            'data' => $tarea->load('usuarios'),
            'message' => 'Usuario asignado exitosamente'
        ]);
    }

    public function cambiarEstado(Request $request, Tarea $tarea)
    {
        $request->validate([
            'estado' => 'required|string|exists:estados_tarea,codigo',
        ]);

        $estado = EstadoTarea::where('codigo', $request->estado)->first();
        $tarea->update(['estado_tarea_id' => $estado->id_estado_tarea]);

        if ($request->estado === 'COMPLETADA') {
            $tarea->update(['fecha_cierre' => now()]);
        }

        return response()->json([
            'data' => $tarea->load(['tipo', 'estado', 'creador']),
            'message' => 'Estado de tarea actualizado exitosamente'
        ]);
    }

    public function catalogos()
    {
        $tipos = TipoTarea::all();
        $estados = EstadoTarea::all();
        $prioridades = [
            ['codigo' => 'Alta', 'nombre' => 'Alta'],
            ['codigo' => 'Media', 'nombre' => 'Media'],
            ['codigo' => 'Baja', 'nombre' => 'Baja'],
        ];
        $usuarios = Usuario::where('activo', true)->get(['id_usuario', 'nombre', 'usuario']);

        return response()->json([
            'tipos' => $tipos,
            'estados' => $estados,
            'prioridades' => $prioridades,
            'usuarios' => $usuarios
        ]);
    }
}