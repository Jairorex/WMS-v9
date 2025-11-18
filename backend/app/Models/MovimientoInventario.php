<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MovimientoInventario extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.movimientos_inventario';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'lote_id',
        'producto_id',
        'ubicacion_id',
        'tipo_movimiento',
        'cantidad',
        'cantidad_anterior',
        'cantidad_nueva',
        'motivo',
        'referencia',
        'usuario_id',
        'fecha_movimiento',
        'observaciones',
    ];

    protected $casts = [
        'cantidad' => 'decimal:2',
        'cantidad_anterior' => 'decimal:2',
        'cantidad_nueva' => 'decimal:2',
        'fecha_movimiento' => 'datetime',
    ];

    // Relaciones
    public function lote()
    {
        return $this->belongsTo(Lote::class, 'lote_id', 'id');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id', 'id_producto');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_id', 'id_ubicacion');
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }

    // Scopes
    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_movimiento', $tipo);
    }

    public function scopePorProducto($query, $productoId)
    {
        return $query->where('producto_id', $productoId);
    }

    public function scopePorLote($query, $loteId)
    {
        return $query->where('lote_id', $loteId);
    }

    public function scopePorUbicacion($query, $ubicacionId)
    {
        return $query->where('ubicacion_id', $ubicacionId);
    }

    public function scopePorUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopePorFecha($query, $fechaInicio, $fechaFin = null)
    {
        $query->where('fecha_movimiento', '>=', $fechaInicio);
        
        if ($fechaFin) {
            $query->where('fecha_movimiento', '<=', $fechaFin);
        }
        
        return $query;
    }

    public function scopeEntradas($query)
    {
        return $query->where('tipo_movimiento', 'ENTRADA');
    }

    public function scopeSalidas($query)
    {
        return $query->where('tipo_movimiento', 'SALIDA');
    }

    public function scopeAjustes($query)
    {
        return $query->where('tipo_movimiento', 'AJUSTE');
    }

    public function scopeReservas($query)
    {
        return $query->where('tipo_movimiento', 'RESERVA');
    }

    public function scopeLiberaciones($query)
    {
        return $query->where('tipo_movimiento', 'LIBERACION');
    }

    // Accessors
    public function getEsEntradaAttribute()
    {
        return $this->tipo_movimiento === 'ENTRADA';
    }

    public function getEsSalidaAttribute()
    {
        return $this->tipo_movimiento === 'SALIDA';
    }

    public function getEsAjusteAttribute()
    {
        return $this->tipo_movimiento === 'AJUSTE';
    }

    public function getDiferenciaAttribute()
    {
        return $this->cantidad_nueva - $this->cantidad_anterior;
    }
}
