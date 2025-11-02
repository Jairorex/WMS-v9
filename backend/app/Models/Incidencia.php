<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Incidencia extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'incidencias';
    protected $primaryKey = 'id_incidencia';
    public $timestamps = true;

    protected $fillable = [
        'id_tarea',
        'id_operario',
        'id_producto',
        'descripcion',
        'estado',
        'fecha_reporte',
        'fecha_resolucion',
        'tipo_incidencia_id',
        'prioridad',
        'categoria',
        'fecha_estimada_resolucion',
        'fecha_resolucion_real',
        'tiempo_resolucion_estimado',
        'tiempo_resolucion_real',
        'operario_resolucion',
        'supervisor_aprobacion',
        'fecha_aprobacion',
        'evidencia_fotos',
        'acciones_correctivas',
        'acciones_preventivas',
        'costo_estimado',
        'costo_real',
        'impacto_operaciones',
        'recurrencia',
        'incidencia_padre_id',
        'escalado',
        'fecha_escalado',
        'nivel_escalado',
        'activo',
    ];

    protected $casts = [
        'fecha_reporte' => 'datetime',
        'fecha_resolucion' => 'datetime',
        'fecha_estimada_resolucion' => 'datetime',
        'fecha_resolucion_real' => 'datetime',
        'fecha_aprobacion' => 'datetime',
        'fecha_escalado' => 'datetime',
        'tiempo_resolucion_estimado' => 'integer',
        'tiempo_resolucion_real' => 'integer',
        'costo_estimado' => 'decimal:2',
        'costo_real' => 'decimal:2',
        'recurrencia' => 'boolean',
        'escalado' => 'boolean',
        'nivel_escalado' => 'integer',
        'activo' => 'boolean',
        'evidencia_fotos' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function tarea()
    {
        return $this->belongsTo(Tarea::class, 'id_tarea', 'id_tarea');
    }

    public function operario()
    {
        return $this->belongsTo(Usuario::class, 'id_operario', 'id_usuario');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    public function tipoIncidencia()
    {
        return $this->belongsTo(TipoIncidencia::class, 'tipo_incidencia_id', 'id');
    }

    public function operarioResolucion()
    {
        return $this->belongsTo(Usuario::class, 'operario_resolucion', 'id_usuario');
    }

    public function supervisorAprobacion()
    {
        return $this->belongsTo(Usuario::class, 'supervisor_aprobacion', 'id_usuario');
    }

    public function incidenciaPadre()
    {
        return $this->belongsTo(Incidencia::class, 'incidencia_padre_id', 'id_incidencia');
    }

    public function incidenciasHijas()
    {
        return $this->hasMany(Incidencia::class, 'incidencia_padre_id', 'id_incidencia');
    }

    public function seguimientos()
    {
        return $this->hasMany(SeguimientoIncidencia::class, 'incidencia_id', 'id_incidencia');
    }

    // Scopes
    public function scopePendientes($query)
    {
        return $query->where('estado', 'Pendiente');
    }

    public function scopeResueltas($query)
    {
        return $query->where('estado', 'Resuelta');
    }

    public function scopePorOperario($query, $operarioId)
    {
        return $query->where('id_operario', $operarioId);
    }

    public function scopeActivas($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorTipoIncidencia($query, $tipoId)
    {
        return $query->where('tipo_incidencia_id', $tipoId);
    }

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function scopePorCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }

    public function scopeCriticas($query)
    {
        return $query->where('prioridad', 'CRITICA');
    }

    public function scopeEscaladas($query)
    {
        return $query->where('escalado', true);
    }

    public function scopeVencidas($query)
    {
        return $query->where('fecha_estimada_resolucion', '<', now())
                    ->where('estado', '!=', 'RESUELTA');
    }

    public function scopePorVencer($query, $horas = 24)
    {
        return $query->where('fecha_estimada_resolucion', '<=', now()->addHours($horas))
                    ->where('fecha_estimada_resolucion', '>', now())
                    ->where('estado', '!=', 'RESUELTA');
    }

    public function scopeRequierenAprobacion($query)
    {
        return $query->whereNotNull('supervisor_aprobacion')
                    ->whereNull('fecha_aprobacion');
    }

    public function scopeRecurrentes($query)
    {
        return $query->where('recurrencia', true);
    }

    public function scopePorProducto($query, $productoId)
    {
        return $query->where('id_producto', $productoId);
    }

    // Accessors
    public function getTiempoResolucionFormateadoAttribute()
    {
        if (!$this->tiempo_resolucion_real) return 'No disponible';
        
        $horas = floor($this->tiempo_resolucion_real / 60);
        $minutos = $this->tiempo_resolucion_real % 60;
        
        if ($horas > 0) {
            return "{$horas}h {$minutos}m";
        }
        
        return "{$minutos}m";
    }

    public function getEstaVencidaAttribute()
    {
        return $this->fecha_estimada_resolucion && 
               $this->fecha_estimada_resolucion < now() && 
               $this->estado !== 'RESUELTA';
    }

    public function getEstaPorVencerAttribute()
    {
        return $this->fecha_estimada_resolucion && 
               $this->fecha_estimada_resolucion <= now()->addHours(24) && 
               $this->fecha_estimada_resolucion > now() && 
               $this->estado !== 'RESUELTA';
    }

    public function getTiempoRestanteAttribute()
    {
        if (!$this->fecha_estimada_resolucion || $this->estado === 'RESUELTA') return 0;
        return now()->diffInMinutes($this->fecha_estimada_resolucion, false);
    }

    public function getEficienciaResolucionAttribute()
    {
        if (!$this->tiempo_resolucion_estimado || !$this->tiempo_resolucion_real) return 0;
        return round(($this->tiempo_resolucion_estimado / $this->tiempo_resolucion_real) * 100, 2);
    }

    public function getTieneEvidenciaAttribute()
    {
        return !empty($this->evidencia_fotos);
    }

    public function getRequiereAprobacionAttribute()
    {
        return !is_null($this->supervisor_aprobacion) && is_null($this->fecha_aprobacion);
    }

    // Métodos
    public function escalar($nivelNuevo, $motivo = null)
    {
        $nivelAnterior = $this->nivel_escalado;
        
        $this->update([
            'escalado' => true,
            'fecha_escalado' => now(),
            'nivel_escalado' => $nivelNuevo,
        ]);

        // Registrar seguimiento
        SeguimientoIncidencia::registrarEscalado(
            $this->id_incidencia,
            $nivelAnterior,
            $nivelNuevo,
            $motivo
        );

        return $this;
    }

    public function resolver($solucion, $tiempoReal = null, $costoReal = null)
    {
        $tiempoReal = $tiempoReal ?? $this->calcularTiempoReal();
        
        $this->update([
            'estado' => 'RESUELTA',
            'fecha_resolucion_real' => now(),
            'tiempo_resolucion_real' => $tiempoReal,
            'costo_real' => $costoReal,
            'operario_resolucion' => auth()->id(),
        ]);

        // Registrar seguimiento
        SeguimientoIncidencia::registrarResolucion(
            $this->id_incidencia,
            $solucion,
            $tiempoReal
        );

        return $this;
    }

    public function aprobar($supervisorId = null)
    {
        $this->update([
            'fecha_aprobacion' => now(),
            'supervisor_aprobacion' => $supervisorId ?? auth()->id(),
        ]);

        // Registrar seguimiento
        SeguimientoIncidencia::registrarAccion(
            $this->id_incidencia,
            'APROBACION',
            'Incidencia aprobada por supervisor'
        );

        return $this;
    }

    public function agregarComentario($comentario, $tiempoInvertido = null)
    {
        SeguimientoIncidencia::registrarComentario(
            $this->id_incidencia,
            $comentario,
            $tiempoInvertido
        );

        return $this;
    }

    public function agregarEvidencia($archivos)
    {
        $evidenciaActual = $this->evidencia_fotos ?? [];
        $evidenciaNueva = array_merge($evidenciaActual, $archivos);
        
        $this->update(['evidencia_fotos' => $evidenciaNueva]);

        SeguimientoIncidencia::registrarArchivo(
            $this->id_incidencia,
            $archivos,
            'Evidencia fotográfica agregada'
        );

        return $this;
    }

    public function calcularTiempoReal()
    {
        return SeguimientoIncidencia::calcularTiempoTotalInvertido($this->id_incidencia);
    }

    public function aplicarPlantilla($plantillaId)
    {
        $plantilla = PlantillaResolucion::find($plantillaId);
        
        if (!$plantilla) {
            throw new \Exception('Plantilla no encontrada');
        }

        return $plantilla->aplicarAIncidencia($this->id_incidencia);
    }

    public function marcarComoRecurrente()
    {
        $this->update(['recurrencia' => true]);

        SeguimientoIncidencia::registrarAccion(
            $this->id_incidencia,
            'MARCAR_RECURRENTE',
            'Incidencia marcada como recurrente'
        );

        return $this;
    }

    public function crearIncidenciaRelacionada($datos)
    {
        $datos['incidencia_padre_id'] = $this->id_incidencia;
        $datos['recurrencia'] = true;
        
        return Incidencia::create($datos);
    }

    public function obtenerHistorialCompleto()
    {
        return SeguimientoIncidencia::obtenerHistorialCompleto($this->id_incidencia);
    }

    public function calcularMetricas()
    {
        return [
            'tiempo_total_invertido' => $this->calcularTiempoReal(),
            'eficiencia_resolucion' => $this->eficiencia_resolucion,
            'costo_total' => $this->costo_real ?? 0,
            'total_seguimientos' => $this->seguimientos()->count(),
            'total_archivos' => count($this->evidencia_fotos ?? []),
            'es_recurrente' => $this->recurrencia,
            'nivel_escalado' => $this->nivel_escalado,
        ];
    }
}
