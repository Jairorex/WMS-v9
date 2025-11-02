<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlantillaEmail extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv';
    protected $table = 'plantillas_email';
    protected $primaryKey = 'id';
    public $timestamps = true;

    protected $fillable = [
        'codigo',
        'nombre',
        'asunto',
        'contenido_html',
        'contenido_texto',
        'variables_disponibles',
        'activo',
    ];

    protected $casts = [
        'activo' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function scopeActivas($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorCodigo($query, $codigo)
    {
        return $query->where('codigo', $codigo);
    }

    public function getVariablesArrayAttribute()
    {
        return is_string($this->variables_disponibles) ? 
            explode(',', $this->variables_disponibles) : 
            $this->variables_disponibles;
    }

    public function procesarPlantilla($variables)
    {
        $asunto = $this->asunto;
        $contenidoHtml = $this->contenido_html;
        $contenidoTexto = $this->contenido_texto;

        foreach ($variables as $key => $value) {
            $asunto = str_replace("{{$key}}", $value, $asunto);
            $contenidoHtml = str_replace("{{$key}}", $value, $contenidoHtml);
            $contenidoTexto = str_replace("{{$key}}", $value, $contenidoTexto);
        }

        return [
            'asunto' => $asunto,
            'contenido_html' => $contenidoHtml,
            'contenido_texto' => $contenidoTexto,
        ];
    }
}
