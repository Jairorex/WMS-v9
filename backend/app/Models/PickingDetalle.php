<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class PickingDetalle extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'picking_det';
    protected $primaryKey = 'id_picking_det';
    public $timestamps = true;

    protected $fillable = [
        'id_picking',
        'id_orden_det',
        'id_producto',
        'id_ubicacion',
        'cantidad_solicitada',
        'cantidad_confirmada',
        'estado',
    ];

    protected $casts = [
        'cantidad_solicitada' => 'integer',
        'cantidad_confirmada' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function picking()
    {
        return $this->belongsTo(Picking::class, 'id_picking', 'id_picking');
    }

    public function ordenDetalle()
    {
        return $this->belongsTo(OrdenSalidaDetalle::class, 'id_orden_det', 'id_det');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'id_ubicacion', 'id_ubicacion');
    }

    // Scopes
    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    public function scopeCompletados($query)
    {
        return $query->where('estado', 'Completado');
    }

    public function scopePendientes($query)
    {
        return $query->where('estado', 'Pendiente');
    }
}
