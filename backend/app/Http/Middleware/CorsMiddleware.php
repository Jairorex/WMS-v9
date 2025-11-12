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
        // Obtener orígenes permitidos desde .env o usar valores por defecto
        $allowedOriginsEnv = env('CORS_ALLOWED_ORIGINS', '');
        $allowedOrigins = !empty($allowedOriginsEnv) 
            ? array_map('trim', explode(',', $allowedOriginsEnv)) 
            : [
                'http://localhost:5173',
                'http://localhost:5174',
                'http://127.0.0.1:5173',
                'http://127.0.0.1:5174',
            ];

        // Agregar APP_URL si está configurado
        if (env('APP_URL')) {
            $appUrl = rtrim(env('APP_URL'), '/');
            if (!in_array($appUrl, $allowedOrigins)) {
                $allowedOrigins[] = $appUrl;
            }
        }

        // Función para determinar el origen permitido
        $getAllowedOrigin = function($origin) use ($allowedOrigins) {
            // Si hay un origen específico y está en la lista, usarlo
            if ($origin && in_array($origin, $allowedOrigins)) {
                return $origin;
            }
            
            // Si hay un origen pero no está en la lista
            if ($origin) {
                // En desarrollo, permitir cualquier origen localhost/127.0.0.1
                if (env('APP_ENV') !== 'production') {
                    // Verificar si es un origen local (desarrollo)
                    if (preg_match('/^https?:\/\/(localhost|127\.0\.0\.1|::1)(:\d+)?$/', $origin)) {
                        return $origin; // Devolver el origen específico
                    }
                }
                // En producción, usar el primer origen permitido o el origen si no hay lista
                return $allowedOrigins[0] ?? $origin;
            }
            
            // Si no hay origen (apps móviles), usar '*' solo si no hay credenciales
            // Para apps móviles sin credenciales
            return env('APP_ENV') === 'production' 
                ? ($allowedOrigins[0] ?? '*') 
                : '*';
        };

        // Manejar peticiones OPTIONS (preflight)
        if ($request->isMethod('OPTIONS')) {
            $origin = $request->header('Origin');
            $allowedOrigin = $getAllowedOrigin($origin);
            
            // NUNCA usar '*' cuando hay credenciales - siempre usar origen específico
            $useCredentials = $allowedOrigin !== '*';

            return response('', 200)
                ->header('Access-Control-Allow-Origin', $allowedOrigin)
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN')
                ->header('Access-Control-Allow-Credentials', $useCredentials ? 'true' : 'false')
                ->header('Access-Control-Max-Age', '86400');
        }

        $response = $next($request);

        // Obtener el origen de la petición
        $origin = $request->header('Origin');
        $allowedOrigin = $getAllowedOrigin($origin);
        
        // NUNCA usar '*' cuando hay credenciales
        $useCredentials = $allowedOrigin !== '*';

        // Forzar los headers CORS
        $response->headers->set('Access-Control-Allow-Origin', $allowedOrigin);
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN');
        
        // Solo establecer credentials si no usamos '*'
        if ($useCredentials) {
            $response->headers->set('Access-Control-Allow-Credentials', 'true');
        }
        
        $response->headers->set('Access-Control-Max-Age', '86400');

        return $response;
    }
}