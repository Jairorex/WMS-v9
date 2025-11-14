<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Rutas de Sanctum para CSRF cookies (necesarias para autenticación SPA)
// Nota: Si usas tokens Bearer, esta ruta no es estrictamente necesaria
Route::middleware('web')->group(function () {
    Route::get('/sanctum/csrf-cookie', function (\Illuminate\Http\Request $request) {
        // Establecer la cookie de sesión para CSRF
        $request->session()->regenerateToken();
        
        return response()->json([
            'message' => 'CSRF cookie set',
            'csrf_token' => csrf_token()
        ], 200)->withCookie(
            cookie('XSRF-TOKEN', csrf_token(), 120, '/', null, true, false, false, 'Lax')
        );
    });
});
