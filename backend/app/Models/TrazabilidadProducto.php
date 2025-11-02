<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TrazabilidadProducto extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'trazabilidad_productos';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'producto_id',
        'lote_id',
        'numero_serie_id',
        'evento',
        'descripcion',
        'ubicacion_origen',
        'ubicacion_destino',
        'cantidad',
        'usuario_id',
        'fecha_evento',
        'referencia',
        'observaciones',
    ];

    protected $casts = [
        'cantidad' => 'decimal:2',
        'fecha_evento' => 'datetime',
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

    public function numeroSerie()
    {
        return $this->belongsTo(NumeroSerie::class, 'numero_serie_id', 'id');
    }

    public function ubicacionOrigen()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_origen', 'id_ubicacion');
    }

    public function ubicacionDestino()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_destino', 'id_ubicacion');
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }

    // Scopes
    public function scopePorProducto($query, $productoId)
    {
        return $query->where('producto_id', $productoId);
    }

    public function scopePorLote($query, $loteId)
    {
        return $query->where('lote_id', $loteId);
    }

    public function scopePorNumeroSerie($query, $numeroSerieId)
    {
        return $query->where('numero_serie_id', $numeroSerieId);
    }

    public function scopePorEvento($query, $evento)
    {
        return $query->where('evento', $evento);
    }

    public function scopePorUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopePorFecha($query, $fechaInicio, $fechaFin = null)
    {
        $query->where('fecha_evento', '>=', $fechaInicio);
        
        if ($fechaFin) {
            $query->where('fecha_evento', '<=', $fechaFin);
        }
        
        return $query;
    }

    public function scopeMovimientos($query)
    {
        return $query->where('evento', 'MOVIMIENTO');
    }

    public function scopeCambiosEstado($query)
    {
        return $query->where('evento', 'CAMBIO_ESTADO');
    }

    public function scopeEntradas($query)
    {
        return $query->where('evento', 'ENTRADA');
    }

    public function scopeSalidas($query)
    {
        return $query->where('evento', 'SALIDA');
    }

    public function scopeAjustes($query)
    {
        return $query->where('evento', 'AJUSTE');
    }

    // Accessors
    public function getTipoEventoAttribute()
    {
        $tipos = [
            'MOVIMIENTO' => 'Movimiento',
            'CAMBIO_ESTADO' => 'Cambio de Estado',
            'ENTRADA' => 'Entrada',
            'SALIDA' => 'Salida',
            'AJUSTE' => 'Ajuste',
            'RESERVA' => 'Reserva',
            'LIBERACION' => 'Liberación',
            'CADUCIDAD' => 'Caducidad',
            'DANADO' => 'Dañado',
            'RETIRADO' => 'Retirado',
        ];

        return $tipos[$this->evento] ?? $this->evento;
    }

    public function getTieneUbicacionDestinoAttribute()
    {
        return !is_null($this->ubicacion_destino);
    }

    public function getEsMovimientoAttribute()
    {
        return $this->evento === 'MOVIMIENTO';
    }

    // Métodos estáticos para crear eventos de trazabilidad
    public static function crearEvento($productoId, $evento, $descripcion, $datos = [])
    {
        return self::create(array_merge([
            'producto_id' => $productoId,
            'evento' => $evento,
            'descripcion' => $descripcion,
            'usuario_id' => auth()->id(),
            'fecha_evento' => now(),
        ], $datos));
    }

    public static function registrarMovimiento($productoId, $ubicacionOrigen, $ubicacionDestino, $cantidad = null, $referencia = null)
    {
        return self::crearEvento($productoId, 'MOVIMIENTO', 'Movimiento de producto', [
            'ubicacion_origen' => $ubicacionOrigen,
            'ubicacion_destino' => $ubicacionDestino,
            'cantidad' => $cantidad,
            'referencia' => $referencia,
        ]);
    }

    public static function registrarCambioEstado($productoId, $estadoAnterior, $estadoNuevo, $ubicacion = null)
    {
        return self::crearEvento($productoId, 'CAMBIO_ESTADO', "Estado cambiado de {$estadoAnterior} a {$estadoNuevo}", [
            'ubicacion_origen' => $ubicacion,
        ]);
    }

    public static function registrarEntrada($productoId, $ubicacion, $cantidad, $referencia = null)
    {
        return self::crearEvento($productoId, 'ENTRADA', 'Entrada de producto', [
            'ubicacion_destino' => $ubicacion,
            'cantidad' => $cantidad,
            'referencia' => $referencia,
        ]);
    }

    public static function registrarSalida($productoId, $ubicacion, $cantidad, $referencia = null)
    {
        return self::crearEvento($productoId, 'SALIDA', 'Salida de producto', [
            'ubicacion_origen' => $ubicacion,
            'cantidad' => $cantidad,
            'referencia' => $referencia,
        ]);
    }
}
