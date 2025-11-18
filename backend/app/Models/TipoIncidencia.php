<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TipoIncidencia extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.tipos_incidencia';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo',
        'nombre',
        'descripcion',
        'categoria',
        'tiempo_resolucion_estimado',
        'es_critica',
        'requiere_aprobacion',
        'activo',
    ];

    protected $casts = [
        'tiempo_resolucion_estimado' => 'integer',
        'es_critica' => 'boolean',
        'requiere_aprobacion' => 'boolean',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function incidencias()
    {
        return $this->hasMany(Incidencia::class, 'tipo_incidencia_id', 'id');
    }

    public function plantillas()
    {
        return $this->hasMany(PlantillaResolucion::class, 'tipo_incidencia_id', 'id');
    }

    public function plantillaDefault()
    {
        return $this->hasOne(PlantillaResolucion::class, 'tipo_incidencia_id', 'id')
                    ->where('es_plantilla_default', true);
    }

    public function metricas()
    {
        return $this->hasMany(MetricaIncidencia::class, 'tipo_incidencia_id', 'id');
    }

    // Scopes
    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }

    public function scopeCriticas($query)
    {
        return $query->where('es_critica', true);
    }

    public function scopeRequierenAprobacion($query)
    {
        return $query->where('requiere_aprobacion', true);
    }

    public function scopePorCodigo($query, $codigo)
    {
        return $query->where('codigo', $codigo);
    }

    // Accessors
    public function getTiempoResolucionFormateadoAttribute()
    {
        if (!$this->tiempo_resolucion_estimado) return 'No definido';
        
        $horas = floor($this->tiempo_resolucion_estimado / 60);
        $minutos = $this->tiempo_resolucion_estimado % 60;
        
        if ($horas > 0) {
            return "{$horas}h {$minutos}m";
        }
        
        return "{$minutos}m";
    }

    public function getEsCriticaFormateadoAttribute()
    {
        return $this->es_critica ? 'Sí' : 'No';
    }

    public function getRequiereAprobacionFormateadoAttribute()
    {
        return $this->requiere_aprobacion ? 'Sí' : 'No';
    }

    // Métodos
    public function calcularTiempoPromedioResolucion()
    {
        $incidenciasResueltas = $this->incidencias()
            ->whereNotNull('tiempo_resolucion_real')
            ->get();

        if ($incidenciasResueltas->isEmpty()) {
            return 0;
        }

        return $incidenciasResueltas->avg('tiempo_resolucion_real');
    }

    public function calcularEficienciaResolucion()
    {
        $totalIncidencias = $this->incidencias()->count();
        $incidenciasResueltas = $this->incidencias()
            ->where('estado', 'RESUELTA')
            ->count();

        if ($totalIncidencias == 0) return 0;

        return round(($incidenciasResueltas / $totalIncidencias) * 100, 2);
    }

    public function obtenerEstadisticas($fechaInicio = null, $fechaFin = null)
    {
        $query = $this->incidencias();

        if ($fechaInicio) {
            $query->where('fecha_creacion', '>=', $fechaInicio);
        }

        if ($fechaFin) {
            $query->where('fecha_creacion', '<=', $fechaFin);
        }

        $incidencias = $query->get();

        return [
            'total' => $incidencias->count(),
            'pendientes' => $incidencias->where('estado', 'PENDIENTE')->count(),
            'en_proceso' => $incidencias->where('estado', 'EN_PROCESO')->count(),
            'resueltas' => $incidencias->where('estado', 'RESUELTA')->count(),
            'escaladas' => $incidencias->where('escalado', true)->count(),
            'tiempo_promedio_resolucion' => $incidencias->whereNotNull('tiempo_resolucion_real')->avg('tiempo_resolucion_real'),
            'costo_total' => $incidencias->sum('costo_real'),
        ];
    }
}
