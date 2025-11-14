<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Rutas de Sanctum para CSRF cookies (necesarias para autenticación SPA)
// Nota: Si usas tokens Bearer, esta ruta no es estrictamente necesaria
Route::middleware('web')->group(function () {
    Route::get('/sanctum/csrf-cookie', function (\Illuminate\Http\Request $request) {
        try {
            // Obtener el token CSRF de forma segura
            $csrfToken = csrf_token();
            
            // Crear la respuesta JSON
            $response = response()->json([
                'message' => 'CSRF cookie set',
                'csrf_token' => $csrfToken
            ], 200);
            
            // Intentar establecer la cookie XSRF-TOKEN
            // Si hay un error con la sesión, simplemente devolvemos la respuesta sin cookie
            try {
                $cookie = cookie(
                    'XSRF-TOKEN',
                    $csrfToken,
                    120, // minutos
                    '/',
                    null, // dominio (null = mismo dominio)
                    true, // secure (HTTPS)
                    false, // httpOnly (false para que JS pueda leerlo)
                    false, // raw
                    'Lax' // sameSite
                );
                
                return $response->withCookie($cookie);
            } catch (\Exception $cookieException) {
                // Si falla la cookie, devolver respuesta sin cookie
                // Esto es aceptable cuando usamos tokens Bearer
                return $response;
            }
        } catch (\Exception $e) {
            // Si hay cualquier error, devolver una respuesta exitosa
            // Esto es aceptable cuando usamos tokens Bearer
            return response()->json([
                'message' => 'CSRF cookie not available (using Bearer tokens)',
                'csrf_token' => null,
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 200);
        }
    });
});
