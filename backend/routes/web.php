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
// Nota: Si usas tokens Bearer, esta ruta no es estrictamente necesaria
// Esta versión simplificada siempre devuelve 200 OK con headers CORS
Route::match(['GET', 'OPTIONS'], '/sanctum/csrf-cookie', function () {
    try {
        $origin = request()->header('Origin');
        $isVercelOrigin = $origin && (
            preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
            preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
        );
        
        // Manejar peticiones OPTIONS (preflight)
        if (request()->isMethod('OPTIONS')) {
            if ($isVercelOrigin) {
                return response('', 200)
                    ->header('Access-Control-Allow-Origin', $origin)
                    ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
                    ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN')
                    ->header('Access-Control-Allow-Credentials', 'true')
                    ->header('Access-Control-Max-Age', '86400');
            }
            return response('', 200);
        }
        
        // Versión simplificada que siempre funciona
        // Como usamos tokens Bearer, el CSRF cookie no es crítico
        $response = response()->json([
            'message' => 'CSRF cookie endpoint (using Bearer tokens)',
            'csrf_token' => null
        ], 200);
        
        // Asegurar que los headers CORS se establezcan (el middleware debería hacerlo, pero por si acaso)
        if ($isVercelOrigin) {
            $response->headers->set('Access-Control-Allow-Origin', $origin, true);
            $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS', true);
            $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN', true);
        }
        
        return $response;
    } catch (\Exception $e) {
        // Si hay un error, devolver una respuesta con CORS
        $origin = request()->header('Origin');
        $isVercelOrigin = $origin && (
            preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
            preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
        );
        
        $response = response()->json([
            'message' => 'CSRF cookie endpoint (using Bearer tokens)',
            'csrf_token' => null,
            'error' => env('APP_DEBUG') ? $e->getMessage() : null
        ], 200);
        
        if ($isVercelOrigin) {
            $response->headers->set('Access-Control-Allow-Origin', $origin, true);
            $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS', true);
            $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN', true);
        }
        
        return $response;
    }
});
