<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Producto extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'productos';
    protected $primaryKey = 'id_producto';
    public $timestamps = true;

    protected $fillable = [
        'nombre',
        'descripcion',
        'codigo_barra',
        'lote',
        'estado_producto_id',
        'fecha_caducidad',
        'unidad_medida',
        'unidad_medida_id',
        'stock_minimo',
        'precio',
    ];

    protected $casts = [
        'fecha_caducidad' => 'date',
        'precio' => 'decimal:2',
        'stock_minimo' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function estado()
    {
        return $this->belongsTo(EstadoProducto::class, 'estado_producto_id', 'id_estado_producto');
    }

    public function unidadMedida()
    {
        return $this->belongsTo(UnidadMedida::class, 'unidad_medida_id', 'id');
    }

    public function inventario()
    {
        return $this->hasMany(Inventario::class, 'id_producto', 'id_producto');
    }

    public function tareasDetalle()
    {
        return $this->hasMany(TareaDetalle::class, 'id_producto', 'id_producto');
    }

    public function incidencias()
    {
        return $this->hasMany(Incidencia::class, 'id_producto', 'id_producto');
    }

    public function ordenesSalidaDetalle()
    {
        return $this->hasMany(OrdenSalidaDetalle::class, 'id_producto', 'id_producto');
    }

    public function pickingDetalle()
    {
        return $this->hasMany(PickingDetalle::class, 'id_producto', 'id_producto');
    }

    // Scopes
    public function scopeDisponibles($query)
    {
        return $query->whereHas('estado', function($q) {
            $q->where('codigo', 'DISPONIBLE');
        });
    }

    public function scopeStockBajo($query)
    {
        return $query->whereRaw('stock_minimo > (
            SELECT COALESCE(SUM(cantidad), 0) 
            FROM inventario 
            WHERE id_producto = productos.id_producto
        )');
    }
}
