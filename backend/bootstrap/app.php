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
        // Manejar excepciones de manera más robusta
        $exceptions->render(function (\Throwable $e, \Illuminate\Http\Request $request) {
            // Si es una petición de API o tiene header Origin, devolver JSON con CORS
            if ($request->expectsJson() || $request->header('Origin')) {
                $origin = $request->header('Origin');
                $isVercelOrigin = $origin && (
                    preg_match('/^https:\/\/.*\.vercel\.app$/', $origin) ||
                    preg_match('/^https:\/\/wms-v9\.vercel\.app$/', $origin)
                );
                
                $response = response()->json([
                    'message' => 'Internal server error',
                    'error' => env('APP_DEBUG') ? $e->getMessage() : null,
                    'file' => env('APP_DEBUG') ? $e->getFile() : null,
                    'line' => env('APP_DEBUG') ? $e->getLine() : null,
                ], 500);
                
                if ($isVercelOrigin && $origin) {
                    $response->headers->set('Access-Control-Allow-Origin', $origin, true);
                    $response->headers->set('Access-Control-Allow-Credentials', 'true', true);
                }
                
                return $response;
            }
        });
    })->create();
