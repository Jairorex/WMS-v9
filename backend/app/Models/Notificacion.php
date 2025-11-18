<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notificacion extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.notificaciones';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'tipo_notificacion_id',
        'usuario_id',
        'titulo',
        'mensaje',
        'datos_adicionales',
        'prioridad',
        'estado',
        'fecha_envio',
        'fecha_lectura',
        'fecha_expiracion',
        'intentos_envio',
        'max_intentos',
        'error_ultimo_envio',
        'canales_enviados',
    ];

    protected $casts = [
        'datos_adicionales' => 'array',
        'canales_enviados' => 'array',
        'fecha_envio' => 'datetime',
        'fecha_lectura' => 'datetime',
        'fecha_expiracion' => 'datetime',
        'intentos_envio' => 'integer',
        'max_intentos' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function tipoNotificacion()
    {
        return $this->belongsTo(TipoNotificacion::class, 'tipo_notificacion_id', 'id');
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }

    public function colaNotificaciones()
    {
        return $this->hasMany(ColaNotificacion::class, 'notificacion_id', 'id');
    }

    public function logs()
    {
        return $this->hasMany(LogNotificacion::class, 'notificacion_id', 'id');
    }

    public function scopePendientes($query)
    {
        return $query->where('estado', 'pendiente');
    }

    public function scopeEnviadas($query)
    {
        return $query->where('estado', 'enviada');
    }

    public function scopeLeidas($query)
    {
        return $query->where('estado', 'leida');
    }

    public function scopePorUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function scopeRecientes($query, $horas = 24)
    {
        return $query->where('created_at', '>=', now()->subHours($horas));
    }

    public function scopeNoExpiradas($query)
    {
        return $query->where(function($q) {
            $q->whereNull('fecha_expiracion')
              ->orWhere('fecha_expiracion', '>', now());
        });
    }

    public function marcarComoLeida()
    {
        $this->update([
            'estado' => 'leida',
            'fecha_lectura' => now(),
        ]);
    }

    public function marcarComoEnviada($canales)
    {
        $this->update([
            'estado' => 'enviada',
            'fecha_envio' => now(),
            'canales_enviados' => is_array($canales) ? implode(',', $canales) : $canales,
        ]);
    }

    public function marcarComoFallida($error)
    {
        $this->update([
            'estado' => 'fallida',
            'error_ultimo_envio' => $error,
            'intentos_envio' => $this->intentos_envio + 1,
        ]);
    }

    public function getEstaExpiradaAttribute()
    {
        return $this->fecha_expiracion && $this->fecha_expiracion < now();
    }

    public function getPuedeReintentarAttribute()
    {
        return $this->intentos_envio < $this->max_intentos;
    }
}
