<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Rutas de Sanctum para CSRF cookies (necesarias para autenticación SPA)
// Nota: Si usas tokens Bearer, esta ruta no es estrictamente necesaria
// Esta versión simplificada siempre devuelve 200 OK con headers CORS
Route::get('/sanctum/csrf-cookie', function () {
    // Versión simplificada que siempre funciona
    // Como usamos tokens Bearer, el CSRF cookie no es crítico
    $response = response()->json([
        'message' => 'CSRF cookie endpoint (using Bearer tokens)',
        'csrf_token' => null
    ], 200);
    
    // Asegurar que los headers CORS se establezcan (el middleware debería hacerlo, pero por si acaso)
    $origin = request()->header('Origin');
    if ($origin && preg_match('/^https:\/\/.*\.vercel\.app$/', $origin)) {
        $response->headers->set('Access-Control-Allow-Origin', $origin);
        $response->headers->set('Access-Control-Allow-Credentials', 'true');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN');
    }
    
    return $response;
});
