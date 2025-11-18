<?php

use Illuminate\Support\Facades\Route;

// Ruta raíz simplificada (sin vista para evitar errores)
Route::get('/', function () {
    return response()->json([
        'message' => 'WMS API Backend',
        'version' => '1.0.0',
        'status' => 'running'
    ]);
});

// Rutas de Sanctum para CSRF cookies (necesarias para autenticación SPA)
// Versión ultra-simplificada que siempre funciona sin dependencias
Route::match(['GET', 'OPTIONS'], '/sanctum/csrf-cookie', function () {
    // Obtener origen de forma segura
    $origin = null;
    try {
        $origin = request()->header('Origin');
    } catch (\Exception $e) {
        // Si falla, continuar sin origen
    }
    
    // Verificar si es Vercel de forma segura
    $isVercelOrigin = false;
    if ($origin) {
        try {
            $isVercelOrigin = (
                preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
                preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
            );
        } catch (\Exception $e) {
            // Si falla, continuar sin verificación
        }
    }
    
    // Manejar peticiones OPTIONS (preflight)
    if (request()->isMethod('OPTIONS')) {
        $response = response('', 200);
        if ($isVercelOrigin && $origin) {
            $response->header('Access-Control-Allow-Origin', $origin);
            $response->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
            $response->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN');
            $response->header('Access-Control-Allow-Credentials', 'true');
            $response->header('Access-Control-Max-Age', '86400');
        }
        return $response;
    }
    
    // Respuesta JSON simple
    $response = response()->json([
        'message' => 'CSRF cookie endpoint (using Bearer tokens)',
        'csrf_token' => null
    ], 200);
    
    // Headers CORS si es Vercel
    if ($isVercelOrigin && $origin) {
        $response->header('Access-Control-Allow-Origin', $origin);
        $response->header('Access-Control-Allow-Credentials', 'true');
        $response->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN');
    }
    
    return $response;
});
