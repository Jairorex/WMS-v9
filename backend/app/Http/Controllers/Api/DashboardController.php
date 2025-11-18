<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use App\Models\OrdenSalida;
use App\Models\Tarea;
use App\Models\Producto;
use App\Models\Usuario;
use App\Models\Incidencia;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    use ApiResponse;

    public function estadisticas()
    {
        try {
            // Órdenes pendientes
            $ordenesPendientes = OrdenSalida::where('estado', 'Pendiente')->count();
            
            // Tareas completadas hoy
            $tareasCompletadasHoy = Tarea::whereHas('estado', function($q) {
                $q->where('codigo', 'COMPLETADA');
            })->whereDate('fecha_cierre', today())->count();
            
            // Alertas de stock bajo (con manejo de error si el scope no existe)
            $alertasStock = 0;
            try {
                $alertasStock = Producto::stockBajo()->count();
            } catch (\Exception $e) {
                // Si el scope no existe, usar una consulta alternativa
                $alertasStock = Producto::whereRaw('stock_minimo > (
                    SELECT COALESCE(SUM(cantidad), 0) 
                    FROM wms.inventario 
                    WHERE id_producto = wms.productos.id_producto
                )')->count();
            }
            
            // Usuarios activos
            $usuariosActivos = Usuario::where('activo', true)->count();

            return $this->successResponse([
                'ordenes_pendientes' => $ordenesPendientes,
                'tareas_completadas_hoy' => $tareasCompletadasHoy,
                'alertas_stock' => $alertasStock,
                'usuarios_activos' => $usuariosActivos,
            ], 'Estadísticas obtenidas exitosamente');
        } catch (\Exception $e) {
            return $this->errorResponse(
                'Error al obtener estadísticas: ' . $e->getMessage(),
                ['error' => $e->getMessage(), 'file' => $e->getFile(), 'line' => $e->getLine()],
                500
            );
        }
    }

    public function actividadReciente()
    {
        try {
            // Actividad reciente de tareas
            $tareasRecientes = Tarea::with(['tipo', 'estado', 'creador'])
                ->orderBy('fecha_creacion', 'desc')
                ->limit(10)
                ->get()
                ->map(function($tarea) {
                    return [
                        'id' => $tarea->id_tarea,
                        'tipo' => $tarea->tipo?->nombre ?? 'N/A',
                        'descripcion' => $tarea->descripcion,
                        'estado' => $tarea->estado?->nombre ?? 'N/A',
                        'creado_por' => $tarea->creador?->nombre ?? 'N/A',
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
                        'operario' => $incidencia->operario?->nombre ?? 'N/A',
                        'producto' => $incidencia->producto?->nombre ?? 'N/A',
                        'fecha' => $incidencia->fecha_reporte,
                    ];
                });

            return $this->successResponse([
                'tareas' => $tareasRecientes,
                'incidencias' => $incidenciasRecientes,
            ], 'Actividad reciente obtenida exitosamente');
        } catch (\Exception $e) {
            return $this->errorResponse(
                'Error al obtener actividad reciente: ' . $e->getMessage(),
                ['error' => $e->getMessage(), 'file' => $e->getFile(), 'line' => $e->getLine()],
                500
            );
        }
    }

    public function resumen()
    {
        try {
            $estadisticas = $this->estadisticas();
            $actividad = $this->actividadReciente();

            // Extraer los datos de las respuestas
            $estadisticasData = $estadisticas->getData();
            $actividadData = $actividad->getData();

            return $this->successResponse([
                'estadisticas' => is_object($estadisticasData) && isset($estadisticasData->data) 
                    ? $estadisticasData->data 
                    : $estadisticasData,
                'actividad_reciente' => is_object($actividadData) && isset($actividadData->data) 
                    ? $actividadData->data 
                    : $actividadData,
            ], 'Resumen del dashboard obtenido exitosamente');
        } catch (\Exception $e) {
            return $this->errorResponse(
                'Error al obtener resumen: ' . $e->getMessage(),
                ['error' => $e->getMessage(), 'file' => $e->getFile(), 'line' => $e->getLine()],
                500
            );
        }
    }
}