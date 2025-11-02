<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MetricaTiempoReal extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'metricas_tiempo_real';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo_metrica',
        'nombre',
        'valor_actual',
        'valor_anterior',
        'fecha_actualizacion',
        'intervalo_actualizacion',
        'fuente_datos',
        'activo',
    ];

    protected $casts = [
        'valor_actual' => 'decimal:4',
        'valor_anterior' => 'decimal:4',
        'fecha_actualizacion' => 'datetime',
        'intervalo_actualizacion' => 'integer',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorCodigo($query, $codigo)
    {
        return $query->where('codigo_metrica', $codigo);
    }

    public function scopeRecientes($query, $minutos = 5)
    {
        return $query->where('fecha_actualizacion', '>=', now()->subMinutes($minutos));
    }

    public function getVariacionAttribute()
    {
        if ($this->valor_anterior && $this->valor_anterior > 0) {
            return (($this->valor_actual - $this->valor_anterior) / $this->valor_anterior) * 100;
        }
        return 0;
    }

    public function getTendenciaAttribute()
    {
        if ($this->valor_anterior) {
            if ($this->valor_actual > $this->valor_anterior * 1.05) {
                return 'ascendente';
            } elseif ($this->valor_actual < $this->valor_anterior * 0.95) {
                return 'descendente';
            }
        }
        return 'estable';
    }
}
