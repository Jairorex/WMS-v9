<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use App\Models\Tarea;
use App\Models\TareaLog;
use App\Models\TipoTarea;
use App\Models\EstadoTarea;
use App\Models\Usuario;
use Illuminate\Http\Request;

class TareaController extends Controller
{
    use ApiResponse;
    public function index(Request $request)
    {
        $query = Tarea::with(['tipo', 'estado', 'creador', 'detalles.producto', 'usuarios']);

        // Búsqueda general
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('descripcion', 'like', "%{$search}%")
                  ->orWhere('id_tarea', 'like', "%{$search}%");
            });
        }

        // Filtro por tipo (acepta ID numérico o código string como 'picking', 'packing')
        if ($request->filled('tipo')) {
            $query->porTipo($request->tipo);
        }

        // Filtro por estado (acepta ID numérico o código string)
        if ($request->filled('estado')) {
            if (is_numeric($request->estado)) {
                $query->where('estado_tarea_id', (int)$request->estado);
            } else {
                $query->porEstado($request->estado);
            }
        }

        // Filtro por prioridad
        if ($request->filled('prioridad')) {
            $query->porPrioridad($request->prioridad);
        }

        // Filtro por usuario asignado
        if ($request->filled('usuario_asignado')) {
            $query->porUsuarioAsignado($request->usuario_asignado);
        }

        // Filtro por zona (a través de ubicaciones)
        if ($request->filled('zona')) {
            $query->porZona($request->zona);
        }

        // Filtros de fecha
        if ($request->filled('fecha_inicio')) {
            $query->porFechaInicio($request->fecha_inicio);
        }

        if ($request->filled('fecha_fin')) {
            $query->porFechaFin($request->fecha_fin);
        }

        // También soportar 'desde' y 'hasta' para compatibilidad
        if ($request->filled('desde')) {
            $query->porFechaInicio($request->desde);
        }

        if ($request->filled('hasta')) {
            $query->porFechaFin($request->hasta);
        }

        // Filtro de tareas vencidas
        if ($request->boolean('vencidas')) {
            $query->vencidas();
        }

        // Ordenamiento
        $orderBy = $request->get('order_by', 'fecha_creacion');
        $orderDir = $request->get('order_dir', 'desc');
        $query->orderBy($orderBy, $orderDir);

        // Paginación
        $perPage = $request->get('per_page', 15);
        
        if ($request->get('paginate', true)) {
            $tareas = $query->paginate($perPage);
            return $this->paginatedResponse($tareas, 'Tareas obtenidas exitosamente');
        } else {
            $tareas = $query->get();
            return $this->successResponse($tareas, 'Tareas obtenidas exitosamente');
        }
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

        return $this->successResponse(
            $tarea->load(['tipo', 'estado', 'creador']),
            'Tarea creada exitosamente',
            201
        );
    }

    public function show(Tarea $tarea)
    {
        return $this->successResponse(
            $tarea->load(['tipo', 'estado', 'creador', 'detalles.producto', 'usuarios']),
            'Tarea obtenida exitosamente'
        );
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

        return $this->successResponse(
            $tarea->load(['tipo', 'estado', 'creador', 'usuarios']),
            'Tarea actualizada exitosamente'
        );
    }

    public function destroy(Tarea $tarea)
    {
        $tarea->delete();

        return $this->successResponse(null, 'Tarea eliminada exitosamente');
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

        return $this->successResponse(
            $tarea->load('usuarios'),
            'Usuario asignado exitosamente'
        );
    }

    public function cambiarEstado(Request $request, Tarea $tarea)
    {
        $request->validate([
            'estado' => 'required|string|exists:estados_tarea,codigo',
            'comentarios' => 'nullable|string',
        ]);

        $estadoAnterior = $tarea->estado ? $tarea->estado->codigo : null;
        $estado = EstadoTarea::where('codigo', $request->estado)->first();
        
        $tarea->update(['estado_tarea_id' => $estado->id_estado_tarea]);

        if ($request->estado === 'COMPLETADA') {
            $tarea->update(['fecha_cierre' => now()]);
        }

        // Registrar en log
        try {
            TareaLog::create([
                'id_tarea' => $tarea->id_tarea,
                'usuario_id' => auth()->id(),
                'estado_anterior' => $estadoAnterior,
                'estado_nuevo' => $request->estado,
                'accion' => 'cambiar_estado',
                'dispositivo' => $request->header('User-Agent'),
                'ip_address' => $request->ip(),
                'comentarios' => $request->comentarios,
            ]);
        } catch (\Exception $e) {
            // Si la tabla no existe aún, solo loguear el error pero no fallar
            \Log::warning('No se pudo registrar log de tarea: ' . $e->getMessage());
        }

        return $this->successResponse(
            $tarea->load(['tipo', 'estado', 'creador']),
            'Estado de tarea actualizado exitosamente'
        );
    }

    /**
     * Completar tarea (alias de cambiarEstado con estado COMPLETADA)
     */
    public function completar(Request $request, Tarea $tarea)
    {
        $request->merge(['estado' => 'COMPLETADA']);
        return $this->cambiarEstado($request, $tarea);
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

        return $this->successResponse([
            'tipos' => $tipos,
            'estados' => $estados,
            'prioridades' => $prioridades,
            'usuarios' => $usuarios
        ], 'Catálogos obtenidos exitosamente');
    }
}