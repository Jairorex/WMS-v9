<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inventario;
use Illuminate\Http\Request;

class InventarioController extends Controller
{
    public function index(Request $request)
    {
        $query = Inventario::with(['producto', 'ubicacion', 'producto.estado']);

        // Filtros
        if ($request->filled('search')) {
            $search = $request->search;
            $query->whereHas('producto', function($q) use ($search) {
                $q->where('nombre', 'like', "%{$search}%")
                  ->orWhere('codigo_barra', 'like', "%{$search}%")
                  ->orWhere('lote', 'like', "%{$search}%");
            })->orWhereHas('ubicacion', function($q) use ($search) {
                $q->where('codigo', 'like', "%{$search}%");
            });
        }

        if ($request->filled('estado')) {
            $query->whereHas('producto.estado', function($q) use ($request) {
                $q->where('codigo', $request->estado);
            });
        }

        if ($request->filled('ubicacion')) {
            $query->whereHas('ubicacion', function($q) use ($request) {
                $q->where('codigo', 'like', "%{$request->ubicacion}%");
            });
        }

        $inventario = $query->orderBy('fecha_actualizacion', 'desc')->get();

        // Transformar datos para el frontend
        $inventarioTransformado = $inventario->map(function($item) {
            return [
                'id_inventario' => $item->id_inventario,
                'cantidad' => $item->cantidad,
                'lote' => $item->producto->lote,
                'fecha_vencimiento' => $item->producto->fecha_caducidad,
                'estado' => $item->producto->estado->nombre,
                'fecha_actualizacion' => $item->fecha_actualizacion,
                'producto_codigo' => $item->producto->codigo_barra,
                'producto_nombre' => $item->producto->nombre,
                'ubicacion_codigo' => $item->ubicacion->codigo,
                'ubicacion_nombre' => $item->ubicacion->pasillo . '-' . $item->ubicacion->estanteria . '-' . $item->ubicacion->nivel,
            ];
        });

        return response()->json([
            'data' => $inventarioTransformado
        ]);
    }

    public function show(Inventario $inventario)
    {
        return response()->json([
            'data' => $inventario->load(['producto.estado', 'ubicacion'])
        ]);
    }

    public function update(Request $request, Inventario $inventario)
    {
        $request->validate([
            'cantidad' => 'required|integer|min:0',
        ]);

        $inventario->update([
            'cantidad' => $request->cantidad,
            'fecha_actualizacion' => now()
        ]);

        return response()->json([
            'data' => $inventario->load(['producto.estado', 'ubicacion']),
            'message' => 'Inventario actualizado exitosamente'
        ]);
    }

    public function ajustar(Request $request, Inventario $inventario)
    {
        $request->validate([
            'cantidad_ajuste' => 'required|integer',
            'motivo' => 'required|string|max:255',
        ]);

        $nuevaCantidad = $inventario->cantidad + $request->cantidad_ajuste;
        
        if ($nuevaCantidad < 0) {
            return response()->json([
                'message' => 'La cantidad no puede ser negativa'
            ], 422);
        }

        $inventario->update([
            'cantidad' => $nuevaCantidad,
            'fecha_actualizacion' => now()
        ]);

        return response()->json([
            'data' => $inventario->load(['producto.estado', 'ubicacion']),
            'message' => 'Ajuste de inventario realizado exitosamente'
        ]);
    }
}