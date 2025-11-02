<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TipoNotificacion extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'tipos_notificacion';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo',
        'nombre',
        'descripcion',
        'categoria',
        'prioridad',
        'canales_notificacion',
        'plantilla_email',
        'plantilla_push',
        'plantilla_web',
        'activo',
    ];

    protected $casts = [
        'canales_notificacion' => 'array',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function notificaciones()
    {
        return $this->hasMany(Notificacion::class, 'tipo_notificacion_id', 'id');
    }

    public function configuracionesUsuario()
    {
        return $this->hasMany(ConfiguracionNotificacionUsuario::class, 'tipo_notificacion_id', 'id');
    }

    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function getCanalesArrayAttribute()
    {
        return explode(',', $this->canales_notificacion);
    }
}
