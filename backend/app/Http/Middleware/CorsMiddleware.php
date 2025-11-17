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
        // Obtener el origen de la petición PRIMERO
        $origin = $request->header('Origin');
        
        // SIEMPRE permitir dominios de Vercel (preview y producción)
        // Esta verificación debe ser lo primero que hacemos
        $isVercelOrigin = $origin && preg_match('/^https:\/\/.*\.vercel\.app$/', $origin);
        
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
        $getAllowedOrigin = function($origin) use ($allowedOrigins, $isVercelOrigin) {
            // Si no hay origen, devolver null (no establecer header)
            if (!$origin) {
                return null;
            }
            
            // SIEMPRE permitir dominios de Vercel PRIMERO (preview y producción)
            if ($isVercelOrigin) {
                return $origin; // Devolver el origen específico de Vercel
            }
            
            // Si hay un origen específico y está en la lista, usarlo
            if (in_array($origin, $allowedOrigins)) {
                return $origin;
            }
            
            // En desarrollo, permitir cualquier origen localhost/127.0.0.1
            if (env('APP_ENV') !== 'production') {
                // Verificar si es un origen local (desarrollo)
                if (preg_match('/^https?:\/\/(localhost|127\.0\.0\.1|::1)(:\d+)?$/', $origin)) {
                    return $origin; // Devolver el origen específico
                }
            }
            
            // En producción, verificar patrones con wildcards
            if (env('APP_ENV') === 'production') {
                // Permitir dominios personalizados de Vercel (si están en la lista)
                // O si el origen coincide con algún patrón permitido
                foreach ($allowedOrigins as $allowed) {
                    // Si el origen permitido es un patrón o coincide
                    if (strpos($allowed, '*') !== false) {
                        $pattern = str_replace('*', '.*', preg_quote($allowed, '/'));
                        if (preg_match("/^$pattern$/", $origin)) {
                            return $origin;
                        }
                    }
                }
            }
            
            // Si no coincide con ningún patrón, usar el primer origen permitido
            // PERO solo si hay orígenes configurados
            if (!empty($allowedOrigins)) {
                return $allowedOrigins[0];
            }
            
            // Si no hay orígenes configurados, devolver el origen recibido
            // (útil para desarrollo o cuando se confía en el origen)
            return $origin;
        };

        // Determinar el origen permitido
        $allowedOrigin = $getAllowedOrigin($origin);
        
        // Manejar peticiones OPTIONS (preflight)
        if ($request->isMethod('OPTIONS')) {
            // Si no hay origen permitido, devolver 200 sin headers CORS
            if (!$allowedOrigin) {
                return response('', 200);
            }
            
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

        // Si es un origen de Vercel o hay un origen permitido, establecer headers CORS
        if ($isVercelOrigin || $allowedOrigin) {
            $finalOrigin = $isVercelOrigin ? $origin : $allowedOrigin;
            
            // NUNCA usar '*' cuando hay credenciales
            $useCredentials = $finalOrigin !== '*';

            // Forzar los headers CORS - SIEMPRE establecerlos
            // Usar set() con true para forzar sobrescritura de headers existentes
            $response->headers->set('Access-Control-Allow-Origin', $finalOrigin, true);
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS', true);
            $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN', true);
            $response->headers->set('Access-Control-Max-Age', '86400', true);
            
            // Solo establecer credentials si no usamos '*'
            if ($useCredentials) {
                $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
            }
        }

        return $response;
    }
}