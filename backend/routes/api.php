<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ProductoController;
use App\Http\Controllers\Api\InventarioController;
use App\Http\Controllers\Api\UbicacionController;
use App\Http\Controllers\Api\TareaController;
use App\Http\Controllers\Api\IncidenciaController;
use App\Http\Controllers\Api\PickingController;
use App\Http\Controllers\Api\RolController;
use App\Http\Controllers\Api\UsuarioController;
use App\Http\Controllers\Api\EstadoProductoController;
use App\Http\Controllers\Api\UnidadMedidaController;
use App\Http\Controllers\Api\LoteController;
use App\Http\Controllers\Api\MovimientoInventarioController;
use App\Http\Controllers\Api\NumeroSerieController;
use App\Http\Controllers\Api\TrazabilidadProductoController;
use App\Http\Controllers\Api\PickingInteligenteController;
use App\Http\Controllers\Api\DashboardAvanzadoController;
use App\Http\Controllers\Api\NotificacionController;
use App\Http\Controllers\Api\OrdenSalidaController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Rutas públicas
Route::post('/auth/login', [AuthController::class, 'login']);
Route::get('/roles', [RolController::class, 'index']);
Route::get('/estados-producto', [EstadoProductoController::class, 'index']);
Route::get('/unidades-medida-catalogos', [UnidadMedidaController::class, 'catalogos']);

// Rutas protegidas
Route::middleware('auth:sanctum')->group(function () {
    // Autenticación
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard/estadisticas', [DashboardController::class, 'estadisticas']);
    Route::get('/dashboard/actividad', [DashboardController::class, 'actividadReciente']);
    Route::get('/dashboard/resumen', [DashboardController::class, 'resumen']);

    // Dashboard Avanzado
    Route::prefix('dashboard-avanzado')->group(function () {
        Route::get('estadisticas', [DashboardAvanzadoController::class, 'estadisticas']);
        Route::get('datos-grafico', [DashboardAvanzadoController::class, 'datosGrafico']);
        Route::post('actualizar-kpi', [DashboardAvanzadoController::class, 'actualizarKpi']);
        Route::patch('alertas/{alerta}/resolver', [DashboardAvanzadoController::class, 'resolverAlerta']);
        Route::get('widgets', [DashboardAvanzadoController::class, 'widgets']);
        Route::post('widgets', [DashboardAvanzadoController::class, 'guardarWidget']);
        Route::delete('widgets/{widget}', [DashboardAvanzadoController::class, 'eliminarWidget']);
    });

    // Sistema de Notificaciones
    Route::prefix('notificaciones')->group(function () {
        Route::get('/', [NotificacionController::class, 'index']);
        Route::post('/', [NotificacionController::class, 'store']);
        Route::get('estadisticas', [NotificacionController::class, 'estadisticas']);
        Route::get('configuracion', [NotificacionController::class, 'configuracion']);
        Route::post('configuracion', [NotificacionController::class, 'actualizarConfiguracion']);
        Route::post('masiva', [NotificacionController::class, 'enviarMasiva']);
        Route::post('procesar-cola', [NotificacionController::class, 'procesarCola']);
        Route::patch('marcar-todas-leidas', [NotificacionController::class, 'marcarTodasLeidas']);
        Route::get('{notificacion}', [NotificacionController::class, 'show']);
        Route::patch('{notificacion}/marcar-leida', [NotificacionController::class, 'marcarLeida']);
        Route::delete('{notificacion}', [NotificacionController::class, 'destroy']);
    });

    // Productos
    Route::apiResource('productos', ProductoController::class);
    Route::patch('productos/{producto}/activar', [ProductoController::class, 'activar']);
    Route::patch('productos/{producto}/desactivar', [ProductoController::class, 'desactivar']);
    Route::get('productos-catalogos', [ProductoController::class, 'catalogos']);

    // Inventario
    Route::apiResource('inventario', InventarioController::class);
    Route::patch('inventario/{inventario}/ajustar', [InventarioController::class, 'ajustar']);

    // Lotes y Trazabilidad
    Route::apiResource('lotes', LoteController::class);
    Route::patch('lotes/{lote}/ajustar-cantidad', [LoteController::class, 'ajustarCantidad']);
    Route::patch('lotes/{lote}/reservar', [LoteController::class, 'reservar']);
    Route::patch('lotes/{lote}/liberar', [LoteController::class, 'liberar']);
    Route::patch('lotes/{lote}/cambiar-estado', [LoteController::class, 'cambiarEstado']);
    Route::get('lotes/{lote}/movimientos', [LoteController::class, 'movimientos']);
    Route::get('lotes/{lote}/trazabilidad', [LoteController::class, 'trazabilidad']);
    Route::get('lotes-estadisticas', [LoteController::class, 'estadisticas']);
    Route::get('lotes-alertas-caducidad', [LoteController::class, 'alertasCaducidad']);

    // Números de Serie
    Route::apiResource('numeros-serie', NumeroSerieController::class);
    Route::patch('numeros-serie/{numeroSerie}/cambiar-estado', [NumeroSerieController::class, 'cambiarEstado']);
    Route::patch('numeros-serie/{numeroSerie}/mover', [NumeroSerieController::class, 'mover']);

    // Movimientos de Inventario
    Route::apiResource('movimientos-inventario', MovimientoInventarioController::class);
    Route::get('movimientos-inventario/producto/{productoId}', [MovimientoInventarioController::class, 'porProducto']);
    Route::get('movimientos-inventario/ubicacion/{ubicacionId}', [MovimientoInventarioController::class, 'porUbicacion']);
    Route::get('movimientos-inventario/lote/{loteId}', [MovimientoInventarioController::class, 'porLote']);
    Route::get('movimientos-inventario/estadisticas', [MovimientoInventarioController::class, 'estadisticas']);
    Route::post('movimientos-inventario/resumen', [MovimientoInventarioController::class, 'resumen']);

    // Trazabilidad de Productos
    Route::apiResource('trazabilidad-productos', TrazabilidadProductoController::class);

    // Picking Inteligente
    Route::prefix('picking-inteligente')->group(function () {
        // Oleadas
        Route::get('oleadas', [PickingInteligenteController::class, 'indexOleadas']);
        Route::post('oleadas', [PickingInteligenteController::class, 'storeOleada']);
        Route::get('oleadas/{oleada}', [PickingInteligenteController::class, 'showOleada']);
        Route::put('oleadas/{oleada}', [PickingInteligenteController::class, 'updateOleada']);
        Route::delete('oleadas/{oleada}', [PickingInteligenteController::class, 'destroyOleada']);
        Route::patch('oleadas/{oleada}/iniciar', [PickingInteligenteController::class, 'iniciarOleada']);
        Route::patch('oleadas/{oleada}/completar', [PickingInteligenteController::class, 'completarOleada']);
        Route::patch('oleadas/{oleada}/cancelar', [PickingInteligenteController::class, 'cancelarOleada']);
        Route::post('oleadas/{oleada}/generar-ruta', [PickingInteligenteController::class, 'generarRutaOptimizada']);
        
        // Pedidos
        Route::get('pedidos', [PickingInteligenteController::class, 'indexPedidos']);
        Route::post('pedidos', [PickingInteligenteController::class, 'storePedido']);
        Route::get('pedidos/{pedido}', [PickingInteligenteController::class, 'showPedido']);
        Route::patch('pedidos/{pedido}/iniciar', [PickingInteligenteController::class, 'iniciarPedido']);
        Route::patch('pedidos/{pedido}/completar', [PickingInteligenteController::class, 'completarPedido']);
        
        // Detalles
        Route::get('detalles', [PickingInteligenteController::class, 'indexDetalles']);
        Route::patch('detalles/{detalle}/iniciar', [PickingInteligenteController::class, 'iniciarDetalle']);
        Route::patch('detalles/{detalle}/completar', [PickingInteligenteController::class, 'completarDetalle']);
        
        // Estadísticas
        Route::get('estadisticas', [PickingInteligenteController::class, 'estadisticas']);
        Route::get('reporte-operario/{operarioId}', [PickingInteligenteController::class, 'reporteOperario']);
        Route::get('reporte-diario', [PickingInteligenteController::class, 'reporteDiario']);
        Route::get('reporte-oleada/{oleada}', [PickingInteligenteController::class, 'reporteOleada']);
    });

    // Ubicaciones
    Route::apiResource('ubicaciones', UbicacionController::class);
    Route::patch('ubicaciones/{ubicacion}/activar', [UbicacionController::class, 'activar']);
    Route::patch('ubicaciones/{ubicacion}/desactivar', [UbicacionController::class, 'desactivar']);
    Route::get('ubicaciones-catalogos', [UbicacionController::class, 'catalogos']);

    // Tareas - Endpoint principal unificado
    Route::apiResource('tareas', TareaController::class);
    Route::patch('tareas/{tarea}/asignar', [TareaController::class, 'asignar']);
    Route::patch('tareas/{tarea}/cambiar-estado', [TareaController::class, 'cambiarEstado']);
    Route::patch('tareas/{tarea}/completar', [TareaController::class, 'completar']);
    Route::get('tareas-catalogos', [TareaController::class, 'catalogos']);

    // Rutas deprecadas - Delegar a TareaController con filtro aplicado
    // Estas rutas están deprecadas pero siguen funcionando para compatibilidad
    Route::prefix('picking')->group(function () {
        Route::get('/', function (Request $request) {
            // Simular request con filtro tipo=picking
            $newRequest = $request->duplicate();
            $newRequest->merge(['tipo' => 'picking']);
            return app(TareaController::class)->index($newRequest);
        });
    });

    Route::prefix('packing')->group(function () {
        Route::get('/', function (Request $request) {
            // Simular request con filtro tipo=packing
            $newRequest = $request->duplicate();
            $newRequest->merge(['tipo' => 'packing']);
            return app(TareaController::class)->index($newRequest);
        });
    });

    // Incidencias
    Route::apiResource('incidencias', IncidenciaController::class);
    Route::patch('incidencias/{incidencia}/resolver', [IncidenciaController::class, 'resolver']);
    Route::patch('incidencias/{incidencia}/reabrir', [IncidenciaController::class, 'reabrir']);
    Route::get('incidencias-catalogos', [IncidenciaController::class, 'catalogos']);

    // Picking
    Route::apiResource('picking', PickingController::class);
    Route::patch('picking/{picking}/asignar', [PickingController::class, 'asignar']);
    Route::patch('picking/{picking}/completar', [PickingController::class, 'completar']);
    Route::patch('picking/{picking}/cancelar', [PickingController::class, 'cancelar']);

    // Órdenes de Salida
    Route::apiResource('ordenes-salida', OrdenSalidaController::class);
    Route::patch('ordenes-salida/{id}/confirmar', [OrdenSalidaController::class, 'confirmar']);
    Route::patch('ordenes-salida/{id}/cancelar', [OrdenSalidaController::class, 'cancelar']);
    Route::get('ordenes-salida-catalogos', [OrdenSalidaController::class, 'catalogos']);

    // Usuarios
    Route::apiResource('usuarios', UsuarioController::class);
    Route::patch('usuarios/{usuario}/toggle-status', [UsuarioController::class, 'toggleStatus']);
    Route::get('usuarios-catalogos', [UsuarioController::class, 'catalogos']);

        // Roles
        Route::apiResource('roles', RolController::class);
        
        // Estados de Producto
    Route::get('estados-producto/{estadoProducto}', [EstadoProductoController::class, 'show']);

    // Unidades de Medida
        Route::apiResource('unidades-medida', UnidadMedidaController::class);
});
