<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OrdenSalida;
use App\Models\OrdenSalidaDetalle;
use App\Models\Producto;
use App\Models\Usuario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class OrdenSalidaController extends Controller
{
    public function index(Request $request)
    {
        $query = OrdenSalida::with(['detalles.producto', 'creador']);

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('id_orden', 'like', "%{$search}%")
                  ->orWhere('cliente', 'like', "%{$search}%");
            });
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('prioridad')) {
            $query->where('prioridad', $request->prioridad);
        }

        if ($request->filled('cliente')) {
            $query->where('cliente', 'like', "%{$request->cliente}%");
        }

        if ($request->filled('desde')) {
            $query->whereDate('fecha_creacion', '>=', $request->desde);
        }

        if ($request->filled('hasta')) {
            $query->whereDate('fecha_creacion', '<=', $request->hasta);
        }

        if ($request->boolean('vencidas')) {
            $query->whereDate('fecha_entrega', '<', now());
        }

        $perPage = $request->get('per_page', 15);
        $ordenes = $query->orderBy('fecha_creacion', 'desc')->paginate($perPage);

        // Transformar datos para el frontend
        $ordenesTransformadas = $ordenes->getCollection()->map(function($orden) {
            // Obtener cliente - puede ser del modelo o un atributo
            $cliente = $orden->cliente ?? (method_exists($orden, 'getClienteAttribute') ? $orden->cliente : 'Cliente Genérico');
            
            return [
                'id_orden' => $orden->id_orden,
                'estado' => $orden->estado,
                'prioridad' => $orden->prioridad,
                'cliente' => $cliente,
                'fecha_compromiso' => $orden->fecha_entrega,
                'creado_por' => $orden->creado_por ?? null,
                'creador' => isset($orden->creador) && $orden->creador ? [
                    'nombre' => $orden->creador->nombre,
                ] : null,
                'detalles' => $orden->detalles->map(function($detalle) {
                    return [
                        'id_det' => $detalle->id_det,
                        'id_producto' => $detalle->id_producto,
                        'cant_solicitada' => $detalle->cantidad_solicitada,
                        'cant_comprometida' => $detalle->cantidad_confirmada ?? 0,
                        'cant_pickeada' => 0, // Se calculará desde picking_detalle si existe
                        'lote_preferente' => null, // Si existe en la tabla
                        'producto' => $detalle->producto ? [
                            'nombre' => $detalle->producto->nombre,
                            'codigo_barra' => $detalle->producto->codigo_barra ?? null,
                        ] : null,
                    ];
                }),
                'created_at' => $orden->created_at,
                'updated_at' => $orden->updated_at,
            ];
        });

        return response()->json([
            'data' => $ordenesTransformadas,
            'current_page' => $ordenes->currentPage(),
            'per_page' => $ordenes->perPage(),
            'total' => $ordenes->total(),
            'last_page' => $ordenes->lastPage(),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'cliente' => 'required|string|max:255',
            'fecha_compromiso' => 'required|date',
            'prioridad' => 'required|integer|min:1|max:5',
            'detalles' => 'required|array|min:1',
            'detalles.*.id_producto' => 'required|exists:wms.productos,id_producto',
            'detalles.*.cant_solicitada' => 'required|integer|min:1',
            'detalles.*.lote_preferente' => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            $orden = OrdenSalida::create([
                'estado' => 'CREADA',
                'prioridad' => $request->prioridad,
                'fecha_creacion' => now(),
                'fecha_entrega' => $request->fecha_compromiso,
            ]);
            
            // Si existe el campo cliente en la tabla, actualizarlo
            if (Schema::hasColumn($orden->getTable(), 'cliente')) {
                DB::table($orden->getTable())
                    ->where($orden->getKeyName(), $orden->getKey())
                    ->update(['cliente' => $request->cliente]);
            }
            
            // Si existe el campo creado_por
            if (Schema::hasColumn($orden->getTable(), 'creado_por')) {
                DB::table($orden->getTable())
                    ->where($orden->getKeyName(), $orden->getKey())
                    ->update(['creado_por' => auth()->id() ?? 1]);
            }

            foreach ($request->detalles as $detalle) {
                OrdenSalidaDetalle::create([
                    'id_orden' => $orden->id_orden,
                    'id_producto' => $detalle['id_producto'],
                    'cantidad_solicitada' => $detalle['cant_solicitada'],
                    'cantidad_confirmada' => 0,
                    'cant_pickeada' => 0,
                    'lote_preferente' => $detalle['lote_preferente'] ?? null,
                ]);
            }

            DB::commit();

            return response()->json([
                'data' => $orden->load(['detalles.producto', 'creador']),
                'message' => 'Orden de salida creada exitosamente'
            ], 201);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'message' => 'Error al crear la orden de salida: ' . $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $orden = OrdenSalida::with(['detalles.producto', 'creador', 'pickings'])->findOrFail($id);
        
        // Calcular métricas
        $totalLineas = $orden->detalles->count();
        $lineasCompletas = $orden->detalles->filter(function($detalle) {
            return ($detalle->cant_pickeada ?? 0) >= $detalle->cantidad_solicitada;
        })->count();
        $porcentajeCompletado = $totalLineas > 0 ? ($lineasCompletas / $totalLineas) * 100 : 0;

        $metricas = [
            'total_lineas' => $totalLineas,
            'lineas_completas' => $lineasCompletas,
            'porcentaje_completado' => round($porcentajeCompletado, 2),
            'puede_asignar_picking' => $orden->estado === 'CREADA' || $orden->estado === 'EN_PICKING',
            'total_pickings' => $orden->pickings->count(),
        ];

        return response()->json([
            'orden' => $orden,
            'metricas' => $metricas
        ]);
    }

    public function update(Request $request, $id)
    {
        $orden = OrdenSalida::findOrFail($id);
        
        $request->validate([
            'estado' => 'sometimes|required|string|in:CREADA,EN_PICKING,PICKING_COMPLETO,CANCELADA',
            'prioridad' => 'sometimes|required|integer|min:1|max:5',
            'fecha_compromiso' => 'sometimes|required|date',
            'cliente' => 'sometimes|required|string|max:255',
        ]);

        $data = $request->only(['estado', 'prioridad']);
        
        // Si existe el campo cliente en la tabla
        if ($request->filled('cliente') && (\Schema::hasColumn($orden->getTable(), 'cliente'))) {
            $data['cliente'] = $request->cliente;
        }
        
        if ($request->filled('fecha_compromiso')) {
            $data['fecha_entrega'] = $request->fecha_compromiso;
        }

        $orden->update($data);

        return response()->json([
            'data' => $orden->load(['detalles.producto', 'creador']),
            'message' => 'Orden de salida actualizada exitosamente'
        ]);
    }

    public function destroy($id)
    {
        $orden = OrdenSalida::findOrFail($id);
        
        // Solo permitir eliminar si no tiene pickings asociados
        if ($orden->pickings()->count() > 0) {
            return response()->json([
                'message' => 'No se puede eliminar una orden que tiene pickings asociados'
            ], 400);
        }

        $orden->delete();

        return response()->json([
            'message' => 'Orden de salida eliminada exitosamente'
        ]);
    }

    public function confirmar($id)
    {
        $orden = OrdenSalida::findOrFail($id);
        
        if ($orden->estado !== 'CREADA') {
            return response()->json([
                'message' => 'Solo se pueden confirmar órdenes en estado CREADA'
            ], 400);
        }

        $orden->update(['estado' => 'EN_PICKING']);

        return response()->json([
            'data' => $orden->load(['detalles.producto', 'creador']),
            'message' => 'Orden confirmada exitosamente'
        ]);
    }

    public function cancelar($id)
    {
        $orden = OrdenSalida::findOrFail($id);
        
        if (in_array($orden->estado, ['PICKING_COMPLETO', 'CANCELADA'])) {
            return response()->json([
                'message' => 'Esta orden no puede ser cancelada'
            ], 400);
        }

        $orden->update(['estado' => 'CANCELADA']);

        return response()->json([
            'data' => $orden->load(['detalles.producto', 'creador']),
            'message' => 'Orden cancelada exitosamente'
        ]);
    }

    public function catalogos()
    {
        $productos = Producto::where('activo', true)
            ->select('id_producto', 'nombre', 'codigo_barra')
            ->orderBy('nombre')
            ->get();
            
        $prioridades = [
            ['codigo' => 1, 'nombre' => 'Muy Baja'],
            ['codigo' => 2, 'nombre' => 'Baja'],
            ['codigo' => 3, 'nombre' => 'Media'],
            ['codigo' => 4, 'nombre' => 'Alta'],
            ['codigo' => 5, 'nombre' => 'Urgente'],
        ];
        
        $estados = [
            ['codigo' => 'CREADA', 'nombre' => 'Creada'],
            ['codigo' => 'EN_PICKING', 'nombre' => 'En Picking'],
            ['codigo' => 'PICKING_COMPLETO', 'nombre' => 'Picking Completo'],
            ['codigo' => 'CANCELADA', 'nombre' => 'Cancelada'],
        ];

        return response()->json([
            'productos' => $productos,
            'prioridades' => $prioridades,
            'estados' => $estados
        ]);
    }
}

