<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RutaPicking extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.rutas_picking';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'oleada_id',
        'operario_id',
        'nombre_ruta',
        'secuencia',
        'ubicacion_id',
        'producto_id',
        'cantidad',
        'estado',
        'fecha_asignacion',
        'fecha_inicio',
        'fecha_fin',
        'tiempo_estimado',
        'tiempo_real',
        'distancia_estimada',
        'distancia_real',
        'observaciones',
    ];

    protected $casts = [
        'cantidad' => 'decimal:2',
        'fecha_asignacion' => 'datetime',
        'fecha_inicio' => 'datetime',
        'fecha_fin' => 'datetime',
        'tiempo_estimado' => 'integer',
        'tiempo_real' => 'integer',
        'distancia_estimada' => 'decimal:2',
        'distancia_real' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function oleada()
    {
        return $this->belongsTo(OleadaPicking::class, 'oleada_id', 'id');
    }

    public function operario()
    {
        return $this->belongsTo(Usuario::class, 'operario_id', 'id_usuario');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_id', 'id_ubicacion');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id', 'id_producto');
    }

    // Scopes
    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    public function scopePendientes($query)
    {
        return $query->where('estado', 'PENDIENTE');
    }

    public function scopeEnProceso($query)
    {
        return $query->where('estado', 'EN_PROCESO');
    }

    public function scopeCompletadas($query)
    {
        return $query->where('estado', 'COMPLETADA');
    }

    public function scopePorOperario($query, $operarioId)
    {
        return $query->where('operario_id', $operarioId);
    }

    public function scopePorOleada($query, $oleadaId)
    {
        return $query->where('oleada_id', $oleadaId);
    }

    public function scopeOrdenadas($query)
    {
        return $query->orderBy('secuencia');
    }

    // Accessors
    public function getTiempoTranscurridoAttribute()
    {
        if (!$this->fecha_inicio) return 0;
        $fechaFin = $this->fecha_fin ?? now();
        return $this->fecha_inicio->diffInMinutes($fechaFin);
    }

    public function getEficienciaTiempoAttribute()
    {
        if (!$this->tiempo_estimado || !$this->tiempo_real) return 0;
        return round(($this->tiempo_estimado / $this->tiempo_real) * 100, 2);
    }

    public function getEficienciaDistanciaAttribute()
    {
        if (!$this->distancia_estimada || !$this->distancia_real) return 0;
        return round(($this->distancia_estimada / $this->distancia_real) * 100, 2);
    }

    // Métodos
    public function iniciar()
    {
        $this->update([
            'estado' => 'EN_PROCESO',
            'fecha_inicio' => now(),
        ]);

        return $this;
    }

    public function completar($tiempoReal = null, $distanciaReal = null)
    {
        $tiempoReal = $tiempoReal ?? $this->tiempo_transcurrido;
        $distanciaReal = $distanciaReal ?? $this->distancia_estimada;

        $this->update([
            'estado' => 'COMPLETADA',
            'fecha_fin' => now(),
            'tiempo_real' => $tiempoReal,
            'distancia_real' => $distanciaReal,
        ]);

        return $this;
    }

    public function cancelar($motivo = null)
    {
        $this->update([
            'estado' => 'CANCELADA',
            'fecha_fin' => now(),
            'observaciones' => $motivo,
        ]);

        return $this;
    }
}
