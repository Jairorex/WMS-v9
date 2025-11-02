<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KpiSistema;
use App\Models\KpiHistorico;
use App\Models\AlertaDashboard;
use App\Models\WidgetDashboard;
use App\Models\MetricaTiempoReal;
use App\Models\OleadaPicking;
use App\Models\Incidencia;
use App\Models\Inventario;
use App\Models\Ubicacion;
use App\Models\PedidoPicking;
use App\Models\Lote;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Obtener estadísticas generales del dashboard
     */
    public function estadisticas(): JsonResponse
    {
        $estadisticas = [
            'resumen_general' => $this->obtenerResumenGeneral(),
            'kpis_principales' => $this->obtenerKpisPrincipales(),
            'alertas_activas' => $this->obtenerAlertasActivas(),
            'metricas_tiempo_real' => $this->obtenerMetricasTiempoReal(),
            'tendencias' => $this->obtenerTendencias(),
        ];

        return response()->json($estadisticas);
    }

    /**
     * Obtener resumen general del sistema
     */
    private function obtenerResumenGeneral(): array
    {
        return [
            'picking_activos' => OleadaPicking::where('estado', 'en_proceso')->count(),
            'incidencias_abiertas' => Incidencia::where('estado', 'abierta')->count(),
            'inventario_total' => Inventario::sum('cantidad'),
            'ubicaciones_ocupadas' => Ubicacion::whereHas('inventario')->count(),
            'operarios_activos' => DB::table('usuarios')->where('activo', true)->count(),
            'pedidos_pendientes' => PedidoPicking::where('estado', 'pendiente')->count(),
            'lotes_vencidos' => Lote::where('fecha_vencimiento', '<', now())->count(),
        ];
    }

    /**
     * Obtener KPIs principales con valores actuales
     */
    private function obtenerKpisPrincipales(): array
    {
        $kpis = KpiSistema::activos()
            ->with(['historicos' => function($query) {
                $query->latest('fecha_medicion')->limit(1);
            }])
            ->get()
            ->map(function($kpi) {
                $ultimoValor = $kpi->historicos->first();
                return [
                    'id' => $kpi->id,
                    'codigo' => $kpi->codigo,
                    'nombre' => $kpi->nombre,
                    'categoria' => $kpi->categoria,
                    'tipo_metrica' => $kpi->tipo_metrica,
                    'unidad' => $kpi->unidad,
                    'valor_actual' => $ultimoValor?->valor ?? 0,
                    'valor_objetivo' => $kpi->valor_objetivo,
                    'valor_minimo' => $kpi->valor_minimo,
                    'valor_maximo' => $kpi->valor_maximo,
                    'tendencia' => $ultimoValor?->tendencia ?? 'estable',
                    'estado' => $this->calcularEstadoKpi($ultimoValor?->valor ?? 0, $kpi),
                    'fecha_actualizacion' => $ultimoValor?->fecha_medicion,
                ];
            });

        return $kpis->groupBy('categoria')->toArray();
    }

    /**
     * Obtener alertas activas
     */
    private function obtenerAlertasActivas(): array
    {
        return AlertaDashboard::activas()
            ->with(['kpi', 'usuarioNotificado'])
            ->orderBy('nivel_criticidad', 'desc')
            ->orderBy('fecha_alerta', 'desc')
            ->limit(10)
            ->get()
            ->map(function($alerta) {
                return [
                    'id' => $alerta->id,
                    'kpi_nombre' => $alerta->kpi->nombre,
                    'tipo_alerta' => $alerta->tipo_alerta,
                    'nivel_criticidad' => $alerta->nivel_criticidad,
                    'mensaje' => $alerta->mensaje,
                    'valor_actual' => $alerta->valor_actual,
                    'valor_umbral' => $alerta->valor_umbral,
                    'fecha_alerta' => $alerta->fecha_alerta,
                    'usuario_notificado' => $alerta->usuarioNotificado?->nombre,
                ];
            })
            ->toArray();
    }

    /**
     * Obtener métricas en tiempo real
     */
    private function obtenerMetricasTiempoReal(): array
    {
        return MetricaTiempoReal::activos()
            ->orderBy('fecha_actualizacion', 'desc')
            ->get()
            ->map(function($metrica) {
                return [
                    'codigo' => $metrica->codigo_metrica,
                    'nombre' => $metrica->nombre,
                    'valor_actual' => $metrica->valor_actual,
                    'valor_anterior' => $metrica->valor_anterior,
                    'variacion' => $metrica->variacion,
                    'tendencia' => $metrica->tendencia,
                    'fecha_actualizacion' => $metrica->fecha_actualizacion,
                    'fuente_datos' => $metrica->fuente_datos,
                ];
            })
            ->toArray();
    }

    /**
     * Obtener tendencias de KPIs
     */
    private function obtenerTendencias(): array
    {
        $fechaInicio = now()->subDays(7);
        $fechaFin = now();

        $tendencias = KpiSistema::activos()
            ->with(['historicos' => function($query) use ($fechaInicio, $fechaFin) {
                $query->whereBetween('fecha_medicion', [$fechaInicio, $fechaFin])
                      ->orderBy('fecha_medicion');
            }])
            ->get()
            ->map(function($kpi) {
                $valores = $kpi->historicos->pluck('valor')->toArray();
                return [
                    'kpi_codigo' => $kpi->codigo,
                    'kpi_nombre' => $kpi->nombre,
                    'valores' => $valores,
                    'tendencia_general' => $this->calcularTendenciaGeneral($valores),
                    'variacion_total' => $this->calcularVariacionTotal($valores),
                ];
            });

        return $tendencias->toArray();
    }

    /**
     * Calcular estado del KPI basado en su valor actual
     */
    private function calcularEstadoKpi($valorActual, $kpi): string
    {
        if ($valorActual >= $kpi->valor_objetivo) {
            return 'excelente';
        } elseif ($valorActual >= $kpi->valor_minimo) {
            return 'bueno';
        } else {
            return 'critico';
        }
    }

    /**
     * Calcular tendencia general de un array de valores
     */
    private function calcularTendenciaGeneral($valores): string
    {
        if (count($valores) < 2) {
            return 'estable';
        }

        $primero = $valores[0];
        $ultimo = end($valores);

        if ($ultimo > $primero * 1.05) {
            return 'ascendente';
        } elseif ($ultimo < $primero * 0.95) {
            return 'descendente';
        }

        return 'estable';
    }

    /**
     * Calcular variación total de un array de valores
     */
    private function calcularVariacionTotal($valores): float
    {
        if (count($valores) < 2) {
            return 0;
        }

        $primero = $valores[0];
        $ultimo = end($valores);

        if ($primero > 0) {
            return (($ultimo - $primero) / $primero) * 100;
        }

        return 0;
    }

    /**
     * Obtener datos para gráficos específicos
     */
    public function datosGrafico(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'tipo_grafico' => 'required|in:linea,barras,pie,area',
            'kpi_codigo' => 'required|string',
            'periodo' => 'required|in:1h,6h,24h,7d,30d',
        ]);

        $periodos = [
            '1h' => now()->subHour(),
            '6h' => now()->subHours(6),
            '24h' => now()->subDay(),
            '7d' => now()->subDays(7),
            '30d' => now()->subDays(30),
        ];

        $fechaInicio = $periodos[$validated['periodo']];
        $fechaFin = now();

        $kpi = KpiSistema::where('codigo', $validated['kpi_codigo'])->first();
        
        if (!$kpi) {
            return response()->json(['error' => 'KPI no encontrado'], 404);
        }

        $datos = KpiHistorico::where('kpi_id', $kpi->id)
            ->whereBetween('fecha_medicion', [$fechaInicio, $fechaFin])
            ->orderBy('fecha_medicion')
            ->get()
            ->map(function($registro) {
                return [
                    'fecha' => $registro->fecha_medicion->format('Y-m-d H:i:s'),
                    'valor' => $registro->valor,
                    'tendencia' => $registro->tendencia,
                ];
            });

        return response()->json([
            'kpi' => [
                'codigo' => $kpi->codigo,
                'nombre' => $kpi->nombre,
                'unidad' => $kpi->unidad,
            ],
            'datos' => $datos,
            'periodo' => $validated['periodo'],
            'fecha_inicio' => $fechaInicio,
            'fecha_fin' => $fechaFin,
        ]);
    }

    /**
     * Actualizar valor de KPI
     */
    public function actualizarKpi(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'kpi_codigo' => 'required|string',
            'valor' => 'required|numeric',
            'observaciones' => 'nullable|string|max:500',
        ]);

        $kpi = KpiSistema::where('codigo', $validated['kpi_codigo'])->first();
        
        if (!$kpi) {
            return response()->json(['error' => 'KPI no encontrado'], 404);
        }

        // Obtener valor anterior
        $valorAnterior = KpiHistorico::where('kpi_id', $kpi->id)
            ->latest('fecha_medicion')
            ->first()?->valor ?? 0;

        // Determinar tendencia
        $tendencia = 'estable';
        if ($validated['valor'] > $valorAnterior * 1.05) {
            $tendencia = 'ascendente';
        } elseif ($validated['valor'] < $valorAnterior * 0.95) {
            $tendencia = 'descendente';
        }

        // Crear nuevo registro histórico
        $historico = KpiHistorico::create([
            'kpi_id' => $kpi->id,
            'fecha_medicion' => now(),
            'valor' => $validated['valor'],
            'valor_anterior' => $valorAnterior,
            'tendencia' => $tendencia,
            'observaciones' => $validated['observaciones'],
        ]);

        // Verificar alertas
        $this->verificarAlertas($kpi, $validated['valor']);

        return response()->json([
            'mensaje' => 'KPI actualizado exitosamente',
            'historico' => $historico,
            'tendencia' => $tendencia,
        ]);
    }

    /**
     * Verificar alertas para un KPI
     */
    private function verificarAlertas($kpi, $valorActual): void
    {
        // Verificar si ya hay alertas activas
        $alertaActiva = AlertaDashboard::where('kpi_id', $kpi->id)
            ->where('estado', 'activa')
            ->exists();

        if (!$alertaActiva) {
            // Alerta por valor superior al máximo
            if ($valorActual > $kpi->valor_maximo) {
                AlertaDashboard::create([
                    'kpi_id' => $kpi->id,
                    'tipo_alerta' => 'umbral_superado',
                    'nivel_criticidad' => 'alta',
                    'mensaje' => "El KPI {$kpi->nombre} ha superado el valor máximo permitido",
                    'valor_actual' => $valorActual,
                    'valor_umbral' => $kpi->valor_maximo,
                ]);
            }

            // Alerta por valor inferior al mínimo
            if ($valorActual < $kpi->valor_minimo) {
                AlertaDashboard::create([
                    'kpi_id' => $kpi->id,
                    'tipo_alerta' => 'umbral_inferior',
                    'nivel_criticidad' => 'alta',
                    'mensaje' => "El KPI {$kpi->nombre} está por debajo del valor mínimo requerido",
                    'valor_actual' => $valorActual,
                    'valor_umbral' => $kpi->valor_minimo,
                ]);
            }
        }
    }

    /**
     * Resolver alerta
     */
    public function resolverAlerta(Request $request, $alertaId): JsonResponse
    {
        $validated = $request->validate([
            'observaciones' => 'nullable|string|max:500',
        ]);

        $alerta = AlertaDashboard::findOrFail($alertaId);
        $alerta->resolver($validated['observaciones']);

        return response()->json([
            'mensaje' => 'Alerta resuelta exitosamente',
            'alerta' => $alerta,
        ]);
    }

    /**
     * Obtener widgets del dashboard
     */
    public function widgets(Request $request): JsonResponse
    {
        $usuarioId = auth()->id();
        
        $widgets = WidgetDashboard::porUsuario($usuarioId)
            ->activos()
            ->orderBy('posicion_y')
            ->orderBy('posicion_x')
            ->get();

        return response()->json($widgets);
    }

    /**
     * Crear o actualizar widget
     */
    public function guardarWidget(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nombre' => 'required|string|max:100',
            'tipo_widget' => 'required|string|max:30',
            'configuracion' => 'nullable|array',
            'posicion_x' => 'required|integer|min:0',
            'posicion_y' => 'required|integer|min:0',
            'ancho' => 'required|integer|min:1|max:12',
            'alto' => 'required|integer|min:1|max:12',
            'es_global' => 'boolean',
        ]);

        $validated['usuario_id'] = auth()->id();

        $widget = WidgetDashboard::create($validated);

        return response()->json($widget, 201);
    }

    /**
     * Eliminar widget
     */
    public function eliminarWidget($widgetId): JsonResponse
    {
        $widget = WidgetDashboard::findOrFail($widgetId);
        
        // Verificar permisos
        if ($widget->usuario_id !== auth()->id() && !$widget->es_global) {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $widget->delete();

        return response()->json(['mensaje' => 'Widget eliminado exitosamente']);
    }
}
