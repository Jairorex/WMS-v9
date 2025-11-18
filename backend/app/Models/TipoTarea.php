<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TipoTarea extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.tipos_tarea';
    protected $primaryKey = 'id_tipo_tarea';
    public $timestamps = false;

    protected $fillable = [
        'codigo',
        'nombre',
        'categoria',
        'requiere_producto',
        'requiere_lote',
        'requiere_ubicacion_origen',
        'requiere_ubicacion_destino',
        'requiere_cantidad',
        'afecta_inventario',
    ];

    protected $casts = [
        'requiere_producto' => 'boolean',
        'requiere_lote' => 'boolean',
        'requiere_ubicacion_origen' => 'boolean',
        'requiere_ubicacion_destino' => 'boolean',
        'requiere_cantidad' => 'boolean',
        'afecta_inventario' => 'boolean',
    ];

    // Relaciones
    public function tareas()
    {
        return $this->hasMany(Tarea::class, 'tipo_tarea_id', 'id_tipo_tarea');
    }

    // Scopes
    public function scopePorCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }
}