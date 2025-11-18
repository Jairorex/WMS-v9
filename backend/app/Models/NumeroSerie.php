<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NumeroSerie extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.numeros_serie';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'numero_serie',
        'numero_serie_ficticio',
        'producto_id',
        'lote_id',
        'ubicacion_id',
        'estado',
        'fecha_fabricacion',
        'fecha_caducidad',
        'proveedor',
        'observaciones',
        'activo',
    ];

    protected $casts = [
        'fecha_fabricacion' => 'date',
        'fecha_caducidad' => 'date',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id', 'id_producto');
    }

    public function lote()
    {
        return $this->belongsTo(Lote::class, 'lote_id', 'id');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_id', 'id_ubicacion');
    }

    public function inventario()
    {
        return $this->hasMany(Inventario::class, 'numero_serie_id', 'id');
    }

    public function trazabilidad()
    {
        return $this->hasMany(TrazabilidadProducto::class, 'numero_serie_id', 'id');
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

    public function scopePorNumero($query, $numero)
    {
        return $query->where('numero_serie', 'like', "%{$numero}%");
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
    public function cambiarEstado($nuevoEstado, $observaciones = null)
    {
        $estadoAnterior = $this->estado;
        $this->update([
            'estado' => $nuevoEstado,
            'observaciones' => $observaciones
        ]);

        // Registrar en trazabilidad
        TrazabilidadProducto::create([
            'producto_id' => $this->producto_id,
            'numero_serie_id' => $this->id,
            'evento' => 'CAMBIO_ESTADO',
            'descripcion' => "Estado cambiado de {$estadoAnterior} a {$nuevoEstado}",
            'ubicacion_origen' => $this->ubicacion_id,
            'usuario_id' => auth()->id(),
            'observaciones' => $observaciones,
        ]);

        return $this;
    }

    public function mover($nuevaUbicacionId, $usuarioId = null)
    {
        $ubicacionAnterior = $this->ubicacion_id;
        $this->update(['ubicacion_id' => $nuevaUbicacionId]);

        // Registrar en trazabilidad
        TrazabilidadProducto::create([
            'producto_id' => $this->producto_id,
            'numero_serie_id' => $this->id,
            'evento' => 'MOVIMIENTO',
            'descripcion' => 'Número de serie movido de ubicación',
            'ubicacion_origen' => $ubicacionAnterior,
            'ubicacion_destino' => $nuevaUbicacionId,
            'usuario_id' => $usuarioId ?? auth()->id(),
        ]);

        return $this;
    }
}
