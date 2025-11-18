<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Usuario extends Authenticatable
{
    use HasFactory, HasApiTokens;

    protected $connection = 'sqlsrv';
    protected $table = 'wms.usuarios';
    protected $primaryKey = 'id_usuario';
    public $timestamps = true;

    protected $fillable = [
        'nombre',
        'usuario',
        'contrasena',
        'rol_id',
        'email',
        'ultimo_login',
        'activo',
    ];

    protected $hidden = [
        'contrasena',
        'remember_token',
    ];

    protected $casts = [
        'activo' => 'boolean',
        'ultimo_login' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relaciones
    public function rol()
    {
        return $this->belongsTo(Rol::class, 'rol_id', 'id_rol');
    }

    public function tareasCreadas()
    {
        return $this->hasMany(Tarea::class, 'creado_por', 'id_usuario');
    }

    public function incidencias()
    {
        return $this->hasMany(Incidencia::class, 'id_operario', 'id_usuario');
    }

    public function pickingsAsignados()
    {
        return $this->hasMany(Picking::class, 'asignado_a', 'id_usuario');
    }

    public function oleadasPicking()
    {
        return $this->hasMany(OleadaPicking::class, 'operario_asignado', 'id_usuario');
    }

    public function pedidosPicking()
    {
        return $this->hasMany(PedidoPicking::class, 'operario_asignado', 'id_usuario');
    }

    public function detallesPicking()
    {
        return $this->hasMany(PedidoPickingDetalle::class, 'operario_asignado', 'id_usuario');
    }

    public function rutasPicking()
    {
        return $this->hasMany(RutaPicking::class, 'operario_id', 'id_usuario');
    }

    public function estadisticasPicking()
    {
        return $this->hasMany(EstadisticaPicking::class, 'operario_id', 'id_usuario');
    }

    // Accessors y Mutators
    public function getPasswordAttribute()
    {
        return $this->contrasena;
    }

    public function setPasswordAttribute($value)
    {
        $this->contrasena = bcrypt($value);
    }
}