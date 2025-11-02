<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SeguimientoIncidencia extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'seguimiento_incidencias';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'incidencia_id',
        'usuario_id',
        'accion',
        'descripcion',
        'estado_anterior',
        'estado_nuevo',
        'fecha_seguimiento',
        'archivos_adjuntos',
        'tiempo_invertido',
        'observaciones',
    ];

    protected $casts = [
        'fecha_seguimiento' => 'datetime',
        'tiempo_invertido' => 'integer',
        'archivos_adjuntos' => 'array',
    ];

    // Relaciones
    public function incidencia()
    {
        return $this->belongsTo(Incidencia::class, 'incidencia_id', 'id_incidencia');
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }

    // Scopes
    public function scopePorIncidencia($query, $incidenciaId)
    {
        return $query->where('incidencia_id', $incidenciaId);
    }

    public function scopePorUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopePorAccion($query, $accion)
    {
        return $query->where('accion', $accion);
    }

    public function scopePorFecha($query, $fechaInicio, $fechaFin = null)
    {
        $query->where('fecha_seguimiento', '>=', $fechaInicio);
        
        if ($fechaFin) {
            $query->where('fecha_seguimiento', '<=', $fechaFin);
        }
        
        return $query;
    }

    public function scopeCambiosEstado($query)
    {
        return $query->whereNotNull('estado_anterior')
                    ->whereNotNull('estado_nuevo');
    }

    public function scopeConTiempo($query)
    {
        return $query->whereNotNull('tiempo_invertido')
                    ->where('tiempo_invertido', '>', 0);
    }

    // Accessors
    public function getTiempoInvertidoFormateadoAttribute()
    {
        if (!$this->tiempo_invertido) return 'No registrado';
        
        $horas = floor($this->tiempo_invertido / 60);
        $minutos = $this->tiempo_invertido % 60;
        
        if ($horas > 0) {
            return "{$horas}h {$minutos}m";
        }
        
        return "{$minutos}m";
    }

    public function getTieneArchivosAttribute()
    {
        return !empty($this->archivos_adjuntos);
    }

    public function getEsCambioEstadoAttribute()
    {
        return !is_null($this->estado_anterior) && !is_null($this->estado_nuevo);
    }

    // Métodos estáticos
    public static function registrarAccion($incidenciaId, $accion, $descripcion, $datos = [])
    {
        return self::create(array_merge([
            'incidencia_id' => $incidenciaId,
            'usuario_id' => auth()->id(),
            'accion' => $accion,
            'descripcion' => $descripcion,
            'fecha_seguimiento' => now(),
        ], $datos));
    }

    public static function registrarCambioEstado($incidenciaId, $estadoAnterior, $estadoNuevo, $descripcion = null)
    {
        $descripcion = $descripcion ?? "Estado cambiado de {$estadoAnterior} a {$estadoNuevo}";
        
        return self::registrarAccion($incidenciaId, 'CAMBIO_ESTADO', $descripcion, [
            'estado_anterior' => $estadoAnterior,
            'estado_nuevo' => $estadoNuevo,
        ]);
    }

    public static function registrarComentario($incidenciaId, $comentario, $tiempoInvertido = null)
    {
        return self::registrarAccion($incidenciaId, 'COMENTARIO', $comentario, [
            'tiempo_invertido' => $tiempoInvertido,
        ]);
    }

    public static function registrarArchivo($incidenciaId, $archivos, $descripcion = null)
    {
        $descripcion = $descripcion ?? 'Archivos adjuntos agregados';
        
        return self::registrarAccion($incidenciaId, 'ARCHIVO_ADJUNTO', $descripcion, [
            'archivos_adjuntos' => $archivos,
        ]);
    }

    public static function registrarEscalado($incidenciaId, $nivelAnterior, $nivelNuevo, $motivo = null)
    {
        $descripcion = $motivo ?? "Incidencia escalada del nivel {$nivelAnterior} al nivel {$nivelNuevo}";
        
        return self::registrarAccion($incidenciaId, 'ESCALADO', $descripcion, [
            'estado_anterior' => $nivelAnterior,
            'estado_nuevo' => $nivelNuevo,
        ]);
    }

    public static function registrarResolucion($incidenciaId, $solucion, $tiempoInvertido = null)
    {
        return self::registrarAccion($incidenciaId, 'RESOLUCION', $solucion, [
            'tiempo_invertido' => $tiempoInvertido,
        ]);
    }

    public static function obtenerHistorialCompleto($incidenciaId)
    {
        return self::where('incidencia_id', $incidenciaId)
            ->with(['usuario'])
            ->orderBy('fecha_seguimiento', 'asc')
            ->get();
    }

    public static function calcularTiempoTotalInvertido($incidenciaId)
    {
        return self::where('incidencia_id', $incidenciaId)
            ->whereNotNull('tiempo_invertido')
            ->sum('tiempo_invertido');
    }

    public static function obtenerEstadisticasUsuario($usuarioId, $fechaInicio = null, $fechaFin = null)
    {
        $query = self::where('usuario_id', $usuarioId);

        if ($fechaInicio) {
            $query->where('fecha_seguimiento', '>=', $fechaInicio);
        }

        if ($fechaFin) {
            $query->where('fecha_seguimiento', '<=', $fechaFin);
        }

        $seguimientos = $query->get();

        return [
            'total_acciones' => $seguimientos->count(),
            'tiempo_total_invertido' => $seguimientos->sum('tiempo_invertido'),
            'cambios_estado' => $seguimientos->where('accion', 'CAMBIO_ESTADO')->count(),
            'comentarios' => $seguimientos->where('accion', 'COMENTARIO')->count(),
            'archivos_adjuntos' => $seguimientos->where('accion', 'ARCHIVO_ADJUNTO')->count(),
            'escalados' => $seguimientos->where('accion', 'ESCALADO')->count(),
            'resoluciones' => $seguimientos->where('accion', 'RESOLUCION')->count(),
        ];
    }
}
