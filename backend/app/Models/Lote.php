<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class Lote extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.lotes';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo_lote',
        'producto_id',
        'cantidad_inicial',
        'cantidad_disponible',
        'fecha_fabricacion',
        'fecha_caducidad',
        'fecha_vencimiento',
        'proveedor',
        'numero_serie',
        'estado',
        'observaciones',
        'activo',
    ];

    protected $casts = [
        'cantidad_inicial' => 'decimal:2',
        'cantidad_disponible' => 'decimal:2',
        'fecha_fabricacion' => 'date',
        'fecha_caducidad' => 'date',
        'fecha_vencimiento' => 'date',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id', 'id_producto');
    }

    public function movimientos()
    {
        return $this->hasMany(MovimientoInventario::class, 'lote_id', 'id');
    }

    public function numerosSerie()
    {
        return $this->hasMany(NumeroSerie::class, 'lote_id', 'id');
    }

    public function inventario()
    {
        // Relación estándar - si la columna lote_id no existe en inventario,
        // esta relación fallará. Ejecutar: agregar_lote_id_inventario.sql
        return $this->hasMany(Inventario::class, 'lote_id', 'id');
    }

    public function trazabilidad()
    {
        return $this->hasMany(TrazabilidadProducto::class, 'lote_id', 'id');
    }

    // Scopes
    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopeDisponibles($query)
    {
        return $query->where('estado', 'DISPONIBLE');
    }

    public function scopeCaducados($query)
    {
        return $query->where('fecha_caducidad', '<', now());
    }

    public function scopePorCaducar($query, $dias = 30)
    {
        return $query->where('fecha_caducidad', '<=', now()->addDays($dias))
                    ->where('fecha_caducidad', '>', now());
    }

    public function scopePorProducto($query, $productoId)
    {
        return $query->where('producto_id', $productoId);
    }

    public function scopePorProveedor($query, $proveedor)
    {
        return $query->where('proveedor', 'like', "%{$proveedor}%");
    }

    // Accessors
    public function getDiasParaCaducarAttribute()
    {
        if (!$this->fecha_caducidad) return null;
        return now()->diffInDays($this->fecha_caducidad, false);
    }

    public function getEstaCaducadoAttribute()
    {
        return $this->fecha_caducidad && $this->fecha_caducidad < now();
    }

    public function getPorCaducarAttribute()
    {
        return $this->fecha_caducidad && 
               $this->fecha_caducidad <= now()->addDays(30) && 
               $this->fecha_caducidad > now();
    }

    // Métodos
    public function ajustarCantidad($cantidad, $motivo = null, $usuarioId = null)
    {
        $cantidadAnterior = $this->cantidad_disponible;
        $cantidadNueva = max(0, $cantidadAnterior + $cantidad);
        
        $this->update(['cantidad_disponible' => $cantidadNueva]);

        // Registrar movimiento
        MovimientoInventario::create([
            'lote_id' => $this->id,
            'producto_id' => $this->producto_id,
            'ubicacion_id' => $this->inventario()->first()?->id_ubicacion ?? 0,
            'tipo_movimiento' => $cantidad > 0 ? 'ENTRADA' : 'SALIDA',
            'cantidad' => abs($cantidad),
            'cantidad_anterior' => $cantidadAnterior,
            'cantidad_nueva' => $cantidadNueva,
            'motivo' => $motivo,
            'usuario_id' => $usuarioId ?? auth()->id(),
        ]);

        return $this;
    }

    public function reservar($cantidad, $usuarioId = null)
    {
        if ($this->cantidad_disponible < $cantidad) {
            throw new \Exception('Cantidad insuficiente en el lote');
        }

        return $this->ajustarCantidad(-$cantidad, 'RESERVA', $usuarioId);
    }

    public function liberar($cantidad, $usuarioId = null)
    {
        return $this->ajustarCantidad($cantidad, 'LIBERACION', $usuarioId);
    }
}
