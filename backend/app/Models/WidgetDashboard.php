<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WidgetDashboard extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.widgets_dashboard';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'nombre',
        'tipo_widget',
        'configuracion',
        'posicion_x',
        'posicion_y',
        'ancho',
        'alto',
        'usuario_id',
        'es_global',
        'activo',
    ];

    protected $casts = [
        'configuracion' => 'array',
        'posicion_x' => 'integer',
        'posicion_y' => 'integer',
        'ancho' => 'integer',
        'alto' => 'integer',
        'es_global' => 'boolean',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }

    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopeGlobales($query)
    {
        return $query->where('es_global', true);
    }

    public function scopePorUsuario($query, $usuarioId)
    {
        return $query->where(function($q) use ($usuarioId) {
            $q->where('usuario_id', $usuarioId)
              ->orWhere('es_global', true);
        });
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_widget', $tipo);
    }
}
