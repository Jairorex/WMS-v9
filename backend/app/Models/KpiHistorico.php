<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KpiHistorico extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.kpis_historicos';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'kpi_id',
        'fecha_medicion',
        'valor',
        'valor_anterior',
        'tendencia',
        'observaciones',
    ];

    protected $casts = [
        'valor' => 'decimal:4',
        'valor_anterior' => 'decimal:4',
        'fecha_medicion' => 'datetime',
        'created_at' => 'datetime',
    ];

    public function kpi()
    {
        return $this->belongsTo(KpiSistema::class, 'kpi_id', 'id');
    }

    public function scopePorPeriodo($query, $fechaInicio, $fechaFin)
    {
        return $query->whereBetween('fecha_medicion', [$fechaInicio, $fechaFin]);
    }

    public function scopePorKpi($query, $kpiId)
    {
        return $query->where('kpi_id', $kpiId);
    }

    public function getVariacionAttribute()
    {
        if ($this->valor_anterior && $this->valor_anterior > 0) {
            return (($this->valor - $this->valor_anterior) / $this->valor_anterior) * 100;
        }
        return 0;
    }
}
