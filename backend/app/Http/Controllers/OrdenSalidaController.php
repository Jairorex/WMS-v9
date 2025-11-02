<?php

namespace App\Http\Controllers;

use App\Models\OrdenSalida;
use App\Models\OrdenSalidaDetalle;
use App\Models\Producto;
use Illuminate\Http\Request;

class OrdenSalidaController extends Controller
{
    public function index(Request $request)
    {
        $query = OrdenSalida::with('detalles.producto');

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where('id_orden', 'like', "%{$search}%");
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
            $query->vencidas();
        }

        $ordenes = $query->orderBy('fecha_creacion', 'desc')->get();

        // Transformar datos para el frontend
        $ordenesTransformadas = $ordenes->map(function($orden) {
            return [
                'id_orden' => $orden->id_orden,
                'estado' => $orden->estado,
                'prioridad' => $orden->prioridad,
                'cliente' => $orden->cliente,
                'fecha_compromiso' => $orden->fecha_entrega,
                'creado_por' => 1, // Por ahora siempre 1
                'creador' => [
                    'nombre' => 'Sistema',
                ],
                'detalles' => $orden->detalles->map(function($detalle) {
                    return [
                        'id_det' => $detalle->id_det,
                        'id_producto' => $detalle->id_producto,
                        'cant_solicitada' => $detalle->cantidad_solicitada,
                        'cant_comprometida' => $detalle->cantidad_confirmada,
                        'cant_pickeada' => 0, // Por ahora siempre 0
                        'producto' => [
                            'nombre' => $detalle->producto->nombre,
                        ],
                    ];
                }),
                'created_at' => $orden->created_at,
                'updated_at' => $orden->updated_at,
            ];
        });

        return response()->json([
            'data' => $ordenesTransformadas
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
                'estado' => 'Pendiente',
                'prioridad' => $request->prioridad,
                'fecha_creacion' => now(),
                'fecha_entrega' => $request->fecha_compromiso,
            ]);

            foreach ($request->detalles as $detalle) {
                OrdenSalidaDetalle::create([
                    'id_orden' => $orden->id_orden,
                    'id_producto' => $detalle['id_producto'],
                    'cantidad_solicitada' => $detalle['cant_solicitada'],
                    'cantidad_confirmada' => 0,
                ]);
            }

            DB::commit();

            return response()->json([
                'data' => $orden->load('detalles.producto'),
                'message' => 'Orden de salida creada exitosamente'
            ], 201);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'message' => 'Error al crear la orden de salida'
            ], 500);
        }
    }

    public function show(OrdenSalida $ordenSalida)
    {
        return response()->json([
            'data' => $ordenSalida->load('detalles.producto')
        ]);
    }

    public function update(Request $request, OrdenSalida $ordenSalida)
    {
        $request->validate([
            'estado' => 'sometimes|required|string|in:Pendiente,En Proceso,Completada,Cancelada',
            'prioridad' => 'sometimes|required|integer|min:1|max:5',
            'fecha_entrega' => 'sometimes|required|date',
        ]);

        $ordenSalida->update($request->all());

        return response()->json([
            'data' => $ordenSalida->load('detalles.producto'),
            'message' => 'Orden de salida actualizada exitosamente'
        ]);
    }

    public function destroy(OrdenSalida $ordenSalida)
    {
        $ordenSalida->delete();

        return response()->json([
            'message' => 'Orden de salida eliminada exitosamente'
        ]);
    }

    public function confirmar(OrdenSalida $ordenSalida)
    {
        $ordenSalida->update(['estado' => 'En Proceso']);

        return response()->json([
            'data' => $ordenSalida->load('detalles.producto'),
            'message' => 'Orden confirmada exitosamente'
        ]);
    }

    public function cancelar(OrdenSalida $ordenSalida)
    {
        $ordenSalida->update(['estado' => 'Cancelada']);

        return response()->json([
            'data' => $ordenSalida->load('detalles.producto'),
            'message' => 'Orden cancelada exitosamente'
        ]);
    }

    public function catalogos()
    {
        $productos = Producto::with('estado')->get(['id_producto', 'nombre', 'lote']);
        $prioridades = [
            ['codigo' => 1, 'nombre' => 'Muy Baja'],
            ['codigo' => 2, 'nombre' => 'Baja'],
            ['codigo' => 3, 'nombre' => 'Media'],
            ['codigo' => 4, 'nombre' => 'Alta'],
            ['codigo' => 5, 'nombre' => 'Muy Alta'],
        ];
        $estados = [
            ['codigo' => 'Pendiente', 'nombre' => 'Pendiente'],
            ['codigo' => 'En Proceso', 'nombre' => 'En Proceso'],
            ['codigo' => 'Completada', 'nombre' => 'Completada'],
            ['codigo' => 'Cancelada', 'nombre' => 'Cancelada'],
        ];

        return response()->json([
            'productos' => $productos,
            'prioridades' => $prioridades,
            'estados' => $estados
        ]);
    }
}