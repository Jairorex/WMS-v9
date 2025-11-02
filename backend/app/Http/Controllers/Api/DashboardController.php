<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OrdenSalida;
use App\Models\Tarea;
use App\Models\Producto;
use App\Models\Usuario;
use App\Models\Incidencia;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function estadisticas()
    {
        // Órdenes pendientes
        $ordenesPendientes = OrdenSalida::where('estado', 'Pendiente')->count();
        
        // Tareas completadas hoy
        $tareasCompletadasHoy = Tarea::whereHas('estado', function($q) {
            $q->where('codigo', 'COMPLETADA');
        })->whereDate('fecha_cierre', today())->count();
        
        // Alertas de stock bajo
        $alertasStock = Producto::stockBajo()->count();
        
        // Usuarios activos
        $usuariosActivos = Usuario::where('activo', true)->count();

        return response()->json([
            'ordenes_pendientes' => $ordenesPendientes,
            'tareas_completadas_hoy' => $tareasCompletadasHoy,
            'alertas_stock' => $alertasStock,
            'usuarios_activos' => $usuariosActivos,
        ]);
    }

    public function actividadReciente()
    {
        // Actividad reciente de tareas
        $tareasRecientes = Tarea::with(['tipo', 'estado', 'creador'])
            ->orderBy('fecha_creacion', 'desc')
            ->limit(10)
            ->get()
            ->map(function($tarea) {
                return [
                    'id' => $tarea->id_tarea,
                    'tipo' => $tarea->tipo->nombre,
                    'descripcion' => $tarea->descripcion,
                    'estado' => $tarea->estado->nombre,
                    'creado_por' => $tarea->creador->nombre,
                    'fecha' => $tarea->fecha_creacion,
                ];
            });

        // Incidencias recientes
        $incidenciasRecientes = Incidencia::with(['operario', 'producto'])
            ->orderBy('fecha_reporte', 'desc')
            ->limit(5)
            ->get()
            ->map(function($incidencia) {
                return [
                    'id' => $incidencia->id_incidencia,
                    'descripcion' => $incidencia->descripcion,
                    'estado' => $incidencia->estado,
                    'operario' => $incidencia->operario->nombre,
                    'producto' => $incidencia->producto->nombre,
                    'fecha' => $incidencia->fecha_reporte,
                ];
            });

        return response()->json([
            'tareas' => $tareasRecientes,
            'incidencias' => $incidenciasRecientes,
        ]);
    }

    public function resumen()
    {
        $estadisticas = $this->estadisticas();
        $actividad = $this->actividadReciente();

        return response()->json([
            'estadisticas' => $estadisticas->getData(),
            'actividad_reciente' => $actividad->getData(),
        ]);
    }
}