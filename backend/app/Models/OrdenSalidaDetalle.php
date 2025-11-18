<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class OrdenSalidaDetalle extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.orden_salida_det';
    protected $primaryKey = 'id_det';
    public $timestamps = true;

    protected $fillable = [
        'id_orden',
        'id_producto',
        'cantidad_solicitada',
        'cantidad_confirmada',
    ];

    protected $casts = [
        'cantidad_solicitada' => 'integer',
        'cantidad_confirmada' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function orden()
    {
        return $this->belongsTo(OrdenSalida::class, 'id_orden', 'id_orden');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    public function pickingDetalle()
    {
        return $this->hasMany(PickingDetalle::class, 'id_orden_det', 'id_det');
    }

    // Scopes
    public function scopePendientes($query)
    {
        return $query->whereRaw('cantidad_solicitada > cantidad_confirmada');
    }

    public function scopeCompletados($query)
    {
        return $query->whereRaw('cantidad_solicitada <= cantidad_confirmada');
    }
}
