<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class EstadoTarea extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'estados_tarea';
    protected $primaryKey = 'id_estado_tarea';
    public $timestamps = false;

    protected $fillable = [
        'codigo',
        'nombre',
    ];

    // Relaciones
    public function tareas()
    {
        return $this->hasMany(Tarea::class, 'estado_tarea_id', 'id_estado_tarea');
    }
}
