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
        // Obtener el origen de la petición
        $origin = $request->header('Origin');
        
        // SIEMPRE permitir dominios de Vercel (preview y producción)
        // Esta es la verificación más importante y debe ser simple
        $isVercelOrigin = $origin && preg_match('/^https:\/\/.*\.vercel\.app$/', $origin);
        
        // Determinar el origen permitido - SIMPLIFICADO
        $allowedOrigin = null;
        
        if ($isVercelOrigin) {
            // Si es Vercel, siempre permitirlo
            $allowedOrigin = $origin;
        } elseif ($origin) {
            // Obtener orígenes permitidos desde .env
            $allowedOriginsEnv = env('CORS_ALLOWED_ORIGINS', '');
            if (!empty($allowedOriginsEnv)) {
                $allowedOrigins = array_map('trim', explode(',', $allowedOriginsEnv));
                if (in_array($origin, $allowedOrigins)) {
                    $allowedOrigin = $origin;
                }
            }
            
            // En desarrollo, permitir localhost
            if (env('APP_ENV') !== 'production' && preg_match('/^https?:\/\/(localhost|127\.0\.0\.1|::1)(:\d+)?$/', $origin)) {
                $allowedOrigin = $origin;
            }
        }
        
        // Manejar peticiones OPTIONS (preflight) - CRÍTICO para CORS
        if ($request->isMethod('OPTIONS')) {
            if ($allowedOrigin) {
                return response('', 200)
                    ->header('Access-Control-Allow-Origin', $allowedOrigin)
                    ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
                    ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN')
                    ->header('Access-Control-Allow-Credentials', 'true')
                    ->header('Access-Control-Max-Age', '86400');
            }
            // Si no hay origen permitido, devolver 200 sin headers CORS
            return response('', 200);
        }

        // Procesar la petición normal
        $response = $next($request);

        // Establecer headers CORS en la respuesta
        if ($allowedOrigin) {
            $response->headers->set('Access-Control-Allow-Origin', $allowedOrigin, true);
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS', true);
            $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN', true);
            $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
            $response->headers->set('Access-Control-Max-Age', '86400', true);
        }

        return $response;
    }
}