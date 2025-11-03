<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CorsMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Manejar peticiones OPTIONS (preflight)
        if ($request->isMethod('OPTIONS')) {
            $origin = $request->header('Origin');
            
            $allowedOrigins = [
                'http://localhost:5173',
                'http://localhost:5174',
                'http://127.0.0.1:5173',
                'http://127.0.0.1:5174',
            ];

            // Para aplicaciones móviles: si no hay Origin o es null, permitir todas
            // En producción, deberías validar el origen específico
            $allowedOrigin = $origin && in_array($origin, $allowedOrigins) 
                ? $origin 
                : ($origin ?: '*');

            return response('', 200)
                ->header('Access-Control-Allow-Origin', $allowedOrigin)
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept')
                ->header('Access-Control-Allow-Credentials', $allowedOrigin !== '*' ? 'true' : 'false');
        }

        $response = $next($request);

        // Obtener el origen de la petición
        $origin = $request->header('Origin');
        
        // Lista de orígenes permitidos para web
        $allowedOrigins = [
            'http://localhost:5173',
            'http://localhost:5174',
            'http://127.0.0.1:5173',
            'http://127.0.0.1:5174',
        ];

        // Para aplicaciones móviles: si no hay Origin, permitir todas
        // En desarrollo: permitir cualquier origen
        // En producción: validar origen específico
        if ($origin && in_array($origin, $allowedOrigins)) {
            $allowedOrigin = $origin;
        } elseif (!$origin) {
            // Apps móviles pueden no enviar Origin
            $allowedOrigin = '*';
        } else {
            // En desarrollo, permitir cualquier origen
            // En producción, cambiar esto para rechazar orígenes desconocidos
            $allowedOrigin = env('APP_ENV') === 'production' ? 'http://localhost:5174' : '*';
        }

        // Forzar los headers CORS
        $response->headers->set('Access-Control-Allow-Origin', $allowedOrigin);
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
        
        // Con '*' no se puede usar credentials
        if ($allowedOrigin !== '*') {
            $response->headers->set('Access-Control-Allow-Credentials', 'true');
        }
        
        $response->headers->set('Access-Control-Max-Age', '86400');

        return $response;
    }
}