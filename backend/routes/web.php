<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Rutas de Sanctum para CSRF cookies (necesarias para autenticación SPA)
// Nota: Si usas tokens Bearer, esta ruta no es estrictamente necesaria
// Esta versión simplificada siempre devuelve 200 OK
Route::get('/sanctum/csrf-cookie', function () {
    // Versión simplificada que siempre funciona
    // Como usamos tokens Bearer, el CSRF cookie no es crítico
    return response()->json([
        'message' => 'CSRF cookie endpoint (using Bearer tokens)',
        'csrf_token' => null
    ], 200);
});
