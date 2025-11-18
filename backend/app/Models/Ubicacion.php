<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Ubicacion extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.ubicaciones';
    protected $primaryKey = 'id_ubicacion';
    public $timestamps = true;

    protected $fillable = [
        'codigo',
        'pasillo',
        'estanteria',
        'nivel',
        'capacidad',
        'tipo',
        'ocupada',
    ];

    protected $casts = [
        'capacidad' => 'integer',
        'ocupada' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function inventario()
    {
        return $this->hasMany(Inventario::class, 'id_ubicacion', 'id_ubicacion');
    }

    public function tareasDetalleOrigen()
    {
        return $this->hasMany(TareaDetalle::class, 'id_ubicacion_origen', 'id_ubicacion');
    }

    public function tareasDetalleDestino()
    {
        return $this->hasMany(TareaDetalle::class, 'id_ubicacion_destino', 'id_ubicacion');
    }

    public function pickingDetalle()
    {
        return $this->hasMany(PickingDetalle::class, 'id_ubicacion', 'id_ubicacion');
    }

    // Scopes
    public function scopeDisponibles($query)
    {
        return $query->where('ocupada', false);
    }

    public function scopeOcupadas($query)
    {
        return $query->where('ocupada', true);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    // Accessors
    public function getOcupacionAttribute()
    {
        return $this->inventario()->sum('cantidad');
    }

    public function getPorcentajeOcupacionAttribute()
    {
        if ($this->capacidad == 0) return 0;
        return ($this->ocupacion / $this->capacidad) * 100;
    }
}
