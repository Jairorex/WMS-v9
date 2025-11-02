<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EstadoProducto;
use Illuminate\Http\Request;

class EstadoProductoController extends Controller
{
    public function index(Request $request)
    {
        $estados = EstadoProducto::orderBy('nombre')->get();
        
        return response()->json([
            'data' => $estados
        ]);
    }

    public function show(EstadoProducto $estadoProducto)
    {
        return response()->json([
            'data' => $estadoProducto
        ]);
    }
}
