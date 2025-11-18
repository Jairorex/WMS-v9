<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PedidoPicking extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.pedidos_picking';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'numero_pedido',
        'oleada_id',
        'cliente',
        'fecha_pedido',
        'fecha_vencimiento',
        'prioridad',
        'estado',
        'operario_asignado',
        'fecha_inicio',
        'fecha_fin',
        'total_items',
        'items_completados',
        'observaciones',
        'activo',
    ];

    protected $casts = [
        'fecha_pedido' => 'datetime',
        'fecha_vencimiento' => 'datetime',
        'fecha_inicio' => 'datetime',
        'fecha_fin' => 'datetime',
        'total_items' => 'integer',
        'items_completados' => 'integer',
        'activo' => 'boolean',
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
        return $this->belongsTo(Usuario::class, 'operario_asignado', 'id_usuario');
    }

    public function detalles()
    {
        return $this->hasMany(PedidoPickingDetalle::class, 'pedido_id', 'id');
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

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function scopeVencidos($query)
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
        if ($this->total_items == 0) return 0;
        return round(($this->items_completados / $this->total_items) * 100, 2);
    }

    public function getEstaVencidoAttribute()
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
               $this->items_completados < $this->total_items;
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
            'estado' => 'COMPLETADO',
            'fecha_fin' => now(),
        ]);

        // Actualizar progreso de la oleada
        $this->oleada->actualizarProgreso();

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

    public function actualizarProgreso()
    {
        $itemsCompletados = $this->detalles()
            ->where('estado', 'COMPLETADO')
            ->sum('cantidad_confirmada');

        $this->update(['items_completados' => $itemsCompletados]);

        // Si todos los items están completados, marcar el pedido como completado
        if ($itemsCompletados >= $this->total_items && $this->estado === 'EN_PROCESO') {
            $this->completar();
        }

        return $this;
    }

    public function asignarOperario($operarioId)
    {
        $this->update(['operario_asignado' => $operarioId]);
        return $this;
    }

    public function calcularTiempoEstimado()
    {
        // Calcular tiempo estimado basado en cantidad de items y ubicaciones
        $detalles = $this->detalles()->with('ubicacion')->get();
        $ubicacionesUnicas = $detalles->pluck('ubicacion_id')->unique()->count();
        
        // 2 minutos por item + 1 minuto por ubicación única
        return ($this->total_items * 2) + $ubicacionesUnicas;
    }

    public function calcularDistanciaEstimada()
    {
        // Calcular distancia estimada basada en ubicaciones
        $detalles = $this->detalles()->with('ubicacion')->get();
        $ubicaciones = $detalles->pluck('ubicacion')->filter(function($ubicacion) {
            return $ubicacion && $ubicacion->coordenada_x && $ubicacion->coordenada_y;
        });

        if ($ubicaciones->isEmpty()) return 0;

        $distanciaTotal = 0;
        $ubicacionAnterior = null;

        foreach ($ubicaciones as $ubicacion) {
            if ($ubicacionAnterior) {
                $distanciaTotal += sqrt(
                    pow($ubicacion->coordenada_x - $ubicacionAnterior->coordenada_x, 2) +
                    pow($ubicacion->coordenada_y - $ubicacionAnterior->coordenada_y, 2)
                );
            }
            $ubicacionAnterior = $ubicacion;
        }

        return round($distanciaTotal, 2);
    }
}
