<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TareaLog extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'tareas_log';
    protected $primaryKey = 'id_log';
    public $timestamps = true;
    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;

    protected $fillable = [
        'id_tarea',
        'usuario_id',
        'estado_anterior',
        'estado_nuevo',
        'accion',
        'dispositivo',
        'ip_address',
        'comentarios',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    // Relaciones
    public function tarea()
    {
        return $this->belongsTo(Tarea::class, 'id_tarea', 'id_tarea');
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id', 'id_usuario');
    }
}

