<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LogNotificacion extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'logs_notificaciones';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'notificacion_id',
        'canal',
        'accion',
        'estado',
        'mensaje',
        'datos_adicionales',
        'fecha_accion',
    ];

    protected $casts = [
        'datos_adicionales' => 'array',
        'fecha_accion' => 'datetime',
    ];

    public function notificacion()
    {
        return $this->belongsTo(Notificacion::class, 'notificacion_id', 'id');
    }

    public function scopeExitosos($query)
    {
        return $query->where('estado', 'exitoso');
    }

    public function scopeFallidos($query)
    {
        return $query->where('estado', 'fallido');
    }

    public function scopePorCanal($query, $canal)
    {
        return $query->where('canal', $canal);
    }

    public function scopePorAccion($query, $accion)
    {
        return $query->where('accion', $accion);
    }

    public function scopeRecientes($query, $horas = 24)
    {
        return $query->where('fecha_accion', '>=', now()->subHours($horas));
    }

    public function scopePorPeriodo($query, $fechaInicio, $fechaFin)
    {
        return $query->whereBetween('fecha_accion', [$fechaInicio, $fechaFin]);
    }
}
