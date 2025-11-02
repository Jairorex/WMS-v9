<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Tarea extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'tareas';
    protected $primaryKey = 'id_tarea';
    public $timestamps = true;
    const CREATED_AT = 'fecha_creacion';
    const UPDATED_AT = 'updated_at';

    protected $fillable = [
        'tipo_tarea_id',
        'estado_tarea_id',
        'prioridad',
        'descripcion',
        'creado_por',
        'fecha_creacion',
        'fecha_cierre',
        'fecha_vencimiento',
    ];

    protected $casts = [
        'fecha_creacion' => 'datetime',
        'fecha_cierre' => 'datetime',
        'fecha_vencimiento' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function tipo()
    {
        return $this->belongsTo(TipoTarea::class, 'tipo_tarea_id', 'id_tipo_tarea');
    }

    public function estado()
    {
        return $this->belongsTo(EstadoTarea::class, 'estado_tarea_id', 'id_estado_tarea');
    }

    public function creador()
    {
        return $this->belongsTo(Usuario::class, 'creado_por', 'id_usuario');
    }

    public function detalles()
    {
        return $this->hasMany(TareaDetalle::class, 'id_tarea', 'id_tarea');
    }

    public function usuarios()
    {
        return $this->belongsToMany(Usuario::class, 'tarea_usuario', 'id_tarea', 'id_usuario')
                    ->withPivot('es_responsable', 'asignado_desde', 'asignado_hasta');
    }

    public function incidencias()
    {
        return $this->hasMany(Incidencia::class, 'id_tarea', 'id_tarea');
    }

    // Scopes
    public function scopePorEstado($query, $estado)
    {
        return $query->whereHas('estado', function($q) use ($estado) {
            $q->where('codigo', $estado);
        });
    }

    public function scopePorPrioridad($query, $prioridad)
    {
        return $query->where('prioridad', $prioridad);
    }

    public function scopeVencidas($query)
    {
        return $query->where('fecha_cierre', '<', now())
                    ->whereHas('estado', function($q) {
                        $q->whereNotIn('codigo', ['COMPLETADA', 'CANCELADA']);
                    });
    }
}
