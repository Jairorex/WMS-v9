<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UnidadMedida extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'unidad_de_medida';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo',
        'nombre',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function productos()
    {
        return $this->hasMany(Producto::class, 'unidad_medida_id', 'id');
    }

    // Scopes
    public function scopePorCodigo($query, $codigo)
    {
        return $query->where('codigo', $codigo);
    }
}
