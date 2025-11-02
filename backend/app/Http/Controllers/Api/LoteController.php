<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lote;
use App\Models\Producto;
use Illuminate\Http\Request;

class LoteController extends Controller
{
    public function index(Request $request)
    {
        $query = Lote::with(['producto']);

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('codigo_lote', 'like', "%{$search}%")
                  ->orWhere('numero_serie', 'like', "%{$search}%")
                  ->orWhere('proveedor', 'like', "%{$search}%")
                  ->orWhereHas('producto', function($productoQuery) use ($search) {
                      $productoQuery->where('nombre', 'like', "%{$search}%");
                  });
            });
        }

        if ($request->filled('producto_id')) {
            $query->where('producto_id', $request->producto_id);
        }

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('proveedor')) {
            $query->where('proveedor', 'like', "%{$request->proveedor}%");
        }

        if ($request->boolean('caducados')) {
            $query->caducados();
        }

        if ($request->boolean('por_caducar')) {
            $query->porCaducar($request->get('dias', 30));
        }

        if ($request->boolean('activos')) {
            $query->activos();
        }

        $lotes = $query->orderBy('fecha_caducidad', 'asc')
                      ->orderBy('codigo_lote', 'asc')
                      ->get();

        return response()->json([
            'data' => $lotes
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'codigo_lote' => 'required|string|max:50|unique:lotes,codigo_lote',
            'producto_id' => 'required|exists:productos,id_producto',
            'cantidad_inicial' => 'required|numeric|min:0',
            'cantidad_disponible' => 'required|numeric|min:0',
            'fecha_fabricacion' => 'required|date',
            'fecha_caducidad' => 'nullable|date|after:fecha_fabricacion',
            'fecha_vencimiento' => 'nullable|date|after:fecha_fabricacion',
            'proveedor' => 'nullable|string|max:100',
            'numero_serie' => 'nullable|string|max:50',
            'estado' => 'nullable|string|in:DISPONIBLE,RESERVADO,CADUCADO,RETIRADO',
            'observaciones' => 'nullable|string',
        ]);

        $lote = Lote::create($request->all());

        // Registrar evento de trazabilidad
        TrazabilidadProducto::registrarEntrada(
            $lote->producto_id,
            null, // Ubicación se asignará cuando se agregue al inventario
            $lote->cantidad_inicial,
            "Lote creado: {$lote->codigo_lote}"
        );

        return response()->json([
            'data' => $lote->load(['producto', 'inventario.ubicacion']),
            'message' => 'Lote creado exitosamente'
        ], 201);
    }

    public function show(Lote $lote)
    {
        return response()->json([
            'data' => $lote->load([
                'producto', 
                'inventario.ubicacion', 
                'movimientos.usuario',
                'trazabilidad.usuario'
            ])
        ]);
    }

    public function update(Request $request, Lote $lote)
    {
        $request->validate([
            'codigo_lote' => 'sometimes|required|string|max:50|unique:lotes,codigo_lote,' . $lote->id,
            'producto_id' => 'sometimes|required|exists:productos,id_producto',
            'cantidad_inicial' => 'sometimes|required|numeric|min:0',
            'cantidad_disponible' => 'sometimes|required|numeric|min:0',
            'fecha_fabricacion' => 'sometimes|required|date',
            'fecha_caducidad' => 'nullable|date|after:fecha_fabricacion',
            'fecha_vencimiento' => 'nullable|date|after:fecha_fabricacion',
            'proveedor' => 'nullable|string|max:100',
            'numero_serie' => 'nullable|string|max:50',
            'estado' => 'nullable|string|in:DISPONIBLE,RESERVADO,CADUCADO,RETIRADO',
            'observaciones' => 'nullable|string',
        ]);

        $lote->update($request->all());

        return response()->json([
            'data' => $lote->load(['producto', 'inventario.ubicacion']),
            'message' => 'Lote actualizado exitosamente'
        ]);
    }

    public function destroy(Lote $lote)
    {
        // Verificar si hay inventario asociado
        if ($lote->inventario()->count() > 0) {
            return response()->json([
                'message' => 'No se puede eliminar el lote porque tiene inventario asociado'
            ], 422);
        }

        $lote->delete();

        return response()->json([
            'message' => 'Lote eliminado exitosamente'
        ]);
    }

    public function ajustarCantidad(Request $request, Lote $lote)
    {
        $request->validate([
            'cantidad' => 'required|numeric',
            'motivo' => 'nullable|string|max:100',
        ]);

        try {
            $lote->ajustarCantidad(
                $request->cantidad,
                $request->motivo,
                auth()->id()
            );

            return response()->json([
                'data' => $lote->fresh(['producto', 'inventario.ubicacion']),
                'message' => 'Cantidad ajustada exitosamente'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function reservar(Request $request, Lote $lote)
    {
        $request->validate([
            'cantidad' => 'required|numeric|min:0',
        ]);

        try {
            $lote->reservar($request->cantidad, auth()->id());

            return response()->json([
                'data' => $lote->fresh(['producto', 'inventario.ubicacion']),
                'message' => 'Cantidad reservada exitosamente'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function liberar(Request $request, Lote $lote)
    {
        $request->validate([
            'cantidad' => 'required|numeric|min:0',
        ]);

        $lote->liberar($request->cantidad, auth()->id());

        return response()->json([
            'data' => $lote->fresh(['producto', 'inventario.ubicacion']),
            'message' => 'Cantidad liberada exitosamente'
        ]);
    }

    public function cambiarEstado(Request $request, Lote $lote)
    {
        $request->validate([
            'estado' => 'required|string|in:DISPONIBLE,RESERVADO,CADUCADO,RETIRADO',
            'observaciones' => 'nullable|string',
        ]);

        $estadoAnterior = $lote->estado;
        $lote->update([
            'estado' => $request->estado,
            'observaciones' => $request->observaciones
        ]);

        // Registrar en trazabilidad
        TrazabilidadProducto::registrarCambioEstado(
            $lote->producto_id,
            $estadoAnterior,
            $request->estado
        );

        return response()->json([
            'data' => $lote->fresh(['producto', 'inventario.ubicacion']),
            'message' => 'Estado del lote actualizado exitosamente'
        ]);
    }

    public function movimientos(Lote $lote)
    {
        $movimientos = $lote->movimientos()
            ->with(['usuario', 'ubicacion'])
            ->orderBy('fecha_movimiento', 'desc')
            ->get();

        return response()->json([
            'data' => $movimientos
        ]);
    }

    public function trazabilidad(Lote $lote)
    {
        $trazabilidad = $lote->trazabilidad()
            ->with(['usuario', 'ubicacionOrigen', 'ubicacionDestino'])
            ->orderBy('fecha_evento', 'desc')
            ->get();

        return response()->json([
            'data' => $trazabilidad
        ]);
    }

    public function estadisticas()
    {
        $totalLotes = Lote::activos()->count();
        $lotesDisponibles = Lote::activos()->disponibles()->count();
        $lotesCaducados = Lote::activos()->caducados()->count();
        $lotesPorCaducar = Lote::activos()->porCaducar()->count();

        $porEstado = Lote::activos()
            ->selectRaw('estado, COUNT(*) as cantidad')
            ->groupBy('estado')
            ->get();

        $porProducto = Lote::activos()
            ->with('producto')
            ->selectRaw('producto_id, COUNT(*) as cantidad')
            ->groupBy('producto_id')
            ->get();

        return response()->json([
            'data' => [
                'total_lotes' => $totalLotes,
                'lotes_disponibles' => $lotesDisponibles,
                'lotes_caducados' => $lotesCaducados,
                'lotes_por_caducar' => $lotesPorCaducar,
                'por_estado' => $porEstado,
                'por_producto' => $porProducto,
            ]
        ]);
    }

    public function alertasCaducidad()
    {
        $lotesCaducados = Lote::activos()
            ->caducados()
            ->with(['producto'])
            ->get();

        $lotesPorCaducar = Lote::activos()
            ->porCaducar()
            ->with(['producto'])
            ->get();

        return response()->json([
            'data' => [
                'caducados' => $lotesCaducados,
                'por_caducar' => $lotesPorCaducar,
            ]
        ]);
    }
}
