<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OleadaPicking;
use App\Models\PedidoPicking;
use App\Models\PedidoPickingDetalle;
use App\Models\RutaPicking;
use App\Models\EstadisticaPicking;
use Illuminate\Http\Request;

class PickingInteligenteController extends Controller
{
    // Gestión de Oleadas
    public function indexOleadas(Request $request)
    {
        $query = OleadaPicking::with(['zona', 'operario', 'pedidos']);

        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('nombre', 'like', "%{$search}%")
                  ->orWhere('descripcion', 'like', "%{$search}%");
            });
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('operario_id')) {
            $query->where('operario_asignado', $request->operario_id);
        }

        if ($request->filled('zona_id')) {
            $query->where('zona_id', $request->zona_id);
        }

        if ($request->filled('prioridad')) {
            $query->where('prioridad', $request->prioridad);
        }

        if ($request->boolean('activas')) {
            $query->activas();
        }

        if ($request->boolean('vencidas')) {
            $query->vencidas();
        }

        if ($request->boolean('por_vencer')) {
            $query->porVencer($request->get('horas', 24));
        }

        $oleadas = $query->orderBy('fecha_vencimiento', 'asc')
                        ->orderBy('prioridad', 'desc')
                        ->get();

        return response()->json([
            'data' => $oleadas
        ]);
    }

    public function storeOleada(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:100',
            'descripcion' => 'nullable|string|max:255',
            'fecha_vencimiento' => 'required|date|after:now',
            'prioridad' => 'required|string|in:BAJA,MEDIA,ALTA,CRITICA',
            'zona_id' => 'nullable|exists:zonas_almacen,id',
            'operario_asignado' => 'nullable|exists:usuarios,id_usuario',
            'observaciones' => 'nullable|string',
        ]);

        $oleada = OleadaPicking::create($request->all());

        return response()->json([
            'data' => $oleada->load(['zona', 'operario']),
            'message' => 'Oleada de picking creada exitosamente'
        ], 201);
    }

    public function showOleada(OleadaPicking $oleada)
    {
        return response()->json([
            'data' => $oleada->load([
                'zona', 
                'operario', 
                'pedidos.detalles.producto',
                'pedidos.detalles.ubicacion',
                'rutas.ubicacion',
                'rutas.producto'
            ])
        ]);
    }

    public function updateOleada(Request $request, OleadaPicking $oleada)
    {
        $request->validate([
            'nombre' => 'sometimes|required|string|max:100',
            'descripcion' => 'nullable|string|max:255',
            'fecha_vencimiento' => 'sometimes|required|date|after:now',
            'prioridad' => 'sometimes|required|string|in:BAJA,MEDIA,ALTA,CRITICA',
            'zona_id' => 'nullable|exists:zonas_almacen,id',
            'operario_asignado' => 'nullable|exists:usuarios,id_usuario',
            'observaciones' => 'nullable|string',
        ]);

        $oleada->update($request->all());

        return response()->json([
            'data' => $oleada->load(['zona', 'operario']),
            'message' => 'Oleada actualizada exitosamente'
        ]);
    }

    public function destroyOleada(OleadaPicking $oleada)
    {
        if ($oleada->estado === 'EN_PROCESO') {
            return response()->json([
                'message' => 'No se puede eliminar una oleada en proceso'
            ], 422);
        }

        $oleada->delete();

        return response()->json([
            'message' => 'Oleada eliminada exitosamente'
        ]);
    }

    public function iniciarOleada(OleadaPicking $oleada)
    {
        if ($oleada->estado !== 'PENDIENTE') {
            return response()->json([
                'message' => 'Solo se pueden iniciar oleadas pendientes'
            ], 422);
        }

        $oleada->iniciar();

        return response()->json([
            'data' => $oleada->fresh(['zona', 'operario']),
            'message' => 'Oleada iniciada exitosamente'
        ]);
    }

    public function completarOleada(OleadaPicking $oleada)
    {
        if ($oleada->estado !== 'EN_PROCESO') {
            return response()->json([
                'message' => 'Solo se pueden completar oleadas en proceso'
            ], 422);
        }

        $oleada->completar();

        return response()->json([
            'data' => $oleada->fresh(['zona', 'operario']),
            'message' => 'Oleada completada exitosamente'
        ]);
    }

    public function cancelarOleada(Request $request, OleadaPicking $oleada)
    {
        $request->validate([
            'motivo' => 'nullable|string|max:255',
        ]);

        $oleada->cancelar($request->motivo);

        return response()->json([
            'data' => $oleada->fresh(['zona', 'operario']),
            'message' => 'Oleada cancelada exitosamente'
        ]);
    }

    public function generarRutaOptimizada(OleadaPicking $oleada)
    {
        $rutas = $oleada->generarRutaOptimizada();

        if ($rutas->isEmpty()) {
            return response()->json([
                'message' => 'No hay items pendientes para generar ruta'
            ], 422);
        }

        // Eliminar rutas existentes
        RutaPicking::where('oleada_id', $oleada->id)->delete();

        // Crear nuevas rutas
        foreach ($rutas as $ruta) {
            RutaPicking::create($ruta);
        }

        return response()->json([
            'data' => RutaPicking::where('oleada_id', $oleada->id)
                ->with(['ubicacion', 'producto'])
                ->orderBy('secuencia')
                ->get(),
            'message' => 'Ruta optimizada generada exitosamente'
        ]);
    }

    // Gestión de Pedidos
    public function indexPedidos(Request $request)
    {
        $query = PedidoPicking::with(['oleada', 'operario', 'detalles.producto']);

        if ($request->filled('oleada_id')) {
            $query->where('oleada_id', $request->oleada_id);
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('operario_id')) {
            $query->where('operario_asignado', $request->operario_id);
        }

        if ($request->filled('prioridad')) {
            $query->where('prioridad', $request->prioridad);
        }

        $pedidos = $query->orderBy('fecha_vencimiento', 'asc')
                        ->orderBy('prioridad', 'desc')
                        ->get();

        return response()->json([
            'data' => $pedidos
        ]);
    }

    public function storePedido(Request $request)
    {
        $request->validate([
            'numero_pedido' => 'required|string|max:50|unique:pedidos_picking,numero_pedido',
            'oleada_id' => 'required|exists:oleadas_picking,id',
            'cliente' => 'nullable|string|max:100',
            'fecha_vencimiento' => 'required|date|after:now',
            'prioridad' => 'required|string|in:BAJA,MEDIA,ALTA,CRITICA',
            'operario_asignado' => 'nullable|exists:usuarios,id_usuario',
            'observaciones' => 'nullable|string',
        ]);

        $pedido = PedidoPicking::create($request->all());

        return response()->json([
            'data' => $pedido->load(['oleada', 'operario']),
            'message' => 'Pedido creado exitosamente'
        ], 201);
    }

    public function showPedido(PedidoPicking $pedido)
    {
        return response()->json([
            'data' => $pedido->load([
                'oleada',
                'operario',
                'detalles.producto',
                'detalles.ubicacion',
                'detalles.lote',
                'detalles.numeroSerie'
            ])
        ]);
    }

    public function iniciarPedido(PedidoPicking $pedido)
    {
        if ($pedido->estado !== 'PENDIENTE') {
            return response()->json([
                'message' => 'Solo se pueden iniciar pedidos pendientes'
            ], 422);
        }

        $pedido->iniciar();

        return response()->json([
            'data' => $pedido->fresh(['oleada', 'operario']),
            'message' => 'Pedido iniciado exitosamente'
        ]);
    }

    public function completarPedido(PedidoPicking $pedido)
    {
        if ($pedido->estado !== 'EN_PROCESO') {
            return response()->json([
                'message' => 'Solo se pueden completar pedidos en proceso'
            ], 422);
        }

        $pedido->completar();

        return response()->json([
            'data' => $pedido->fresh(['oleada', 'operario']),
            'message' => 'Pedido completado exitosamente'
        ]);
    }

    // Gestión de Detalles de Pedidos
    public function indexDetalles(Request $request)
    {
        $query = PedidoPickingDetalle::with([
            'pedido.oleada',
            'producto',
            'ubicacion',
            'lote',
            'numeroSerie',
            'operario'
        ]);

        if ($request->filled('pedido_id')) {
            $query->where('pedido_id', $request->pedido_id);
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('operario_id')) {
            $query->where('operario_asignado', $request->operario_id);
        }

        if ($request->filled('producto_id')) {
            $query->where('producto_id', $request->producto_id);
        }

        if ($request->filled('ubicacion_id')) {
            $query->where('ubicacion_id', $request->ubicacion_id);
        }

        $detalles = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'data' => $detalles
        ]);
    }

    public function iniciarDetalle(PedidoPickingDetalle $detalle)
    {
        if ($detalle->estado !== 'PENDIENTE') {
            return response()->json([
                'message' => 'Solo se pueden iniciar detalles pendientes'
            ], 422);
        }

        if (!$detalle->verificarDisponibilidad()) {
            return response()->json([
                'message' => 'No hay suficiente stock disponible'
            ], 422);
        }

        $detalle->iniciar();

        return response()->json([
            'data' => $detalle->fresh(['producto', 'ubicacion', 'lote']),
            'message' => 'Detalle iniciado exitosamente'
        ]);
    }

    public function completarDetalle(Request $request, PedidoPickingDetalle $detalle)
    {
        $request->validate([
            'cantidad_confirmada' => 'required|numeric|min:0',
        ]);

        if ($detalle->estado !== 'EN_PROCESO') {
            return response()->json([
                'message' => 'Solo se pueden completar detalles en proceso'
            ], 422);
        }

        $detalle->completar($request->cantidad_confirmada);

        return response()->json([
            'data' => $detalle->fresh(['producto', 'ubicacion', 'lote']),
            'message' => 'Detalle completado exitosamente'
        ]);
    }

    // Estadísticas y Reportes
    public function estadisticas(Request $request)
    {
        $fechaInicio = $request->get('fecha_inicio', now()->subDays(30));
        $fechaFin = $request->get('fecha_fin', now());

        $estadisticas = EstadisticaPicking::porRangoFecha($fechaInicio, $fechaFin)
            ->with(['operario', 'oleada'])
            ->get();

        return response()->json([
            'data' => $estadisticas
        ]);
    }

    public function reporteOperario(Request $request, $operarioId)
    {
        $fecha = $request->get('fecha', now()->toDateString());
        
        $estadisticas = EstadisticaPicking::calcularEstadisticas($operarioId, $fecha);

        return response()->json([
            'data' => $estadisticas
        ]);
    }

    public function reporteDiario(Request $request)
    {
        $fecha = $request->get('fecha', now()->toDateString());
        
        $estadisticas = EstadisticaPicking::generarReporteDiario($fecha);

        return response()->json([
            'data' => $estadisticas
        ]);
    }

    public function reporteOleada(OleadaPicking $oleada)
    {
        $estadisticas = EstadisticaPicking::generarReporteOleada($oleada->id);

        return response()->json([
            'data' => $estadisticas
        ]);
    }
}
