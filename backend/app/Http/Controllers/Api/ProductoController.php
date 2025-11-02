<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductoRequest;
use App\Http\Requests\UpdateProductoRequest;
use App\Models\Producto;
use App\Models\EstadoProducto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProductoController extends Controller
{
    public function index(Request $request)
    {
        $query = Producto::with(['estado', 'unidadMedida']);

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('nombre', 'like', "%{$search}%")
                  ->orWhere('descripcion', 'like', "%{$search}%")
                  ->orWhere('codigo_barra', 'like', "%{$search}%")
                  ->orWhere('lote', 'like', "%{$search}%");
            });
        }

        if ($request->filled('estado')) {
            $query->where('estado_producto_id', $request->estado);
        }

        if ($request->filled('unidad_medida')) {
            $query->whereHas('unidadMedida', function($q) use ($request) {
                $q->where('codigo', $request->unidad_medida);
            });
        }

        if ($request->boolean('stock_minimo')) {
            $query->stockBajo();
        }

        $productos = $query->orderBy('nombre')->get();

        return response()->json([
            'data' => $productos
        ]);
    }

    public function store(StoreProductoRequest $request)
    {
        $producto = Producto::create($request->validated());

        return response()->json([
            'data' => $producto->load('estado', 'unidadMedida'),
            'message' => 'Producto creado exitosamente'
        ], 201);
    }

    public function show(Producto $producto)
    {
        return response()->json([
            'data' => $producto->load('estado', 'unidadMedida', 'inventario.ubicacion')
        ]);
    }

    public function update(UpdateProductoRequest $request, Producto $producto)
    {
        $producto->update($request->validated());

        return response()->json([
            'data' => $producto->load('estado', 'unidadMedida'),
            'message' => 'Producto actualizado exitosamente'
        ]);
    }

    public function destroy(Producto $producto)
    {
        $producto->delete();

        return response()->json([
            'message' => 'Producto eliminado exitosamente'
        ]);
    }

    public function activar(Producto $producto)
    {
        $estadoDisponible = EstadoProducto::where('codigo', 'DISPONIBLE')->first();
        
        if (!$estadoDisponible) {
            return response()->json([
                'message' => 'Estado disponible no encontrado'
            ], 404);
        }

        $producto->update(['estado_producto_id' => $estadoDisponible->id_estado_producto]);

        return response()->json([
            'data' => $producto->load('estado'),
            'message' => 'Producto activado exitosamente'
        ]);
    }

    public function desactivar(Producto $producto)
    {
        $estadoRetenido = EstadoProducto::where('codigo', 'RETENIDO')->first();
        
        if (!$estadoRetenido) {
            return response()->json([
                'message' => 'Estado retenido no encontrado'
            ], 404);
        }

        $producto->update(['estado_producto_id' => $estadoRetenido->id_estado_producto]);

        return response()->json([
            'data' => $producto->load('estado'),
            'message' => 'Producto desactivado exitosamente'
        ]);
    }

    public function catalogos()
    {
        $estados = EstadoProducto::all();
        $unidadesMedida = Producto::distinct()->pluck('unidad_medida')->filter();

        return response()->json([
            'estados' => $estados,
            'unidades_medida' => $unidadesMedida
        ]);
    }
}