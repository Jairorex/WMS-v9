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
        try {
            // Obtener el origen de la petición
            $origin = $request->header('Origin');
            
            // Las aplicaciones móviles NO envían header Origin, así que debemos permitirlas
            $isMobileApp = !$origin;
            
            // SIEMPRE permitir dominios de Vercel (preview, producción y dominios personalizados)
            $isVercelOrigin = $origin && (
                preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
                preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
            );
            
            // Determinar el origen permitido
            $allowedOrigin = null;
            
            if ($isVercelOrigin) {
                // Si es Vercel, siempre permitirlo
                $allowedOrigin = $origin;
            } elseif ($isMobileApp) {
                // Aplicaciones móviles: permitir con wildcard o sin Origin
                // Usar '*' para permitir cualquier origen (solo para apps móviles)
                $allowedOrigin = '*';
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
                        ->header('Access-Control-Allow-Credentials', $isMobileApp ? 'false' : 'true')
                        ->header('Access-Control-Max-Age', '86400');
                }
                // Si no hay origen permitido, devolver 200 sin headers CORS
                return response('', 200);
            }

            // Procesar la petición normal
            $response = $next($request);

            // Establecer headers CORS en la respuesta
            if ($isVercelOrigin || $allowedOrigin) {
                $finalOrigin = $isVercelOrigin ? $origin : $allowedOrigin;
                $response->headers->set('Access-Control-Allow-Origin', $finalOrigin, true);
                $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS', true);
                $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, X-XSRF-TOKEN', true);
                $response->headers->set('Access-Control-Allow-Credentials', $isMobileApp ? 'false' : 'true', true);
                $response->headers->set('Access-Control-Max-Age', '86400', true);
            }

            return $response;
        } catch (\Exception $e) {
            // Si hay un error, devolver una respuesta básica con CORS
            $origin = $request->header('Origin');
            $isMobileApp = !$origin;
            $isVercelOrigin = $origin && (
                preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
                preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
            );
            
            $response = response()->json(['error' => 'Internal server error'], 500);
            
            // Agregar headers CORS para apps móviles o Vercel
            if ($isMobileApp) {
                $response->headers->set('Access-Control-Allow-Origin', '*', true);
                $response->headers->set('Access-Control-Allow-Credentials', 'false', true);
            } elseif ($isVercelOrigin) {
                $response->headers->set('Access-Control-Allow-Origin', $origin, true);
                $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
            }
            
            return $response;
        }
    }
}