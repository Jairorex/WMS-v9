<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TrazabilidadProducto;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class TrazabilidadProductoController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = TrazabilidadProducto::with(['producto', 'lote', 'numeroSerie', 'ubicacion', 'usuario']);

        // Filtros
        if ($request->filled('producto_id')) {
            $query->where('producto_id', $request->producto_id);
        }

        if ($request->filled('lote_id')) {
            $query->where('lote_id', $request->lote_id);
        }

        if ($request->filled('numero_serie_id')) {
            $query->where('numero_serie_id', $request->numero_serie_id);
        }

        if ($request->filled('ubicacion_id')) {
            $query->where('ubicacion_id', $request->ubicacion_id);
        }

        if ($request->filled('tipo_evento')) {
            $query->where('tipo_evento', $request->tipo_evento);
        }

        if ($request->filled('fecha_desde')) {
            $query->whereDate('fecha_evento', '>=', $request->fecha_desde);
        }

        if ($request->filled('fecha_hasta')) {
            $query->whereDate('fecha_evento', '<=', $request->fecha_hasta);
        }

        $trazabilidad = $query->orderBy('fecha_evento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($trazabilidad);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'producto_id' => 'required|exists:productos,id',
            'lote_id' => 'nullable|exists:lotes,id',
            'numero_serie_id' => 'nullable|exists:numeros_serie,id',
            'ubicacion_id' => 'nullable|exists:ubicaciones,id',
            'tipo_evento' => 'required|in:entrada,salida,transferencia,ajuste,reserva,liberacion,inspeccion,calibracion,mantenimiento',
            'fecha_evento' => 'required|date',
            'cantidad' => 'nullable|numeric|min:0',
            'precio_unitario' => 'nullable|numeric|min:0',
            'referencia' => 'nullable|string|max:100',
            'observaciones' => 'nullable|string|max:500',
            'datos_adicionales' => 'nullable|json',
            'temperatura' => 'nullable|numeric',
            'humedad' => 'nullable|numeric',
            'presion' => 'nullable|numeric',
        ]);

        $validated['usuario_id'] = auth()->id();

        $trazabilidad = TrazabilidadProducto::create($validated);

        return response()->json($trazabilidad->load(['producto', 'lote', 'numeroSerie', 'ubicacion', 'usuario']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(TrazabilidadProducto $trazabilidadProducto): JsonResponse
    {
        return response()->json($trazabilidadProducto->load(['producto', 'lote', 'numeroSerie', 'ubicacion', 'usuario']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, TrazabilidadProducto $trazabilidadProducto): JsonResponse
    {
        $validated = $request->validate([
            'producto_id' => 'sometimes|exists:productos,id',
            'lote_id' => 'nullable|exists:lotes,id',
            'numero_serie_id' => 'nullable|exists:numeros_serie,id',
            'ubicacion_id' => 'nullable|exists:ubicaciones,id',
            'tipo_evento' => 'sometimes|in:entrada,salida,transferencia,ajuste,reserva,liberacion,inspeccion,calibracion,mantenimiento',
            'fecha_evento' => 'sometimes|date',
            'cantidad' => 'nullable|numeric|min:0',
            'precio_unitario' => 'nullable|numeric|min:0',
            'referencia' => 'nullable|string|max:100',
            'observaciones' => 'nullable|string|max:500',
            'datos_adicionales' => 'nullable|json',
            'temperatura' => 'nullable|numeric',
            'humedad' => 'nullable|numeric',
            'presion' => 'nullable|numeric',
        ]);

        $trazabilidadProducto->update($validated);

        return response()->json($trazabilidadProducto->load(['producto', 'lote', 'numeroSerie', 'ubicacion', 'usuario']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(TrazabilidadProducto $trazabilidadProducto): JsonResponse
    {
        $trazabilidadProducto->delete();

        return response()->json(null, 204);
    }

    /**
     * Obtener trazabilidad completa de un producto
     */
    public function porProducto(Request $request, $productoId): JsonResponse
    {
        $trazabilidad = TrazabilidadProducto::with(['lote', 'numeroSerie', 'ubicacion', 'usuario'])
            ->where('producto_id', $productoId)
            ->orderBy('fecha_evento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($trazabilidad);
    }

    /**
     * Obtener trazabilidad de un lote específico
     */
    public function porLote(Request $request, $loteId): JsonResponse
    {
        $trazabilidad = TrazabilidadProducto::with(['producto', 'numeroSerie', 'ubicacion', 'usuario'])
            ->where('lote_id', $loteId)
            ->orderBy('fecha_evento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($trazabilidad);
    }

    /**
     * Obtener trazabilidad de un número de serie específico
     */
    public function porNumeroSerie(Request $request, $numeroSerieId): JsonResponse
    {
        $trazabilidad = TrazabilidadProducto::with(['producto', 'lote', 'ubicacion', 'usuario'])
            ->where('numero_serie_id', $numeroSerieId)
            ->orderBy('fecha_evento', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($trazabilidad);
    }

    /**
     * Obtener historial de ubicaciones de un producto
     */
    public function historialUbicaciones(Request $request, $productoId): JsonResponse
    {
        $historial = TrazabilidadProducto::with(['ubicacion', 'lote', 'numeroSerie'])
            ->where('producto_id', $productoId)
            ->whereNotNull('ubicacion_id')
            ->orderBy('fecha_evento', 'desc')
            ->get();

        return response()->json($historial);
    }

    /**
     * Obtener estadísticas de trazabilidad
     */
    public function estadisticas(Request $request): JsonResponse
    {
        $query = TrazabilidadProducto::query();

        if ($request->filled('fecha_desde')) {
            $query->whereDate('fecha_evento', '>=', $request->fecha_desde);
        }

        if ($request->filled('fecha_hasta')) {
            $query->whereDate('fecha_evento', '<=', $request->fecha_hasta);
        }

        $estadisticas = [
            'total_eventos' => $query->count(),
            'por_tipo_evento' => $query->selectRaw('tipo_evento, COUNT(*) as cantidad')
                ->groupBy('tipo_evento')
                ->get(),
            'por_producto' => $query->with('producto')
                ->selectRaw('producto_id, COUNT(*) as cantidad')
                ->groupBy('producto_id')
                ->get(),
            'por_ubicacion' => $query->with('ubicacion')
                ->selectRaw('ubicacion_id, COUNT(*) as cantidad')
                ->groupBy('ubicacion_id')
                ->get(),
            'por_fecha' => $query->selectRaw('DATE(fecha_evento) as fecha, COUNT(*) as cantidad')
                ->groupBy('DATE(fecha_evento)')
                ->orderBy('fecha', 'desc')
                ->limit(30)
                ->get(),
        ];

        return response()->json($estadisticas);
    }

    /**
     * Obtener resumen de trazabilidad por período
     */
    public function resumen(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fecha_desde' => 'required|date',
            'fecha_hasta' => 'required|date',
        ]);

        $resumen = TrazabilidadProducto::whereBetween('fecha_evento', [
            $validated['fecha_desde'],
            $validated['fecha_hasta']
        ])
        ->selectRaw('
            tipo_evento,
            COUNT(*) as total_eventos,
            SUM(cantidad) as total_cantidad,
            AVG(precio_unitario) as precio_promedio
        ')
        ->groupBy('tipo_evento')
        ->get();

        return response()->json($resumen);
    }

    /**
     * Obtener alertas de trazabilidad
     */
    public function alertas(): JsonResponse
    {
        $alertas = [
            'productos_sin_movimiento' => TrazabilidadProducto::selectRaw('producto_id, MAX(fecha_evento) as ultimo_movimiento')
                ->groupBy('producto_id')
                ->havingRaw('MAX(fecha_evento) < DATE_SUB(NOW(), INTERVAL 30 DAY)')
                ->with('producto')
                ->get(),
            'lotes_proximos_vencimiento' => TrazabilidadProducto::with(['producto', 'lote'])
                ->whereHas('lote', function($query) {
                    $query->where('fecha_vencimiento', '<=', now()->addDays(30));
                })
                ->get(),
        ];

        return response()->json($alertas);
    }
}
