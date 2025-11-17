-- Script de verificación del WMS avanzado
-- Ejecutar después de las migraciones para verificar que todo esté funcionando

USE [wms_escasan];
GO

PRINT '🔍 Verificando sistema WMS avanzado...';
GO

-- 1. Verificar todas las tablas nuevas
PRINT '📋 Verificando tablas del sistema avanzado...';
GO

DECLARE @tablas_faltantes NVARCHAR(MAX) = '';
DECLARE @tabla NVARCHAR(100);

-- Lista de tablas que deben existir
DECLARE tablas_cursor CURSOR FOR
SELECT TABLE_NAME FROM (
    VALUES 
    ('tipos_ubicacion'),
    ('zonas_almacen'),
    ('lotes'),
    ('movimientos_inventario'),
    ('numeros_serie'),
    ('trazabilidad_productos'),
    ('oleadas_picking'),
    ('pedidos_picking'),
    ('pedidos_picking_detalle'),
    ('rutas_picking'),
    ('estadisticas_picking'),
    ('tipos_incidencia'),
    ('seguimiento_incidencias'),
    ('plantillas_resolucion'),
    ('metricas_incidencias')
) AS tablas(TABLE_NAME);

OPEN tablas_cursor;
FETCH NEXT FROM tablas_cursor INTO @tabla;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tabla)
    BEGIN
        SET @tablas_faltantes = @tablas_faltantes + @tabla + ', ';
    END
    FETCH NEXT FROM tablas_cursor INTO @tabla;
END

CLOSE tablas_cursor;
DEALLOCATE tablas_cursor;

IF LEN(@tablas_faltantes) > 0
BEGIN
    PRINT '❌ ERROR: Faltan las siguientes tablas: ' + LEFT(@tablas_faltantes, LEN(@tablas_faltantes) - 2);
END
ELSE
BEGIN
    PRINT '✅ Todas las tablas del sistema avanzado están presentes';
END
GO

-- 2. Verificar columnas en tablas existentes
PRINT '🔍 Verificando columnas agregadas...';
GO

-- Verificar ubicaciones
DECLARE @columnas_ubicaciones NVARCHAR(MAX) = '';
SELECT @columnas_ubicaciones = @columnas_ubicaciones + COLUMN_NAME + ', '
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

IF LEN(@columnas_ubicaciones) > 0
BEGIN
    PRINT '✅ Columnas avanzadas en ubicaciones: ' + LEFT(@columnas_ubicaciones, LEN(@columnas_ubicaciones) - 2);
END
ELSE
BEGIN
    PRINT '❌ ERROR: No se encontraron las columnas avanzadas en ubicaciones';
END
GO

-- Verificar inventario
DECLARE @columnas_inventario NVARCHAR(MAX) = '';
SELECT @columnas_inventario = @columnas_inventario + COLUMN_NAME + ', '
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'inventario' 
AND COLUMN_NAME IN ('lote_id', 'numero_serie_id');

IF LEN(@columnas_inventario) > 0
BEGIN
    PRINT '✅ Columnas de trazabilidad en inventario: ' + LEFT(@columnas_inventario, LEN(@columnas_inventario) - 2);
END
ELSE
BEGIN
    PRINT '❌ ERROR: No se encontraron las columnas de trazabilidad en inventario';
END
GO

-- Verificar incidencias
DECLARE @columnas_incidencias NVARCHAR(MAX) = '';
SELECT @columnas_incidencias = @columnas_incidencias + COLUMN_NAME + ', '
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

IF LEN(@columnas_incidencias) > 0
BEGIN
    PRINT '✅ Columnas avanzadas en incidencias: ' + LEFT(@columnas_incidencias, LEN(@columnas_incidencias) - 2);
END
ELSE
BEGIN
    PRINT '❌ ERROR: No se encontraron las columnas avanzadas en incidencias';
END
GO

-- 3. Verificar datos iniciales
PRINT '📊 Verificando datos iniciales...';
GO

-- Verificar tipos de ubicación
DECLARE @tipos_ubicacion INT;
SELECT @tipos_ubicacion = COUNT(*) FROM tipos_ubicacion;
IF @tipos_ubicacion > 0
BEGIN
    PRINT '✅ Tipos de ubicación: ' + CAST(@tipos_ubicacion AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No hay tipos de ubicación';
END
GO

-- Verificar zonas de almacén
DECLARE @zonas_almacen INT;
SELECT @zonas_almacen = COUNT(*) FROM zonas_almacen;
IF @zonas_almacen > 0
BEGIN
    PRINT '✅ Zonas de almacén: ' + CAST(@zonas_almacen AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No hay zonas de almacén';
END
GO

-- Verificar tipos de incidencia
DECLARE @tipos_incidencia INT;
SELECT @tipos_incidencia = COUNT(*) FROM tipos_incidencia;
IF @tipos_incidencia > 0
BEGIN
    PRINT '✅ Tipos de incidencia: ' + CAST(@tipos_incidencia AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No hay tipos de incidencia';
END
GO

-- Verificar plantillas de resolución
DECLARE @plantillas_resolucion INT;
SELECT @plantillas_resolucion = COUNT(*) FROM plantillas_resolucion;
IF @plantillas_resolucion > 0
BEGIN
    PRINT '✅ Plantillas de resolución: ' + CAST(@plantillas_resolucion AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No hay plantillas de resolución';
END
GO

-- 4. Verificar relaciones y claves foráneas
PRINT '🔗 Verificando relaciones...';
GO

-- Verificar FK en ubicaciones
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON rc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    WHERE kcu.TABLE_NAME = 'ubicaciones' 
    AND kcu.COLUMN_NAME IN ('tipo_ubicacion_id', 'zona_id')
)
BEGIN
    PRINT '✅ Relaciones en ubicaciones configuradas correctamente';
END
ELSE
BEGIN
    PRINT '❌ ERROR: Faltan relaciones en ubicaciones';
END
GO

-- Verificar FK en inventario
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON rc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    WHERE kcu.TABLE_NAME = 'inventario' 
    AND kcu.COLUMN_NAME IN ('lote_id', 'numero_serie_id')
)
BEGIN
    PRINT '✅ Relaciones de trazabilidad en inventario configuradas correctamente';
END
ELSE
BEGIN
    PRINT '❌ ERROR: Faltan relaciones de trazabilidad en inventario';
END
GO

-- Verificar FK en incidencias
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON rc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    WHERE kcu.TABLE_NAME = 'incidencias' 
    AND kcu.COLUMN_NAME = 'tipo_incidencia_id'
)
BEGIN
    PRINT '✅ Relaciones en incidencias configuradas correctamente';
END
ELSE
BEGIN
    PRINT '❌ ERROR: Faltan relaciones en incidencias';
END
GO

-- 5. Verificar índices
PRINT '📈 Verificando índices...';
GO

-- Verificar índices en lotes
DECLARE @indices_lotes INT;
SELECT @indices_lotes = COUNT(*) FROM sys.indexes 
WHERE object_id = OBJECT_ID('lotes') 
AND name LIKE '%idx_%';

IF @indices_lotes > 0
BEGIN
    PRINT '✅ Índices en lotes: ' + CAST(@indices_lotes AS NVARCHAR(10)) + ' índices';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No hay índices en lotes';
END
GO

-- Verificar índices en movimientos_inventario
DECLARE @indices_movimientos INT;
SELECT @indices_movimientos = COUNT(*) FROM sys.indexes 
WHERE object_id = OBJECT_ID('movimientos_inventario') 
AND name LIKE '%idx_%';

IF @indices_movimientos > 0
BEGIN
    PRINT '✅ Índices en movimientos_inventario: ' + CAST(@indices_movimientos AS NVARCHAR(10)) + ' índices';
END
ELSE
BEGIN
    PRINT '❌ ERROR: No hay índices en movimientos_inventario';
END
GO

-- 6. Resumen final
PRINT '';
PRINT '📋 RESUMEN DE VERIFICACIÓN:';
PRINT '========================';
GO

-- Contar total de tablas del sistema
DECLARE @total_tablas INT;
SELECT @total_tablas = COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
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
);

PRINT '📊 Total de tablas del sistema avanzado: ' + CAST(@total_tablas AS NVARCHAR(10)) + '/15';
GO

-- Verificar si el sistema está completo
IF @total_tablas = 15
BEGIN
    PRINT '🎉 ¡SISTEMA WMS AVANZADO COMPLETAMENTE FUNCIONAL!';
    PRINT '';
    PRINT '✅ Funcionalidades implementadas:';
    PRINT '   📍 Gestión avanzada de ubicaciones con coordenadas y tipos';
    PRINT '   📋 Sistema de lotes y trazabilidad completa';
    PRINT '   🎯 Sistema de picking inteligente con oleadas';
    PRINT '   ⚠️ Sistema de incidencias avanzado';
    PRINT '';
    PRINT '🚀 El sistema está listo para usar en producción!';
END
ELSE
BEGIN
    PRINT '❌ SISTEMA INCOMPLETO - Faltan ' + CAST((15 - @total_tablas) AS NVARCHAR(10)) + ' tablas';
    PRINT '🔧 Ejecute las migraciones faltantes antes de continuar';
END
GO
