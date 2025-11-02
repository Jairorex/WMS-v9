<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notificacion;
use App\Models\TipoNotificacion;
use App\Models\ConfiguracionNotificacionUsuario;
use App\Models\PlantillaEmail;
use App\Models\ColaNotificacion;
use App\Models\LogNotificacion;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class NotificacionController extends Controller
{
    /**
     * Obtener notificaciones del usuario autenticado
     */
    public function index(Request $request): JsonResponse
    {
        $usuarioId = auth()->id();
        
        $query = Notificacion::porUsuario($usuarioId)
            ->with(['tipoNotificacion'])
            ->noExpiradas();

        // Filtros
        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('prioridad')) {
            $query->where('prioridad', $request->prioridad);
        }

        if ($request->filled('categoria')) {
            $query->whereHas('tipoNotificacion', function($q) use ($request) {
                $q->where('categoria', $request->categoria);
            });
        }

        if ($request->filled('no_leidas')) {
            $query->whereNull('fecha_lectura');
        }

        $notificaciones = $query->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json($notificaciones);
    }

    /**
     * Crear nueva notificación
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'tipo_codigo' => 'required|string|max:50',
            'usuario_id' => 'required|exists:usuarios,id_usuario',
            'titulo' => 'required|string|max:200',
            'mensaje' => 'required|string|max:1000',
            'datos_adicionales' => 'nullable|array',
            'prioridad' => 'nullable|in:baja,media,alta,critica',
            'fecha_expiracion' => 'nullable|date|after:now',
        ]);

        $notificacion = $this->crearNotificacion($validated);

        return response()->json($notificacion, 201);
    }

    /**
     * Mostrar notificación específica
     */
    public function show(Notificacion $notificacion): JsonResponse
    {
        // Verificar que la notificación pertenece al usuario autenticado
        if ($notificacion->usuario_id !== auth()->id()) {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        return response()->json($notificacion->load(['tipoNotificacion', 'logs']));
    }

    /**
     * Marcar notificación como leída
     */
    public function marcarLeida(Notificacion $notificacion): JsonResponse
    {
        // Verificar que la notificación pertenece al usuario autenticado
        if ($notificacion->usuario_id !== auth()->id()) {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $notificacion->marcarComoLeida();

        return response()->json([
            'mensaje' => 'Notificación marcada como leída',
            'notificacion' => $notificacion,
        ]);
    }

    /**
     * Marcar todas las notificaciones como leídas
     */
    public function marcarTodasLeidas(): JsonResponse
    {
        $usuarioId = auth()->id();
        
        Notificacion::porUsuario($usuarioId)
            ->whereNull('fecha_lectura')
            ->update([
                'estado' => 'leida',
                'fecha_lectura' => now(),
            ]);

        return response()->json(['mensaje' => 'Todas las notificaciones marcadas como leídas']);
    }

    /**
     * Eliminar notificación
     */
    public function destroy(Notificacion $notificacion): JsonResponse
    {
        // Verificar que la notificación pertenece al usuario autenticado
        if ($notificacion->usuario_id !== auth()->id()) {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $notificacion->delete();

        return response()->json(['mensaje' => 'Notificación eliminada exitosamente']);
    }

    /**
     * Obtener configuración de notificaciones del usuario
     */
    public function configuracion(): JsonResponse
    {
        $usuarioId = auth()->id();
        
        $configuracion = ConfiguracionNotificacionUsuario::porUsuario($usuarioId)
            ->activos()
            ->with(['tipoNotificacion'])
            ->get()
            ->groupBy('tipoNotificacion.categoria');

        return response()->json($configuracion);
    }

    /**
     * Actualizar configuración de notificaciones
     */
    public function actualizarConfiguracion(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'tipo_notificacion_id' => 'required|exists:tipos_notificacion,id',
            'recibir_email' => 'boolean',
            'recibir_push' => 'boolean',
            'recibir_web' => 'boolean',
            'frecuencia_resumen' => 'nullable|in:inmediata,diaria,semanal,mensual',
            'hora_resumen' => 'nullable|date_format:H:i',
            'dias_resumen' => 'nullable|array',
        ]);

        $usuarioId = auth()->id();

        $configuracion = ConfiguracionNotificacionUsuario::updateOrCreate(
            [
                'usuario_id' => $usuarioId,
                'tipo_notificacion_id' => $validated['tipo_notificacion_id'],
            ],
            $validated
        );

        return response()->json([
            'mensaje' => 'Configuración actualizada exitosamente',
            'configuracion' => $configuracion,
        ]);
    }

    /**
     * Obtener estadísticas de notificaciones
     */
    public function estadisticas(): JsonResponse
    {
        $usuarioId = auth()->id();
        
        $estadisticas = [
            'total_notificaciones' => Notificacion::porUsuario($usuarioId)->count(),
            'no_leidas' => Notificacion::porUsuario($usuarioId)->whereNull('fecha_lectura')->count(),
            'por_prioridad' => Notificacion::porUsuario($usuarioId)
                ->selectRaw('prioridad, COUNT(*) as cantidad')
                ->groupBy('prioridad')
                ->get(),
            'por_categoria' => Notificacion::porUsuario($usuarioId)
                ->join('tipos_notificacion', 'notificaciones.tipo_notificacion_id', '=', 'tipos_notificacion.id')
                ->selectRaw('tipos_notificacion.categoria, COUNT(*) as cantidad')
                ->groupBy('tipos_notificacion.categoria')
                ->get(),
            'recientes' => Notificacion::porUsuario($usuarioId)
                ->recientes(24)
                ->count(),
        ];

        return response()->json($estadisticas);
    }

    /**
     * Enviar notificación masiva
     */
    public function enviarMasiva(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'tipo_codigo' => 'required|string|max:50',
            'usuario_ids' => 'required|array',
            'usuario_ids.*' => 'exists:usuarios,id_usuario',
            'titulo' => 'required|string|max:200',
            'mensaje' => 'required|string|max:1000',
            'datos_adicionales' => 'nullable|array',
            'prioridad' => 'nullable|in:baja,media,alta,critica',
        ]);

        $notificacionesCreadas = [];

        foreach ($validated['usuario_ids'] as $usuarioId) {
            $datos = $validated;
            $datos['usuario_id'] = $usuarioId;
            
            $notificacion = $this->crearNotificacion($datos);
            $notificacionesCreadas[] = $notificacion;
        }

        return response()->json([
            'mensaje' => 'Notificaciones masivas enviadas exitosamente',
            'notificaciones_creadas' => count($notificacionesCreadas),
            'notificaciones' => $notificacionesCreadas,
        ], 201);
    }

    /**
     * Procesar cola de notificaciones
     */
    public function procesarCola(): JsonResponse
    {
        $colaPendiente = ColaNotificacion::listasParaProcesar()
            ->with(['notificacion.tipoNotificacion', 'notificacion.usuario'])
            ->get();

        $procesadas = 0;
        $fallidas = 0;

        foreach ($colaPendiente as $item) {
            try {
                $item->marcarComoProcesando();
                
                $resultado = $this->enviarNotificacion($item);
                
                if ($resultado['exitoso']) {
                    $item->marcarComoEnviada();
                    $procesadas++;
                } else {
                    $item->marcarComoFallida($resultado['error']);
                    $fallidas++;
                }
                
                // Registrar en logs
                LogNotificacion::create([
                    'notificacion_id' => $item->notificacion_id,
                    'canal' => $item->canal,
                    'accion' => 'enviada',
                    'estado' => $resultado['exitoso'] ? 'exitoso' : 'fallido',
                    'mensaje' => $resultado['mensaje'],
                    'datos_adicionales' => $resultado['datos'],
                ]);
                
            } catch (\Exception $e) {
                $item->marcarComoFallida($e->getMessage());
                $fallidas++;
                
                LogNotificacion::create([
                    'notificacion_id' => $item->notificacion_id,
                    'canal' => $item->canal,
                    'accion' => 'enviada',
                    'estado' => 'fallido',
                    'mensaje' => $e->getMessage(),
                ]);
            }
        }

        return response()->json([
            'mensaje' => 'Cola de notificaciones procesada',
            'procesadas' => $procesadas,
            'fallidas' => $fallidas,
            'total' => $colaPendiente->count(),
        ]);
    }

    /**
     * Crear notificación usando procedimiento almacenado
     */
    private function crearNotificacion(array $datos): Notificacion
    {
        $resultado = DB::select('EXEC sp_crear_notificacion ?, ?, ?, ?, ?, ?, ?', [
            $datos['tipo_codigo'],
            $datos['usuario_id'],
            $datos['titulo'],
            $datos['mensaje'],
            json_encode($datos['datos_adicionales'] ?? []),
            $datos['prioridad'] ?? 'media',
            $datos['fecha_expiracion'] ?? null,
        ]);

        $notificacionId = $resultado[0]->notificacion_id ?? null;
        
        if (!$notificacionId) {
            throw new \Exception('No se pudo crear la notificación');
        }

        return Notificacion::with(['tipoNotificacion'])->find($notificacionId);
    }

    /**
     * Enviar notificación según el canal
     */
    private function enviarNotificacion(ColaNotificacion $item): array
    {
        $notificacion = $item->notificacion;
        $usuario = $notificacion->usuario;
        
        switch ($item->canal) {
            case 'email':
                return $this->enviarEmail($notificacion, $usuario);
                
            case 'push':
                return $this->enviarPush($notificacion, $usuario);
                
            case 'web':
                return $this->enviarWeb($notificacion, $usuario);
                
            default:
                return [
                    'exitoso' => false,
                    'error' => 'Canal no soportado',
                    'mensaje' => 'Canal de notificación no soportado',
                    'datos' => null,
                ];
        }
    }

    /**
     * Enviar notificación por email
     */
    private function enviarEmail(Notificacion $notificacion, $usuario): array
    {
        try {
            $tipo = $notificacion->tipoNotificacion;
            $plantilla = PlantillaEmail::porCodigo('PLANTILLA_BASE')->first();
            
            if (!$plantilla) {
                throw new \Exception('Plantilla de email no encontrada');
            }

            $variables = array_merge(
                $notificacion->datos_adicionales ?? [],
                [
                    'titulo' => $notificacion->titulo,
                    'mensaje' => $notificacion->mensaje,
                    'prioridad' => $notificacion->prioridad,
                    'fecha' => $notificacion->created_at->format('d/m/Y H:i'),
                    'usuario_nombre' => $usuario->nombre ?? 'Usuario',
                ]
            );

            $contenido = $plantilla->procesarPlantilla($variables);

            // Aquí se implementaría el envío real del email
            // Mail::to($usuario->email)->send(new NotificacionMail($contenido));

            return [
                'exitoso' => true,
                'mensaje' => 'Email enviado exitosamente',
                'datos' => [
                    'email' => $usuario->email ?? 'no_email',
                    'asunto' => $contenido['asunto'],
                ],
            ];
            
        } catch (\Exception $e) {
            return [
                'exitoso' => false,
                'error' => $e->getMessage(),
                'mensaje' => 'Error al enviar email',
                'datos' => null,
            ];
        }
    }

    /**
     * Enviar notificación push
     */
    private function enviarPush(Notificacion $notificacion, $usuario): array
    {
        try {
            // Aquí se implementaría el envío real de push notification
            // usando servicios como Firebase, OneSignal, etc.
            
            return [
                'exitoso' => true,
                'mensaje' => 'Push notification enviada exitosamente',
                'datos' => [
                    'usuario_id' => $usuario->id_usuario,
                    'titulo' => $notificacion->titulo,
                ],
            ];
            
        } catch (\Exception $e) {
            return [
                'exitoso' => false,
                'error' => $e->getMessage(),
                'mensaje' => 'Error al enviar push notification',
                'datos' => null,
            ];
        }
    }

    /**
     * Enviar notificación web
     */
    private function enviarWeb(Notificacion $notificacion, $usuario): array
    {
        try {
            // Aquí se implementaría el envío real de notificación web
            // usando WebSockets, Server-Sent Events, etc.
            
            return [
                'exitoso' => true,
                'mensaje' => 'Notificación web enviada exitosamente',
                'datos' => [
                    'usuario_id' => $usuario->id_usuario,
                    'notificacion_id' => $notificacion->id,
                ],
            ];
            
        } catch (\Exception $e) {
            return [
                'exitoso' => false,
                'error' => $e->getMessage(),
                'mensaje' => 'Error al enviar notificación web',
                'datos' => null,
            ];
        }
    }
}
