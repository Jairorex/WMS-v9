<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductoRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'nombre' => 'sometimes|required|string|max:100',
            'descripcion' => 'nullable|string',
            'codigo_barra' => 'nullable|string|max:50|unique:productos,codigo_barra,' . $this->route('producto')->id_producto . ',id_producto',
            'lote' => 'sometimes|required|string|max:50',
            'estado_producto_id' => 'sometimes|required|exists:estados_producto,id_estado_producto',
            'fecha_caducidad' => 'nullable|date',
            'unidad_medida_id' => 'sometimes|required|exists:unidad_de_medida,id',
            'stock_minimo' => 'sometimes|required|integer|min:0',
            'precio' => 'nullable|numeric|min:0',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'unidad_medida_id.in' => 'La unidad de medida seleccionada no es válida',
            'unidad_medida_id.required' => 'La unidad de medida es requerida',
        ];
    }
}
