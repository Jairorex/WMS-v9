<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KpiSistema extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.kpis_sistema';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo',
        'nombre',
        'descripcion',
        'categoria',
        'tipo_metrica',
        'unidad',
        'valor_objetivo',
        'valor_minimo',
        'valor_maximo',
        'frecuencia_actualizacion',
        'activo',
    ];

    protected $casts = [
        'valor_objetivo' => 'decimal:2',
        'valor_minimo' => 'decimal:2',
        'valor_maximo' => 'decimal:2',
        'frecuencia_actualizacion' => 'integer',
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function historicos()
    {
        return $this->hasMany(KpiHistorico::class, 'kpi_id', 'id');
    }

    public function alertas()
    {
        return $this->hasMany(AlertaDashboard::class, 'kpi_id', 'id');
    }

    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }

    public function getValorActualAttribute()
    {
        return $this->historicos()->latest('fecha_medicion')->first()?->valor ?? 0;
    }

    public function getTendenciaAttribute()
    {
        return $this->historicos()->latest('fecha_medicion')->first()?->tendencia ?? 'estable';
    }

    public function getEstadoAttribute()
    {
        $valorActual = $this->valor_actual;
        
        if ($valorActual >= $this->valor_objetivo) {
            return 'excelente';
        } elseif ($valorActual >= $this->valor_minimo) {
            return 'bueno';
        } else {
            return 'critico';
        }
    }
}
