<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OleadaPicking extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'oleadas_picking';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'nombre',
        'descripcion',
        'fecha_creacion',
        'fecha_inicio',
        'fecha_fin',
        'fecha_vencimiento',
        'estado',
        'prioridad',
        'zona_id',
        'operario_asignado',
        'total_pedidos',
        'pedidos_completados',
        'total_items',
        'items_completados',
        'observaciones',
        'activo',
    ];

    protected $casts = [
        'fecha_creacion' => 'datetime',
        'fecha_inicio' => 'datetime',
        'fecha_fin' => 'datetime',
        'fecha_vencimiento' => 'datetime',
        'total_pedidos' => 'integer',
        'pedidos_completados' => 'integer',
        'total_items' => 'integer',
        'items_completados' => 'integer',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function zona()
    {
        return $this->belongsTo(ZonaAlmacen::class, 'zona_id', 'id');
    }

    public function operario()
    {
        return $this->belongsTo(Usuario::class, 'operario_asignado', 'id_usuario');
    }

    public function pedidos()
    {
        return $this->hasMany(PedidoPicking::class, 'oleada_id', 'id');
    }

    public function rutas()
    {
        return $this->hasMany(RutaPicking::class, 'oleada_id', 'id');
    }

    public function estadisticas()
    {
        return $this->hasMany(EstadisticaPicking::class, 'oleada_id', 'id');
    }

    // Scopes
    public function scopeActivas($query)
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

    public function scopeCompletadas($query)
    {
        return $query->where('estado', 'COMPLETADA');
    }

    public function scopePorOperario($query, $operarioId)
    {
        return $query->where('operario_asignado', $operarioId);
    }

    public function scopePorZona($query, $zonaId)
    {
        return $query->where('zona_id', $zonaId);
    }

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function scopeVencidas($query)
    {
        return $query->where('fecha_vencimiento', '<', now());
    }

    public function scopePorVencer($query, $horas = 24)
    {
        return $query->where('fecha_vencimiento', '<=', now()->addHours($horas))
                    ->where('fecha_vencimiento', '>', now());
    }

    // Accessors
    public function getPorcentajeCompletadoAttribute()
    {
        if ($this->total_pedidos == 0) return 0;
        return round(($this->pedidos_completados / $this->total_pedidos) * 100, 2);
    }

    public function getPorcentajeItemsCompletadosAttribute()
    {
        if ($this->total_items == 0) return 0;
        return round(($this->items_completados / $this->total_items) * 100, 2);
    }

    public function getEstaVencidaAttribute()
    {
        return $this->fecha_vencimiento < now();
    }

    public function getEstaPorVencerAttribute()
    {
        return $this->fecha_vencimiento <= now()->addHours(24) && 
               $this->fecha_vencimiento > now();
    }

    public function getTiempoRestanteAttribute()
    {
        if ($this->fecha_vencimiento < now()) return 0;
        return now()->diffInMinutes($this->fecha_vencimiento);
    }

    public function getEsCompletableAttribute()
    {
        return $this->estado === 'EN_PROCESO' && 
               $this->pedidos_completados < $this->total_pedidos;
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

    public function completar()
    {
        $this->update([
            'estado' => 'COMPLETADA',
            'fecha_fin' => now(),
        ]);

        return $this;
    }

    public function cancelar($motivo = null)
    {
        $this->update([
            'estado' => 'CANCELADA',
            'fecha_fin' => now(),
            'observaciones' => $motivo,
        ]);

        return $this;
    }

    public function actualizarProgreso()
    {
        $pedidosCompletados = $this->pedidos()->where('estado', 'COMPLETADO')->count();
        $itemsCompletados = $this->pedidos()
            ->join('pedidos_picking_detalle', 'pedidos_picking.id', '=', 'pedidos_picking_detalle.pedido_id')
            ->where('pedidos_picking_detalle.estado', 'COMPLETADO')
            ->sum('pedidos_picking_detalle.cantidad_confirmada');

        $this->update([
            'pedidos_completados' => $pedidosCompletados,
            'items_completados' => $itemsCompletados,
        ]);

        // Si todos los pedidos están completados, marcar la oleada como completada
        if ($pedidosCompletados >= $this->total_pedidos && $this->estado === 'EN_PROCESO') {
            $this->completar();
        }

        return $this;
    }

    public function generarRutaOptimizada()
    {
        // Obtener todos los items pendientes de la oleada
        $items = $this->pedidos()
            ->join('pedidos_picking_detalle', 'pedidos_picking.id', '=', 'pedidos_picking_detalle.pedido_id')
            ->join('ubicaciones', 'pedidos_picking_detalle.ubicacion_id', '=', 'ubicaciones.id_ubicacion')
            ->where('pedidos_picking_detalle.estado', 'PENDIENTE')
            ->whereNotNull('ubicaciones.coordenada_x')
            ->whereNotNull('ubicaciones.coordenada_y')
            ->select([
                'pedidos_picking_detalle.*',
                'ubicaciones.coordenada_x',
                'ubicaciones.coordenada_y',
                'ubicaciones.codigo as ubicacion_codigo'
            ])
            ->get();

        if ($items->isEmpty()) {
            return collect();
        }

        // Ordenar por coordenadas para optimizar la ruta
        $itemsOrdenados = $items->sortBy(function($item) {
            // Calcular distancia desde el punto de inicio (0,0)
            return sqrt(pow($item->coordenada_x, 2) + pow($item->coordenada_y, 2));
        });

        // Crear rutas optimizadas
        $rutas = collect();
        $secuencia = 1;

        foreach ($itemsOrdenados as $item) {
            $rutas->push([
                'oleada_id' => $this->id,
                'operario_id' => $this->operario_asignado,
                'nombre_ruta' => "Ruta {$this->nombre}",
                'secuencia' => $secuencia++,
                'ubicacion_id' => $item->ubicacion_id,
                'producto_id' => $item->producto_id,
                'cantidad' => $item->cantidad_solicitada,
                'estado' => 'PENDIENTE',
                'tiempo_estimado' => 5, // 5 minutos por item
                'distancia_estimada' => $this->calcularDistancia($item),
            ]);
        }

        return $rutas;
    }

    private function calcularDistancia($item)
    {
        // Calcular distancia desde el punto anterior (simplificado)
        return sqrt(pow($item->coordenada_x, 2) + pow($item->coordenada_y, 2));
    }
}
