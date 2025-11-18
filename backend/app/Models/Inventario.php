<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class Inventario extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.inventario';
    protected $primaryKey = 'id_inventario';
    public $timestamps = true;

    protected $fillable = [
        'id_producto',
        'id_ubicacion',
        'cantidad',
        'fecha_actualizacion',
        'lote_id',
        'numero_serie_id',
    ];

    protected $casts = [
        'cantidad' => 'integer',
        'fecha_actualizacion' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function producto()
    {
        return $this->belongsTo(Producto::class, 'id_producto', 'id_producto');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'id_ubicacion', 'id_ubicacion');
    }

    public function lote()
    {
        // Solo definir la relación si la columna existe
        if (\Schema::hasColumn($this->getTable(), 'lote_id')) {
            return $this->belongsTo(Lote::class, 'lote_id', 'id');
        }
        return null;
    }

    public function numeroSerie()
    {
        // Solo definir la relación si la columna existe
        if (\Schema::hasColumn($this->getTable(), 'numero_serie_id')) {
            return $this->belongsTo(NumeroSerie::class, 'numero_serie_id', 'id');
        }
        return null;
    }

    // Scopes
    public function scopeDisponibles($query)
    {
        return $query->where('cantidad', '>', 0);
    }

    public function scopePorProducto($query, $productoId)
    {
        return $query->where('id_producto', $productoId);
    }

    public function scopePorUbicacion($query, $ubicacionId)
    {
        return $query->where('id_ubicacion', $ubicacionId);
    }

    public function scopePorLote($query, $loteId)
    {
        if (Schema::hasColumn($this->getTable(), 'lote_id')) {
            return $query->where('lote_id', $loteId);
        }
        return $query->whereRaw('1 = 0'); // Retornar query vacío si no existe la columna
    }

    public function scopePorNumeroSerie($query, $numeroSerieId)
    {
        if (Schema::hasColumn($this->getTable(), 'numero_serie_id')) {
            return $query->where('numero_serie_id', $numeroSerieId);
        }
        return $query->whereRaw('1 = 0'); // Retornar query vacío si no existe la columna
    }

    public function scopeConLote($query)
    {
        if (Schema::hasColumn($this->getTable(), 'lote_id')) {
            return $query->whereNotNull('lote_id');
        }
        return $query->whereRaw('1 = 0');
    }

    public function scopeConNumeroSerie($query)
    {
        if (Schema::hasColumn($this->getTable(), 'numero_serie_id')) {
            return $query->whereNotNull('numero_serie_id');
        }
        return $query->whereRaw('1 = 0');
    }

    public function scopeSinLote($query)
    {
        if (Schema::hasColumn($this->getTable(), 'lote_id')) {
            return $query->whereNull('lote_id');
        }
        return $query; // Si no existe la columna, retornar todos
    }
}
