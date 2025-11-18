<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MetricaIncidencia extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.metricas_incidencias';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'fecha',
        'tipo_incidencia_id',
        'operario_id',
        'total_incidencias',
        'incidencias_resueltas',
        'incidencias_pendientes',
        'incidencias_escaladas',
        'tiempo_promedio_resolucion',
        'tiempo_total_resolucion',
        'costo_total',
        'satisfaccion_cliente',
        'eficiencia_resolucion',
    ];

    protected $casts = [
        'fecha' => 'date',
        'total_incidencias' => 'integer',
        'incidencias_resueltas' => 'integer',
        'incidencias_pendientes' => 'integer',
        'incidencias_escaladas' => 'integer',
        'tiempo_promedio_resolucion' => 'decimal:2',
        'tiempo_total_resolucion' => 'integer',
        'costo_total' => 'decimal:2',
        'satisfaccion_cliente' => 'decimal:2',
        'eficiencia_resolucion' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function tipoIncidencia()
    {
        return $this->belongsTo(TipoIncidencia::class, 'tipo_incidencia_id', 'id');
    }

    public function operario()
    {
        return $this->belongsTo(Usuario::class, 'operario_id', 'id_usuario');
    }

    // Scopes
    public function scopePorFecha($query, $fecha)
    {
        return $query->where('fecha', $fecha);
    }

    public function scopePorRangoFecha($query, $fechaInicio, $fechaFin)
    {
        return $query->whereBetween('fecha', [$fechaInicio, $fechaFin]);
    }

    public function scopePorTipoIncidencia($query, $tipoId)
    {
        return $query->where('tipo_incidencia_id', $tipoId);
    }

    public function scopePorOperario($query, $operarioId)
    {
        return $query->where('operario_id', $operarioId);
    }

    public function scopeConAltaEficiencia($query, $minimo = 80)
    {
        return $query->where('eficiencia_resolucion', '>=', $minimo);
    }

    public function scopeConBajaEficiencia($query, $maximo = 60)
    {
        return $query->where('eficiencia_resolucion', '<=', $maximo);
    }

    // Accessors
    public function getTiempoPromedioFormateadoAttribute()
    {
        if (!$this->tiempo_promedio_resolucion) return 'No disponible';
        
        $horas = floor($this->tiempo_promedio_resolucion / 60);
        $minutos = $this->tiempo_promedio_resolucion % 60;
        
        if ($horas > 0) {
            return "{$horas}h {$minutos}m";
        }
        
        return "{$minutos}m";
    }

    public function getTiempoTotalFormateadoAttribute()
    {
        if (!$this->tiempo_total_resolucion) return 'No disponible';
        
        $horas = floor($this->tiempo_total_resolucion / 60);
        $minutos = $this->tiempo_total_resolucion % 60;
        
        if ($horas > 0) {
            return "{$horas}h {$minutos}m";
        }
        
        return "{$minutos}m";
    }

    public function getPorcentajeResolucionAttribute()
    {
        if ($this->total_incidencias == 0) return 0;
        return round(($this->incidencias_resueltas / $this->total_incidencias) * 100, 2);
    }

    public function getPorcentajeEscaladoAttribute()
    {
        if ($this->total_incidencias == 0) return 0;
        return round(($this->incidencias_escaladas / $this->total_incidencias) * 100, 2);
    }

    public function getNivelSatisfaccionAttribute()
    {
        if (!$this->satisfaccion_cliente) return 'No evaluado';
        
        if ($this->satisfaccion_cliente >= 4.5) return 'Excelente';
        if ($this->satisfaccion_cliente >= 3.5) return 'Bueno';
        if ($this->satisfaccion_cliente >= 2.5) return 'Regular';
        return 'Malo';
    }

    public function getNivelEficienciaAttribute()
    {
        if ($this->eficiencia_resolucion >= 90) return 'Excelente';
        if ($this->eficiencia_resolucion >= 80) return 'Bueno';
        if ($this->eficiencia_resolucion >= 70) return 'Regular';
        return 'Necesita mejora';
    }

    // Métodos estáticos
    public static function calcularMetricas($fecha, $tipoIncidenciaId = null, $operarioId = null)
    {
        $query = Incidencia::whereDate('fecha_creacion', $fecha);

        if ($tipoIncidenciaId) {
            $query->where('tipo_incidencia_id', $tipoIncidenciaId);
        }

        if ($operarioId) {
            $query->where('id_operario', $operarioId);
        }

        $incidencias = $query->get();

        $totalIncidencias = $incidencias->count();
        $incidenciasResueltas = $incidencias->where('estado', 'RESUELTA')->count();
        $incidenciasPendientes = $incidencias->where('estado', 'PENDIENTE')->count();
        $incidenciasEscaladas = $incidencias->where('escalado', true)->count();

        $tiempoPromedioResolucion = $incidencias->whereNotNull('tiempo_resolucion_real')->avg('tiempo_resolucion_real');
        $tiempoTotalResolucion = $incidencias->whereNotNull('tiempo_resolucion_real')->sum('tiempo_resolucion_real');
        $costoTotal = $incidencias->sum('costo_real');

        $eficienciaResolucion = $totalIncidencias > 0 ? ($incidenciasResueltas / $totalIncidencias) * 100 : 0;

        return [
            'fecha' => $fecha,
            'tipo_incidencia_id' => $tipoIncidenciaId,
            'operario_id' => $operarioId,
            'total_incidencias' => $totalIncidencias,
            'incidencias_resueltas' => $incidenciasResueltas,
            'incidencias_pendientes' => $incidenciasPendientes,
            'incidencias_escaladas' => $incidenciasEscaladas,
            'tiempo_promedio_resolucion' => round($tiempoPromedioResolucion ?? 0, 2),
            'tiempo_total_resolucion' => $tiempoTotalResolucion ?? 0,
            'costo_total' => round($costoTotal ?? 0, 2),
            'eficiencia_resolucion' => round($eficienciaResolucion, 2),
        ];
    }

    public static function generarReporteDiario($fecha)
    {
        $metricas = self::calcularMetricas($fecha);
        
        // Guardar o actualizar métricas del día
        self::updateOrCreate(
            ['fecha' => $fecha, 'tipo_incidencia_id' => null, 'operario_id' => null],
            $metricas
        );

        return $metricas;
    }

    public static function generarReporteOperario($operarioId, $fecha)
    {
        $metricas = self::calcularMetricas($fecha, null, $operarioId);
        
        // Guardar o actualizar métricas del operario
        self::updateOrCreate(
            ['fecha' => $fecha, 'tipo_incidencia_id' => null, 'operario_id' => $operarioId],
            $metricas
        );

        return $metricas;
    }

    public static function generarReporteTipoIncidencia($tipoIncidenciaId, $fecha)
    {
        $metricas = self::calcularMetricas($fecha, $tipoIncidenciaId);
        
        // Guardar o actualizar métricas del tipo
        self::updateOrCreate(
            ['fecha' => $fecha, 'tipo_incidencia_id' => $tipoIncidenciaId, 'operario_id' => null],
            $metricas
        );

        return $metricas;
    }

    public static function obtenerTendencias($fechaInicio, $fechaFin, $tipoIncidenciaId = null, $operarioId = null)
    {
        $query = self::whereBetween('fecha', [$fechaInicio, $fechaFin]);

        if ($tipoIncidenciaId) {
            $query->where('tipo_incidencia_id', $tipoIncidenciaId);
        }

        if ($operarioId) {
            $query->where('operario_id', $operarioId);
        }

        $metricas = $query->orderBy('fecha')->get();

        return [
            'tendencia_total_incidencias' => $metricas->pluck('total_incidencias'),
            'tendencia_resolucion' => $metricas->pluck('eficiencia_resolucion'),
            'tendencia_tiempo_promedio' => $metricas->pluck('tiempo_promedio_resolucion'),
            'tendencia_costo' => $metricas->pluck('costo_total'),
            'fechas' => $metricas->pluck('fecha'),
        ];
    }

    public static function obtenerTopOperarios($fechaInicio, $fechaFin, $limite = 10)
    {
        return self::whereBetween('fecha', [$fechaInicio, $fechaFin])
            ->whereNotNull('operario_id')
            ->with('operario')
            ->orderBy('eficiencia_resolucion', 'desc')
            ->orderBy('incidencias_resueltas', 'desc')
            ->limit($limite)
            ->get();
    }

    public static function obtenerTiposMasProblematicos($fechaInicio, $fechaFin, $limite = 10)
    {
        return self::whereBetween('fecha', [$fechaInicio, $fechaFin])
            ->whereNotNull('tipo_incidencia_id')
            ->with('tipoIncidencia')
            ->orderBy('total_incidencias', 'desc')
            ->orderBy('incidencias_escaladas', 'desc')
            ->limit($limite)
            ->get();
    }
}
