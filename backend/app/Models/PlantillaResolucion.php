<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlantillaResolucion extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'plantillas_resolucion';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'tipo_incidencia_id',
        'nombre',
        'descripcion',
        'pasos_resolucion',
        'tiempo_estimado',
        'requiere_aprobacion',
        'es_plantilla_default',
        'activo',
    ];

    protected $casts = [
        'pasos_resolucion' => 'array',
        'tiempo_estimado' => 'integer',
        'requiere_aprobacion' => 'boolean',
        'es_plantilla_default' => 'boolean',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function tipoIncidencia()
    {
        return $this->belongsTo(TipoIncidencia::class, 'tipo_incidencia_id', 'id');
    }

    // Scopes
    public function scopeActivas($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorTipoIncidencia($query, $tipoId)
    {
        return $query->where('tipo_incidencia_id', $tipoId);
    }

    public function scopeDefault($query)
    {
        return $query->where('es_plantilla_default', true);
    }

    public function scopeRequierenAprobacion($query)
    {
        return $query->where('requiere_aprobacion', true);
    }

    // Accessors
    public function getTiempoEstimadoFormateadoAttribute()
    {
        if (!$this->tiempo_estimado) return 'No definido';
        
        $horas = floor($this->tiempo_estimado / 60);
        $minutos = $this->tiempo_estimado % 60;
        
        if ($horas > 0) {
            return "{$horas}h {$minutos}m";
        }
        
        return "{$minutos}m";
    }

    public function getPasosFormateadosAttribute()
    {
        if (!$this->pasos_resolucion) return [];
        
        return array_map(function($paso, $index) {
            return [
                'numero' => $index + 1,
                'descripcion' => $paso,
                'completado' => false,
            ];
        }, $this->pasos_resolucion, array_keys($this->pasos_resolucion));
    }

    public function getEsDefaultFormateadoAttribute()
    {
        return $this->es_plantilla_default ? 'Sí' : 'No';
    }

    public function getRequiereAprobacionFormateadoAttribute()
    {
        return $this->requiere_aprobacion ? 'Sí' : 'No';
    }

    // Métodos
    public function aplicarAIncidencia($incidenciaId)
    {
        $incidencia = Incidencia::find($incidenciaId);
        
        if (!$incidencia) {
            throw new \Exception('Incidencia no encontrada');
        }

        // Actualizar la incidencia con los datos de la plantilla
        $incidencia->update([
            'tiempo_resolucion_estimado' => $this->tiempo_estimado,
            'fecha_estimada_resolucion' => now()->addMinutes($this->tiempo_estimado),
            'requiere_aprobacion' => $this->requiere_aprobacion,
        ]);

        // Registrar el seguimiento
        SeguimientoIncidencia::registrarAccion(
            $incidenciaId,
            'PLANTILLA_APLICADA',
            "Plantilla '{$this->nombre}' aplicada a la incidencia",
            [
                'observaciones' => "Pasos a seguir: " . implode(', ', $this->pasos_resolucion),
            ]
        );

        return $incidencia;
    }

    public function marcarComoDefault()
    {
        // Desmarcar otras plantillas default del mismo tipo
        self::where('tipo_incidencia_id', $this->tipo_incidencia_id)
            ->where('id', '!=', $this->id)
            ->update(['es_plantilla_default' => false]);

        // Marcar esta como default
        $this->update(['es_plantilla_default' => true]);

        return $this;
    }

    public function duplicar($nuevoNombre = null)
    {
        $nuevoNombre = $nuevoNombre ?? "Copia de {$this->nombre}";
        
        return self::create([
            'tipo_incidencia_id' => $this->tipo_incidencia_id,
            'nombre' => $nuevoNombre,
            'descripcion' => $this->descripcion,
            'pasos_resolucion' => $this->pasos_resolucion,
            'tiempo_estimado' => $this->tiempo_estimado,
            'requiere_aprobacion' => $this->requiere_aprobacion,
            'es_plantilla_default' => false,
            'activo' => true,
        ]);
    }

    public function calcularEficiencia()
    {
        // Calcular eficiencia basada en incidencias resueltas usando esta plantilla
        $incidenciasResueltas = Incidencia::where('tipo_incidencia_id', $this->tipo_incidencia_id)
            ->where('estado', 'RESUELTA')
            ->whereNotNull('tiempo_resolucion_real')
            ->get();

        if ($incidenciasResueltas->isEmpty()) {
            return 0;
        }

        $tiempoPromedioReal = $incidenciasResueltas->avg('tiempo_resolucion_real');
        
        if ($tiempoPromedioReal == 0) return 0;

        // Eficiencia = (tiempo estimado / tiempo real) * 100
        return round(($this->tiempo_estimado / $tiempoPromedioReal) * 100, 2);
    }

    public function obtenerEstadisticas()
    {
        $incidenciasUsadas = Incidencia::where('tipo_incidencia_id', $this->tipo_incidencia_id)
            ->where('estado', 'RESUELTA')
            ->get();

        return [
            'total_incidencias_resueltas' => $incidenciasUsadas->count(),
            'tiempo_promedio_real' => $incidenciasUsadas->avg('tiempo_resolucion_real'),
            'eficiencia_plantilla' => $this->calcularEficiencia(),
            'incidencias_escaladas' => $incidenciasUsadas->where('escalado', true)->count(),
            'costo_promedio' => $incidenciasUsadas->avg('costo_real'),
        ];
    }

    // Métodos estáticos
    public static function obtenerPlantillaDefault($tipoIncidenciaId)
    {
        return self::where('tipo_incidencia_id', $tipoIncidenciaId)
            ->where('es_plantilla_default', true)
            ->where('activo', true)
            ->first();
    }

    public static function obtenerPlantillasDisponibles($tipoIncidenciaId)
    {
        return self::where('tipo_incidencia_id', $tipoIncidenciaId)
            ->where('activo', true)
            ->orderBy('es_plantilla_default', 'desc')
            ->orderBy('nombre')
            ->get();
    }

    public static function crearPlantillaDesdeIncidencia($incidenciaId, $nombrePlantilla)
    {
        $incidencia = Incidencia::find($incidenciaId);
        
        if (!$incidencia || $incidencia->estado !== 'RESUELTA') {
            throw new \Exception('La incidencia debe estar resuelta para crear una plantilla');
        }

        $pasos = SeguimientoIncidencia::where('incidencia_id', $incidenciaId)
            ->where('accion', 'RESOLUCION')
            ->pluck('descripcion')
            ->toArray();

        return self::create([
            'tipo_incidencia_id' => $incidencia->tipo_incidencia_id,
            'nombre' => $nombrePlantilla,
            'descripcion' => "Plantilla creada desde incidencia #{$incidencia->id_incidencia}",
            'pasos_resolucion' => $pasos,
            'tiempo_estimado' => $incidencia->tiempo_resolucion_real ?? 30,
            'requiere_aprobacion' => $incidencia->requiere_aprobacion ?? false,
            'es_plantilla_default' => false,
            'activo' => true,
        ]);
    }
}
