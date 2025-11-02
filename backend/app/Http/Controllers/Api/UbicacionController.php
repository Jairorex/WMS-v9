<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ubicacion;
use Illuminate\Http\Request;

class UbicacionController extends Controller
{
    public function index(Request $request)
    {
        $query = Ubicacion::with(['inventario']);

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('codigo', 'like', "%{$search}%")
                  ->orWhere('pasillo', 'like', "%{$search}%")
                  ->orWhere('estanteria', 'like', "%{$search}%")
                  ->orWhere('nivel', 'like', "%{$search}%");
            });
        }

        if ($request->filled('tipo')) {
            $query->where('tipo', $request->tipo);
        }

        if ($request->filled('pasillo')) {
            $query->where('pasillo', $request->pasillo);
        }

        if ($request->boolean('disponibles')) {
            $query->disponibles();
        }

        if ($request->boolean('ocupadas')) {
            $query->ocupadas();
        }

        if ($request->boolean('activas')) {
            $query->activas();
        }

        if ($request->boolean('con_coordenadas')) {
            $query->conCoordenadas();
        }

        $ubicaciones = $query->orderBy('codigo')->get();

        // Transformar datos para incluir información de ocupación
        $ubicacionesTransformadas = $ubicaciones->map(function($ubicacion) {
            $ocupacion = $ubicacion->inventario->sum('cantidad');
            $porcentaje = $ubicacion->capacidad > 0 ? ($ocupacion / $ubicacion->capacidad) * 100 : 0;

            return [
                'id_ubicacion' => $ubicacion->id_ubicacion,
                'codigo' => $ubicacion->codigo,
                'pasillo' => $ubicacion->pasillo,
                'estanteria' => $ubicacion->estanteria,
                'nivel' => $ubicacion->nivel,
                'capacidad' => $ubicacion->capacidad,
                'tipo' => $ubicacion->tipo,
                'ocupada' => $ubicacion->ocupada,
                'inventario' => [
                    'cantidad_disponible' => $ocupacion,
                    'cantidad_reservada' => 0, // Por ahora siempre 0
                ],
                'ocupacion' => $ocupacion,
                'porcentaje_ocupacion' => round($porcentaje, 2),
                'created_at' => $ubicacion->created_at,
                'updated_at' => $ubicacion->updated_at,
            ];
        });

        return response()->json([
            'data' => $ubicacionesTransformadas
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'codigo' => 'required|string|max:50|unique:wms.ubicaciones,codigo',
            'pasillo' => 'required|string|max:10',
            'estanteria' => 'required|string|max:10',
            'nivel' => 'required|string|max:10',
            'capacidad' => 'required|integer|min:1',
            'tipo' => 'required|string|in:Almacen,Picking,Devoluciones',
            'ocupada' => 'boolean',
        ]);

        $ubicacion = Ubicacion::create($request->all());

        return response()->json([
            'data' => $ubicacion,
            'message' => 'Ubicación creada exitosamente'
        ], 201);
    }

    public function show(Ubicacion $ubicacion)
    {
        return response()->json([
            'data' => $ubicacion->load(['inventario.producto.estado'])
        ]);
    }

    public function update(Request $request, Ubicacion $ubicacion)
    {
        $request->validate([
            'codigo' => 'sometimes|required|string|max:50|unique:wms.ubicaciones,codigo,' . $ubicacion->id_ubicacion . ',id_ubicacion',
            'pasillo' => 'sometimes|required|string|max:10',
            'estanteria' => 'sometimes|required|string|max:10',
            'nivel' => 'sometimes|required|string|max:10',
            'capacidad' => 'sometimes|required|integer|min:1',
            'tipo' => 'sometimes|required|string|in:Almacen,Picking,Devoluciones',
            'ocupada' => 'boolean',
        ]);

        $ubicacion->update($request->all());

        return response()->json([
            'data' => $ubicacion,
            'message' => 'Ubicación actualizada exitosamente'
        ]);
    }

    public function destroy(Ubicacion $ubicacion)
    {
        $ubicacion->delete();

        return response()->json([
            'message' => 'Ubicación eliminada exitosamente'
        ]);
    }

    public function activar(Ubicacion $ubicacion)
    {
        $ubicacion->update(['ocupada' => false]);

        return response()->json([
            'data' => $ubicacion,
            'message' => 'Ubicación activada exitosamente'
        ]);
    }

    public function desactivar(Ubicacion $ubicacion)
    {
        $ubicacion->update(['ocupada' => true]);

        return response()->json([
            'data' => $ubicacion,
            'message' => 'Ubicación desactivada exitosamente'
        ]);
    }

    public function catalogos()
    {
        $tiposUbicacion = TipoUbicacion::activos()->orderBy('nombre')->get(['id', 'codigo', 'nombre']);
        $zonas = ZonaAlmacen::activas()->orderBy('nombre')->get(['id', 'codigo', 'nombre']);
        
        $tipos = [
            ['codigo' => 'Almacen', 'nombre' => 'Almacén'],
            ['codigo' => 'Picking', 'nombre' => 'Picking'],
            ['codigo' => 'Devoluciones', 'nombre' => 'Devoluciones'],
        ];

        $pasillos = Ubicacion::distinct()->pluck('pasillo')->filter()->sort()->values();

        return response()->json([
            'tipos' => $tipos,
            'tipos_ubicacion' => $tiposUbicacion,
            'zonas' => $zonas,
            'pasillos' => $pasillos
        ]);
    }

    public function mapa()
    {
        $ubicaciones = Ubicacion::conCoordenadas()
            ->with(['tipoUbicacion', 'zona', 'inventario'])
            ->activas()
            ->get();

        $mapa = $ubicaciones->map(function($ubicacion) {
            $ocupacion = $ubicacion->inventario->sum('cantidad');
            $porcentaje = $ubicacion->capacidad > 0 ? ($ocupacion / $ubicacion->capacidad) * 100 : 0;

            return [
                'id' => $ubicacion->id_ubicacion,
                'codigo' => $ubicacion->codigo,
                'x' => $ubicacion->coordenada_x,
                'y' => $ubicacion->coordenada_y,
                'z' => $ubicacion->coordenada_z,
                'tipo' => $ubicacion->tipoUbicacion?->nombre ?? $ubicacion->tipo,
                'zona' => $ubicacion->zona?->nombre,
                'capacidad' => $ubicacion->capacidad,
                'ocupacion' => $ocupacion,
                'porcentaje_ocupacion' => round($porcentaje, 2),
                'estado' => $ubicacion->ocupada ? 'ocupada' : 'disponible',
                'temperatura_min' => $ubicacion->temperatura_min,
                'temperatura_max' => $ubicacion->temperatura_max,
            ];
        });

        return response()->json([
            'data' => $mapa
        ]);
    }

    public function estadisticas()
    {
        $totalUbicaciones = Ubicacion::activas()->count();
        $ubicacionesOcupadas = Ubicacion::activas()->ocupadas()->count();
        $ubicacionesDisponibles = Ubicacion::activas()->disponibles()->count();
        
        $capacidadTotal = Ubicacion::activas()->sum('capacidad');
        $capacidadUtilizada = Ubicacion::activas()
            ->with('inventario')
            ->get()
            ->sum(function($ubicacion) {
                return $ubicacion->inventario->sum('cantidad');
            });

        $porTipoUbicacion = TipoUbicacion::withCount('ubicaciones')->get();
        $porZona = ZonaAlmacen::withCount('ubicaciones')->get();

        return response()->json([
            'data' => [
                'total_ubicaciones' => $totalUbicaciones,
                'ubicaciones_ocupadas' => $ubicacionesOcupadas,
                'ubicaciones_disponibles' => $ubicacionesDisponibles,
                'capacidad_total' => $capacidadTotal,
                'capacidad_utilizada' => $capacidadUtilizada,
                'porcentaje_ocupacion' => $capacidadTotal > 0 ? round(($capacidadUtilizada / $capacidadTotal) * 100, 2) : 0,
                'por_tipo_ubicacion' => $porTipoUbicacion,
                'por_zona' => $porZona,
            ]
        ]);
    }
}