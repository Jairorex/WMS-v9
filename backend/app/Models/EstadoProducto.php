<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class EstadoProducto extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.estados_producto';
    protected $primaryKey = 'id_estado_producto';
    public $timestamps = false;

    protected $fillable = [
        'codigo',
        'nombre',
    ];

    // Relaciones
    public function productos()
    {
        return $this->hasMany(Producto::class, 'estado_producto_id', 'id_estado_producto');
    }
}
