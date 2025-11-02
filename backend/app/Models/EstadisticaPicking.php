<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EstadisticaPicking extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'estadisticas_picking';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'oleada_id',
        'operario_id',
        'fecha',
        'total_pedidos',
        'pedidos_completados',
        'total_items',
        'items_completados',
        'tiempo_total',
        'tiempo_promedio_por_pedido',
        'tiempo_promedio_por_item',
        'distancia_total',
        'errores',
        'precision_picking',
        'eficiencia',
    ];

    protected $casts = [
        'fecha' => 'date',
        'total_pedidos' => 'integer',
        'pedidos_completados' => 'integer',
        'total_items' => 'integer',
        'items_completados' => 'integer',
        'tiempo_total' => 'integer',
        'tiempo_promedio_por_pedido' => 'decimal:2',
        'tiempo_promedio_por_item' => 'decimal:2',
        'distancia_total' => 'decimal:2',
        'errores' => 'integer',
        'precision_picking' => 'decimal:2',
        'eficiencia' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function oleada()
    {
        return $this->belongsTo(OleadaPicking::class, 'oleada_id', 'id');
    }

    public function operario()
    {
        return $this->belongsTo(Usuario::class, 'operario_id', 'id_usuario');
    }

    // Scopes
    public function scopePorOperario($query, $operarioId)
    {
        return $query->where('operario_id', $operarioId);
    }

    public function scopePorFecha($query, $fecha)
    {
        return $query->where('fecha', $fecha);
    }

    public function scopePorRangoFecha($query, $fechaInicio, $fechaFin)
    {
        return $query->whereBetween('fecha', [$fechaInicio, $fechaFin]);
    }

    public function scopePorOleada($query, $oleadaId)
    {
        return $query->where('oleada_id', $oleadaId);
    }

    // Accessors
    public function getPorcentajePedidosCompletadosAttribute()
    {
        if ($this->total_pedidos == 0) return 0;
        return round(($this->pedidos_completados / $this->total_pedidos) * 100, 2);
    }

    public function getPorcentajeItemsCompletadosAttribute()
    {
        if ($this->total_items == 0) return 0;
        return round(($this->items_completados / $this->total_items) * 100, 2);
    }

    public function getTasaErroresAttribute()
    {
        if ($this->total_items == 0) return 0;
        return round(($this->errores / $this->total_items) * 100, 2);
    }

    // Métodos estáticos
    public static function calcularEstadisticas($operarioId, $fecha, $oleadaId = null)
    {
        $query = PedidoPicking::where('operario_asignado', $operarioId)
            ->whereDate('fecha_inicio', $fecha);

        if ($oleadaId) {
            $query->where('oleada_id', $oleadaId);
        }

        $pedidos = $query->get();

        $totalPedidos = $pedidos->count();
        $pedidosCompletados = $pedidos->where('estado', 'COMPLETADO')->count();
        $totalItems = $pedidos->sum('total_items');
        $itemsCompletados = $pedidos->sum('items_completados');

        $tiempoTotal = $pedidos->sum(function($pedido) {
            return $pedido->fecha_inicio && $pedido->fecha_fin 
                ? $pedido->fecha_inicio->diffInMinutes($pedido->fecha_fin)
                : 0;
        });

        $tiempoPromedioPorPedido = $totalPedidos > 0 ? $tiempoTotal / $totalPedidos : 0;
        $tiempoPromedioPorItem = $totalItems > 0 ? $tiempoTotal / $totalItems : 0;

        // Calcular distancia total (simplificado)
        $distanciaTotal = $pedidos->sum(function($pedido) {
            return $pedido->calcularDistanciaEstimada();
        });

        // Calcular errores (simplificado)
        $errores = $pedidos->sum(function($pedido) {
            return $pedido->detalles()->where('cantidad_pickeada', '!=', 'cantidad_confirmada')->count();
        });

        $precisionPicking = $totalItems > 0 ? (($totalItems - $errores) / $totalItems) * 100 : 0;
        $eficiencia = $tiempoTotal > 0 ? ($itemsCompletados / $tiempoTotal) * 60 : 0; // items por hora

        return [
            'oleada_id' => $oleadaId,
            'operario_id' => $operarioId,
            'fecha' => $fecha,
            'total_pedidos' => $totalPedidos,
            'pedidos_completados' => $pedidosCompletados,
            'total_items' => $totalItems,
            'items_completados' => $itemsCompletados,
            'tiempo_total' => $tiempoTotal,
            'tiempo_promedio_por_pedido' => round($tiempoPromedioPorPedido, 2),
            'tiempo_promedio_por_item' => round($tiempoPromedioPorItem, 2),
            'distancia_total' => round($distanciaTotal, 2),
            'errores' => $errores,
            'precision_picking' => round($precisionPicking, 2),
            'eficiencia' => round($eficiencia, 2),
        ];
    }

    public static function generarReporteDiario($fecha)
    {
        $operarios = Usuario::whereHas('pedidosPicking', function($query) use ($fecha) {
            $query->whereDate('fecha_inicio', $fecha);
        })->get();

        $estadisticas = [];

        foreach ($operarios as $operario) {
            $estadisticas[] = self::calcularEstadisticas($operario->id_usuario, $fecha);
        }

        return $estadisticas;
    }

    public static function generarReporteOleada($oleadaId)
    {
        $oleada = OleadaPicking::find($oleadaId);
        if (!$oleada) return [];

        $operarios = Usuario::whereHas('pedidosPicking', function($query) use ($oleadaId) {
            $query->where('oleada_id', $oleadaId);
        })->get();

        $estadisticas = [];

        foreach ($operarios as $operario) {
            $estadisticas[] = self::calcularEstadisticas(
                $operario->id_usuario, 
                $oleada->fecha_creacion->toDateString(), 
                $oleadaId
            );
        }

        return $estadisticas;
    }
}
