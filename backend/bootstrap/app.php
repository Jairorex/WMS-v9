<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Asegurar que CORS se ejecute PRIMERO, antes de cualquier otro middleware
        $middleware->prepend(\App\Http\Middleware\CorsMiddleware::class);
        $middleware->prependToGroup('web', \App\Http\Middleware\CorsMiddleware::class);
        $middleware->prependToGroup('api', \App\Http\Middleware\CorsMiddleware::class);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Loggear todos los errores para debugging
        $exceptions->report(function (\Throwable $e) {
            // Loggear el error completo
            \Log::error('Exception caught', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
        });
        
        // Manejar excepciones de manera más robusta
        $exceptions->render(function (\Throwable $e, \Illuminate\Http\Request $request) {
            // Loggear el error
            \Log::error('Rendering exception', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'url' => $request->fullUrl(),
            ]);
            
            // Si es una petición de API o tiene header Origin, devolver JSON con CORS
            if ($request->expectsJson() || $request->header('Origin') || $request->is('api/*')) {
                $origin = $request->header('Origin');
                $isVercelOrigin = $origin && (
                    preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
                    preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
                );
                
                // Siempre mostrar el error en producción para debugging
                $response = response()->json([
                    'message' => 'Internal server error',
                    'error' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'type' => get_class($e),
                ], 500);
                
                if ($isVercelOrigin && $origin) {
                    $response->headers->set('Access-Control-Allow-Origin', $origin, true);
                    $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
                }
                
                return $response;
            }
        });
    })->create();
