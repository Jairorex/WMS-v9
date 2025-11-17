-- Script para ejecutar todas las migraciones del WMS avanzado
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

PRINT '🚀 Iniciando migraciones del WMS avanzado...';
GO

-- 1. Gestión avanzada de ubicaciones
PRINT '📍 Ejecutando migración: Gestión avanzada de ubicaciones...';
GO

-- Ejecutar script de ubicaciones avanzadas
:r backend/crear_ubicaciones_avanzadas.sql
GO

-- 2. Sistema de lotes y trazabilidad
PRINT '📋 Ejecutando migración: Sistema de lotes y trazabilidad...';
GO

-- Ejecutar script de lotes y trazabilidad
:r backend/crear_sistema_lotes_trazabilidad.sql
GO

-- 3. Sistema de picking inteligente
PRINT '🎯 Ejecutando migración: Sistema de picking inteligente...';
GO

-- Ejecutar script de picking inteligente
:r backend/crear_sistema_picking_inteligente.sql
GO

-- 4. Sistema de incidencias avanzado
PRINT '⚠️ Ejecutando migración: Sistema de incidencias avanzado...';
GO

-- Ejecutar script de incidencias avanzadas
:r backend/crear_sistema_incidencias_avanzado.sql
GO

-- 5. Verificar que todas las tablas se crearon correctamente
PRINT '✅ Verificando creación de tablas...';
GO

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN (
    'tipos_ubicacion',
    'zonas_almacen', 
    'lotes',
    'movimientos_inventario',
    'numeros_serie',
    'trazabilidad_productos',
    'oleadas_picking',
    'pedidos_picking',
    'pedidos_picking_detalle',
    'rutas_picking',
    'estadisticas_picking',
    'tipos_incidencia',
    'seguimiento_incidencias',
    'plantillas_resolucion',
    'metricas_incidencias'
)
ORDER BY TABLE_NAME;
GO

-- 6. Verificar que las columnas se agregaron correctamente
PRINT '🔍 Verificando columnas agregadas...';
GO

-- Verificar columnas en ubicaciones
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ubicaciones' 
AND COLUMN_NAME IN (
    'tipo_ubicacion_id',
    'zona_id',
    'coordenada_x',
    'coordenada_y',
    'coordenada_z',
    'temperatura_min',
    'temperatura_max',
    'humedad_min',
    'humedad_max',
    'activo'
);
GO

-- Verificar columnas en inventario
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'inventario' 
AND COLUMN_NAME IN ('lote_id', 'numero_serie_id');
GO

-- Verificar columnas en incidencias
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'incidencias' 
AND COLUMN_NAME IN (
    'tipo_incidencia_id',
    'prioridad',
    'categoria',
    'fecha_estimada_resolucion',
    'fecha_resolucion_real',
    'tiempo_resolucion_estimado',
    'tiempo_resolucion_real',
    'operario_resolucion',
    'supervisor_aprobacion',
    'fecha_aprobacion',
    'evidencia_fotos',
    'acciones_correctivas',
    'acciones_preventivas',
    'costo_estimado',
    'costo_real',
    'impacto_operaciones',
    'recurrencia',
    'incidencia_padre_id',
    'escalado',
    'fecha_escalado',
    'nivel_escalado',
    'activo'
);
GO

-- 7. Verificar datos iniciales
PRINT '📊 Verificando datos iniciales...';
GO

-- Verificar tipos de ubicación
SELECT COUNT(*) as 'Tipos de Ubicación' FROM tipos_ubicacion;
GO

-- Verificar zonas de almacén
SELECT COUNT(*) as 'Zonas de Almacén' FROM zonas_almacen;
GO

-- Verificar tipos de incidencia
SELECT COUNT(*) as 'Tipos de Incidencia' FROM tipos_incidencia;
GO

-- Verificar plantillas de resolución
SELECT COUNT(*) as 'Plantillas de Resolución' FROM plantillas_resolucion;
GO

PRINT '🎉 ¡Migraciones completadas exitosamente!';
PRINT '📋 Resumen de funcionalidades implementadas:';
PRINT '   ✅ Gestión avanzada de ubicaciones con coordenadas y tipos';
PRINT '   ✅ Sistema de lotes y trazabilidad completa';
PRINT '   ✅ Sistema de picking inteligente con oleadas';
PRINT '   ✅ Sistema de incidencias avanzado';
PRINT '';
PRINT '🚀 El sistema WMS avanzado está listo para usar!';
GO
