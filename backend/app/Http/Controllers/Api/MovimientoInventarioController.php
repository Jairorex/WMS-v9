<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MovimientoInventario;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class MovimientoInventarioController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = MovimientoInventario::with(['producto', 'ubicacion', 'lote', 'usuario']);

        // Filtros
        if ($request->filled('producto_id')) {
            $query->where('producto_id', $request->producto_id);
        }

        if ($request->filled('ubicacion_id')) {
            $query->where('ubicacion_id', $request->ubicacion_id);
        }

        if ($request->filled('lote_id')) {
            $query->where('lote_id', $request->lote_id);
        }

        if ($request->filled('numero_serie_id')) {
            $query->where('numero_serie_id', $request->numero_serie_id);
        }

        if ($request->filled('tipo_movimiento')) {
            $query->where('tipo_movimiento', $request->tipo_movimiento);
        }

        if ($request->filled('fecha_desde')) {
            $query->whereDate('fecha_movimiento', '>=', $request->fecha_desde);
        }

        if ($request->filled('fecha_hasta')) {
            $query->whereDate('fecha_movimiento', '<=', $request->fecha_hasta);
        }

        if ($request->filled('usuario_id')) {
            $query->where('usuario_id', $request->usuario_id);
        }

        // Búsqueda general
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function ($q) use ($search) {
                $q->whereHas('producto', function ($query) use ($search) {
                    $query->where('nombre', 'like', "%{$search}%")
                        ->orWhere('codigo_barra', 'like', "%{$search}%");
                })
                ->orWhereHas('ubicacion', function ($query) use ($search) {
                    $query->where('codigo', 'like', "%{$search}%");
                })
                ->orWhereHas('lote', function ($query) use ($search) {
                    $query->where('codigo_lote', 'like', "%{$search}%");
                })
                ->orWhere('tipo_movimiento', 'like', "%{$search}%")
                ->orWhere('motivo', 'like', "%{$search}%")
                ->orWhere('referencia', 'like', "%{$search}%")
                ->orWhere('observaciones', 'like', "%{$search}%");
            });
        }

        $movimientos = $query->orderBy('fecha_movimiento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($movimientos);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'producto_id' => 'required|exists:productos,id',
            'ubicacion_id' => 'required|exists:ubicaciones,id',
            'lote_id' => 'nullable|exists:lotes,id',
            'numero_serie_id' => 'nullable|exists:numeros_serie,id',
            'tipo_movimiento' => 'required|in:entrada,salida,transferencia,ajuste,reserva,liberacion',
            'cantidad' => 'required|numeric|min:0.01',
            'precio_unitario' => 'nullable|numeric|min:0',
            'fecha_movimiento' => 'required|date',
            'referencia' => 'nullable|string|max:100',
            'observaciones' => 'nullable|string|max:500',
            'motivo' => 'nullable|string|max:200',
        ]);

        $validated['usuario_id'] = auth()->id();

        $movimiento = MovimientoInventario::create($validated);

        return response()->json($movimiento->load(['producto', 'ubicacion', 'lote', 'usuario']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(MovimientoInventario $movimientoInventario): JsonResponse
    {
        return response()->json($movimientoInventario->load(['producto', 'ubicacion', 'lote', 'usuario']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, MovimientoInventario $movimientoInventario): JsonResponse
    {
        $validated = $request->validate([
            'producto_id' => 'sometimes|exists:productos,id',
            'ubicacion_id' => 'sometimes|exists:ubicaciones,id',
            'lote_id' => 'nullable|exists:lotes,id',
            'numero_serie_id' => 'nullable|exists:numeros_serie,id',
            'tipo_movimiento' => 'sometimes|in:entrada,salida,transferencia,ajuste,reserva,liberacion',
            'cantidad' => 'sometimes|numeric|min:0.01',
            'precio_unitario' => 'nullable|numeric|min:0',
            'fecha_movimiento' => 'sometimes|date',
            'referencia' => 'nullable|string|max:100',
            'observaciones' => 'nullable|string|max:500',
            'motivo' => 'nullable|string|max:200',
        ]);

        $movimientoInventario->update($validated);

        return response()->json($movimientoInventario->load(['producto', 'ubicacion', 'lote', 'usuario']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(MovimientoInventario $movimientoInventario): JsonResponse
    {
        $movimientoInventario->delete();

        return response()->json(null, 204);
    }

    /**
     * Obtener movimientos por producto
     */
    public function porProducto(Request $request, $productoId): JsonResponse
    {
        $movimientos = MovimientoInventario::with(['ubicacion', 'lote', 'usuario'])
            ->where('producto_id', $productoId)
            ->orderBy('fecha_movimiento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($movimientos);
    }

    /**
     * Obtener movimientos por ubicación
     */
    public function porUbicacion(Request $request, $ubicacionId): JsonResponse
    {
        $movimientos = MovimientoInventario::with(['producto', 'lote', 'usuario'])
            ->where('ubicacion_id', $ubicacionId)
            ->orderBy('fecha_movimiento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($movimientos);
    }

    /**
     * Obtener movimientos por lote
     */
    public function porLote(Request $request, $loteId): JsonResponse
    {
        $movimientos = MovimientoInventario::with(['producto', 'ubicacion', 'usuario'])
            ->where('lote_id', $loteId)
            ->orderBy('fecha_movimiento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($movimientos);
    }

    /**
     * Obtener estadísticas de movimientos
     */
    public function estadisticas(Request $request): JsonResponse
    {
        $query = MovimientoInventario::query();

        if ($request->filled('fecha_desde')) {
            $query->whereDate('fecha_movimiento', '>=', $request->fecha_desde);
        }

        if ($request->filled('fecha_hasta')) {
            $query->whereDate('fecha_movimiento', '<=', $request->fecha_hasta);
        }

        $estadisticas = [
            'total_movimientos' => $query->count(),
            'por_tipo' => $query->selectRaw('tipo_movimiento, COUNT(*) as cantidad')
                ->groupBy('tipo_movimiento')
                ->get(),
            'por_producto' => $query->with('producto')
                ->selectRaw('producto_id, COUNT(*) as cantidad, SUM(cantidad) as total_cantidad')
                ->groupBy('producto_id')
                ->get(),
            'por_ubicacion' => $query->with('ubicacion')
                ->selectRaw('ubicacion_id, COUNT(*) as cantidad, SUM(cantidad) as total_cantidad')
                ->groupBy('ubicacion_id')
                ->get(),
            'por_fecha' => $query->selectRaw('DATE(fecha_movimiento) as fecha, COUNT(*) as cantidad')
                ->groupBy('DATE(fecha_movimiento)')
                ->orderBy('fecha', 'desc')
                ->limit(30)
                ->get(),
        ];

        return response()->json($estadisticas);
    }

    /**
     * Obtener resumen de movimientos por período
     */
    public function resumen(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fecha_desde' => 'required|date',
            'fecha_hasta' => 'required|date',
        ]);

        $resumen = MovimientoInventario::whereBetween('fecha_movimiento', [
            $validated['fecha_desde'],
            $validated['fecha_hasta']
        ])
        ->selectRaw('
            tipo_movimiento,
            COUNT(*) as total_movimientos,
            SUM(cantidad) as total_cantidad,
            AVG(precio_unitario) as precio_promedio,
            SUM(cantidad * COALESCE(precio_unitario, 0)) as valor_total
        ')
        ->groupBy('tipo_movimiento')
        ->get();

        return response()->json($resumen);
    }
}
