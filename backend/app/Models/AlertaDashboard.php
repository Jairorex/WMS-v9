<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AlertaDashboard extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'alertas_dashboard';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'kpi_id',
        'tipo_alerta',
        'nivel_criticidad',
        'mensaje',
        'valor_actual',
        'valor_umbral',
        'fecha_alerta',
        'fecha_resolucion',
        'estado',
        'usuario_notificado',
        'observaciones',
    ];

    protected $casts = [
        'valor_actual' => 'decimal:4',
        'valor_umbral' => 'decimal:4',
        'fecha_alerta' => 'datetime',
        'fecha_resolucion' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function kpi()
    {
        return $this->belongsTo(KpiSistema::class, 'kpi_id', 'id');
    }

    public function usuarioNotificado()
    {
        return $this->belongsTo(Usuario::class, 'usuario_notificado', 'id_usuario');
    }

    public function scopeActivas($query)
    {
        return $query->where('estado', 'activa');
    }

    public function scopePorNivel($query, $nivel)
    {
        return $query->where('nivel_criticidad', $nivel);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_alerta', $tipo);
    }

    public function scopeRecientes($query, $horas = 24)
    {
        return $query->where('fecha_alerta', '>=', now()->subHours($horas));
    }

    public function resolver($observaciones = null)
    {
        $this->update([
            'estado' => 'resuelta',
            'fecha_resolucion' => now(),
            'observaciones' => $observaciones ?? $this->observaciones,
        ]);
    }
}
