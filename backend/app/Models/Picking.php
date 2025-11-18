<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Picking extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.picking';
    protected $primaryKey = 'id_picking';
    public $timestamps = true;

    protected $fillable = [
        'id_orden',
        'estado',
        'asignado_a',
        'fecha_inicio',
        'fecha_fin',
    ];

    protected $casts = [
        'fecha_inicio' => 'datetime',
        'fecha_fin' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function orden()
    {
        return $this->belongsTo(OrdenSalida::class, 'id_orden', 'id_orden');
    }

    public function asignadoA()
    {
        return $this->belongsTo(Usuario::class, 'asignado_a', 'id_usuario');
    }

    public function detalles()
    {
        return $this->hasMany(PickingDetalle::class, 'id_picking', 'id_picking');
    }

    // Scopes
    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    public function scopeAsignados($query)
    {
        return $query->whereNotNull('asignado_a');
    }

    public function scopeSinAsignar($query)
    {
        return $query->whereNull('asignado_a');
    }
}
