<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class OrdenSalida extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'orden_salida';
    protected $primaryKey = 'id_orden';
    public $timestamps = true;

    protected $fillable = [
        'estado',
        'prioridad',
        'fecha_creacion',
        'fecha_entrega',
    ];

    protected $casts = [
        'fecha_creacion' => 'datetime',
        'fecha_entrega' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function detalles()
    {
        return $this->hasMany(OrdenSalidaDetalle::class, 'id_orden', 'id_orden');
    }

    public function pickings()
    {
        return $this->hasMany(Picking::class, 'id_orden', 'id_orden');
    }

    public function creador()
    {
        if (Schema::hasColumn($this->getTable(), 'creado_por')) {
            return $this->belongsTo(Usuario::class, 'creado_por', 'id_usuario');
        }
        return null;
    }

    // Scopes
    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function scopeVencidas($query)
    {
        return $query->where('fecha_entrega', '<', now())
                    ->whereNotIn('estado', ['Completada', 'Cancelada']);
    }

    // Accessors
    public function getClienteAttribute()
    {
        // Por ahora retornamos un cliente genérico, se puede expandir después
        return 'Cliente Genérico';
    }
}
