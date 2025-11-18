<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class TareaDetalle extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.tarea_detalle';
    protected $primaryKey = 'id_detalle';
    public $timestamps = true;

    protected $fillable = [
        'id_tarea',
        'id_producto',
        'id_ubicacion_origen',
        'id_ubicacion_destino',
        'cantidad_solicitada',
        'cantidad_confirmada',
        'notas',
    ];

    protected $casts = [
        'cantidad_solicitada' => 'integer',
        'cantidad_confirmada' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function tarea()
    {
        return $this->belongsTo(Tarea::class, 'id_tarea', 'id_tarea');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    public function ubicacionOrigen()
    {
        return $this->belongsTo(Ubicacion::class, 'id_ubicacion_origen', 'id_ubicacion');
    }

    public function ubicacionDestino()
    {
        return $this->belongsTo(Ubicacion::class, 'id_ubicacion_destino', 'id_ubicacion');
    }
}
