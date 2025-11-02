<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ColaNotificacion extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'cola_notificaciones';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'notificacion_id',
        'canal',
        'estado',
        'fecha_programada',
        'fecha_procesado',
        'intentos',
        'max_intentos',
        'error_ultimo_intento',
        'datos_envio',
    ];

    protected $casts = [
        'datos_envio' => 'array',
        'fecha_programada' => 'datetime',
        'fecha_procesado' => 'datetime',
        'intentos' => 'integer',
        'max_intentos' => 'integer',
        'created_at' => 'datetime',
    ];

    public function notificacion()
    {
        return $this->belongsTo(Notificacion::class, 'notificacion_id', 'id');
    }

    public function scopePendientes($query)
    {
        return $query->where('estado', 'pendiente');
    }

    public function scopeProcesando($query)
    {
        return $query->where('estado', 'procesando');
    }

    public function scopeEnviadas($query)
    {
        return $query->where('estado', 'enviada');
    }

    public function scopeFallidas($query)
    {
        return $query->where('estado', 'fallida');
    }

    public function scopePorCanal($query, $canal)
    {
        return $query->where('canal', $canal);
    }

    public function scopeListasParaProcesar($query)
    {
        return $query->where('estado', 'pendiente')
                    ->where('fecha_programada', '<=', now());
    }

    public function scopeReintentables($query)
    {
        return $query->where('estado', 'fallida')
                    ->whereRaw('intentos < max_intentos');
    }

    public function marcarComoProcesando()
    {
        $this->update([
            'estado' => 'procesando',
            'intentos' => $this->intentos + 1,
        ]);
    }

    public function marcarComoEnviada()
    {
        $this->update([
            'estado' => 'enviada',
            'fecha_procesado' => now(),
        ]);
    }

    public function marcarComoFallida($error)
    {
        $this->update([
            'estado' => 'fallida',
            'error_ultimo_intento' => $error,
        ]);
    }

    public function getPuedeReintentarAttribute()
    {
        return $this->intentos < $this->max_intentos;
    }
}
