<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ConfiguracionNotificacionUsuario extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'configuracion_notificaciones_usuario';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'usuario_id',
        'tipo_notificacion_id',
        'recibir_email',
        'recibir_push',
        'recibir_web',
        'frecuencia_resumen',
        'hora_resumen',
        'dias_resumen',
        'activo',
    ];

    protected $casts = [
        'recibir_email' => 'boolean',
        'recibir_push' => 'boolean',
        'recibir_web' => 'boolean',
        'dias_resumen' => 'array',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }

    public function tipoNotificacion()
    {
        return $this->belongsTo(TipoNotificacion::class, 'tipo_notificacion_id', 'id');
    }

    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopePorTipo($query, $tipoId)
    {
        return $query->where('tipo_notificacion_id', $tipoId);
    }

    public function getCanalesHabilitadosAttribute()
    {
        $canales = [];
        if ($this->recibir_email) $canales[] = 'email';
        if ($this->recibir_push) $canales[] = 'push';
        if ($this->recibir_web) $canales[] = 'web';
        return $canales;
    }

    public function getDiasResumenArrayAttribute()
    {
        return is_string($this->dias_resumen) ? explode(',', $this->dias_resumen) : $this->dias_resumen;
    }
}
