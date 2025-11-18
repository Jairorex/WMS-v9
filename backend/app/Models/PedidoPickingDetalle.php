<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PedidoPickingDetalle extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.pedidos_picking_detalle';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'pedido_id',
        'producto_id',
        'lote_id',
        'numero_serie_id',
        'ubicacion_id',
        'cantidad_solicitada',
        'cantidad_pickeada',
        'cantidad_confirmada',
        'estado',
        'operario_asignado',
        'fecha_inicio',
        'fecha_fin',
        'observaciones',
        'activo',
    ];

    protected $casts = [
        'cantidad_solicitada' => 'decimal:2',
        'cantidad_pickeada' => 'decimal:2',
        'cantidad_confirmada' => 'decimal:2',
        'fecha_inicio' => 'datetime',
        'fecha_fin' => 'datetime',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function pedido()
    {
        return $this->belongsTo(PedidoPicking::class, 'pedido_id', 'id');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id', 'id_producto');
    }

    public function lote()
    {
        return $this->belongsTo(Lote::class, 'lote_id', 'id');
    }

    public function numeroSerie()
    {
        return $this->belongsTo(NumeroSerie::class, 'numero_serie_id', 'id');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_id', 'id_ubicacion');
    }

    public function operario()
    {
        return $this->belongsTo(Usuario::class, 'operario_asignado', 'id_usuario');
    }

    // Scopes
    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    public function scopePendientes($query)
    {
        return $query->where('estado', 'PENDIENTE');
    }

    public function scopeEnProceso($query)
    {
        return $query->where('estado', 'EN_PROCESO');
    }

    public function scopeCompletados($query)
    {
        return $query->where('estado', 'COMPLETADO');
    }

    public function scopePorOperario($query, $operarioId)
    {
        return $query->where('operario_asignado', $operarioId);
    }

    public function scopePorProducto($query, $productoId)
    {
        return $query->where('producto_id', $productoId);
    }

    public function scopePorUbicacion($query, $ubicacionId)
    {
        return $query->where('ubicacion_id', $ubicacionId);
    }

    public function scopePorLote($query, $loteId)
    {
        return $query->where('lote_id', $loteId);
    }

    // Accessors
    public function getPorcentajeCompletadoAttribute()
    {
        if ($this->cantidad_solicitada == 0) return 0;
        return round(($this->cantidad_confirmada / $this->cantidad_solicitada) * 100, 2);
    }

    public function getEstaCompletoAttribute()
    {
        return $this->cantidad_confirmada >= $this->cantidad_solicitada;
    }

    public function getTieneDiferenciasAttribute()
    {
        return $this->cantidad_pickeada !== $this->cantidad_confirmada;
    }

    public function getTiempoTranscurridoAttribute()
    {
        if (!$this->fecha_inicio) return 0;
        $fechaFin = $this->fecha_fin ?? now();
        return $this->fecha_inicio->diffInMinutes($fechaFin);
    }

    // Métodos
    public function iniciar($operarioId = null)
    {
        $this->update([
            'estado' => 'EN_PROCESO',
            'fecha_inicio' => now(),
            'operario_asignado' => $operarioId ?? auth()->id(),
        ]);

        return $this;
    }

    public function completar($cantidadConfirmada = null)
    {
        $cantidadConfirmada = $cantidadConfirmada ?? $this->cantidad_pickeada;
        
        $this->update([
            'estado' => 'COMPLETADO',
            'cantidad_confirmada' => $cantidadConfirmada,
            'fecha_fin' => now(),
        ]);

        // Actualizar progreso del pedido
        $this->pedido->actualizarProgreso();

        // Registrar movimiento de inventario si hay lote
        if ($this->lote_id) {
            MovimientoInventario::create([
                'lote_id' => $this->lote_id,
                'producto_id' => $this->producto_id,
                'ubicacion_id' => $this->ubicacion_id,
                'tipo_movimiento' => 'SALIDA',
                'cantidad' => $cantidadConfirmada,
                'cantidad_anterior' => $this->lote->cantidad_disponible,
                'cantidad_nueva' => $this->lote->cantidad_disponible - $cantidadConfirmada,
                'motivo' => 'PICKING',
                'referencia' => $this->pedido->numero_pedido,
                'usuario_id' => auth()->id(),
            ]);

            // Actualizar cantidad disponible del lote
            $this->lote->ajustarCantidad(-$cantidadConfirmada, 'PICKING', auth()->id());
        }

        // Registrar en trazabilidad
        TrazabilidadProducto::registrarSalida(
            $this->producto_id,
            $this->ubicacion_id,
            $cantidadConfirmada,
            $this->pedido->numero_pedido
        );

        return $this;
    }

    public function cancelar($motivo = null)
    {
        $this->update([
            'estado' => 'CANCELADO',
            'fecha_fin' => now(),
            'observaciones' => $motivo,
        ]);

        return $this;
    }

    public function actualizarCantidadPickeada($cantidad)
    {
        $this->update(['cantidad_pickeada' => $cantidad]);
        return $this;
    }

    public function asignarOperario($operarioId)
    {
        $this->update(['operario_asignado' => $operarioId]);
        return $this;
    }

    public function verificarDisponibilidad()
    {
        // Verificar si hay suficiente stock en la ubicación
        $inventario = Inventario::where('id_producto', $this->producto_id)
            ->where('id_ubicacion', $this->ubicacion_id)
            ->when($this->lote_id, function($query) {
                $query->where('lote_id', $this->lote_id);
            })
            ->sum('cantidad');

        return $inventario >= $this->cantidad_solicitada;
    }

    public function obtenerInventarioDisponible()
    {
        return Inventario::where('id_producto', $this->producto_id)
            ->where('id_ubicacion', $this->ubicacion_id)
            ->when($this->lote_id, function($query) {
                $query->where('lote_id', $this->lote_id);
            })
            ->when($this->numero_serie_id, function($query) {
                $query->where('numero_serie_id', $this->numero_serie_id);
            })
            ->with(['lote', 'numeroSerie'])
            ->get();
    }
}
