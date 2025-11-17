-- Script de verificación rápida del WMS avanzado
-- Ejecutar después de las migraciones

USE [wms_escasan];
GO

PRINT '🔍 Verificando tablas del WMS avanzado...';
GO

-- Verificar tablas de ubicaciones avanzadas
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_ubicacion')
    PRINT '✅ Tabla tipos_ubicacion creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla tipos_ubicacion NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'zonas_almacen')
    PRINT '✅ Tabla zonas_almacen creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla zonas_almacen NO existe'

-- Verificar tablas de lotes y trazabilidad
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
    PRINT '✅ Tabla lotes creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla lotes NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
    PRINT '✅ Tabla movimientos_inventario creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla movimientos_inventario NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
    PRINT '✅ Tabla numeros_serie creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla numeros_serie NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
    PRINT '✅ Tabla trazabilidad_productos creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla trazabilidad_productos NO existe'

-- Verificar tablas de picking inteligente
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'oleadas_picking')
    PRINT '✅ Tabla oleadas_picking creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla oleadas_picking NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'pedidos_picking')
    PRINT '✅ Tabla pedidos_picking creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla pedidos_picking NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'pedidos_picking_detalle')
    PRINT '✅ Tabla pedidos_picking_detalle creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla pedidos_picking_detalle NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'rutas_picking')
    PRINT '✅ Tabla rutas_picking creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla rutas_picking NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'estadisticas_picking')
    PRINT '✅ Tabla estadisticas_picking creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla estadisticas_picking NO existe'

-- Verificar tablas de incidencias avanzadas
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_incidencia')
    PRINT '✅ Tabla tipos_incidencia creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla tipos_incidencia NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'seguimiento_incidencias')
    PRINT '✅ Tabla seguimiento_incidencias creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla seguimiento_incidencias NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_resolucion')
    PRINT '✅ Tabla plantillas_resolucion creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla plantillas_resolucion NO existe'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'metricas_incidencias')
    PRINT '✅ Tabla metricas_incidencias creada correctamente'
ELSE
    PRINT '❌ ERROR: Tabla metricas_incidencias NO existe'

-- Verificar columnas agregadas a tablas existentes
PRINT '';
PRINT '🔍 Verificando columnas agregadas...';

-- Verificar columnas en ubicaciones
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'tipo_ubicacion_id')
    PRINT '✅ Columna tipo_ubicacion_id agregada a ubicaciones'
ELSE
    PRINT '❌ ERROR: Columna tipo_ubicacion_id NO existe en ubicaciones'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'zona_id')
    PRINT '✅ Columna zona_id agregada a ubicaciones'
ELSE
    PRINT '❌ ERROR: Columna zona_id NO existe en ubicaciones'

-- Verificar columnas en inventario
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'lote_id')
    PRINT '✅ Columna lote_id agregada a inventario'
ELSE
    PRINT '❌ ERROR: Columna lote_id NO existe en inventario'

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'numero_serie_id')
    PRINT '✅ Columna numero_serie_id agregada a inventario'
ELSE
    PRINT '❌ ERROR: Columna numero_serie_id NO existe en inventario'

-- Verificar columnas en incidencias
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'tipo_incidencia_id')
    PRINT '✅ Columna tipo_incidencia_id agregada a incidencias'
ELSE
    PRINT '❌ ERROR: Columna tipo_incidencia_id NO existe en incidencias'

-- Verificar datos iniciales
PRINT '';
PRINT '📊 Verificando datos iniciales...';

DECLARE @tipos_ubicacion INT;
SELECT @tipos_ubicacion = COUNT(*) FROM tipos_ubicacion;
PRINT '📋 Tipos de ubicación: ' + CAST(@tipos_ubicacion AS NVARCHAR(10)) + ' registros';

DECLARE @zonas_almacen INT;
SELECT @zonas_almacen = COUNT(*) FROM zonas_almacen;
PRINT '🏢 Zonas de almacén: ' + CAST(@zonas_almacen AS NVARCHAR(10)) + ' registros';

DECLARE @tipos_incidencia INT;
SELECT @tipos_incidencia = COUNT(*) FROM tipos_incidencia;
PRINT '⚠️ Tipos de incidencia: ' + CAST(@tipos_incidencia AS NVARCHAR(10)) + ' registros';

DECLARE @plantillas_resolucion INT;
SELECT @plantillas_resolucion = COUNT(*) FROM plantillas_resolucion;
PRINT '📝 Plantillas de resolución: ' + CAST(@plantillas_resolucion AS NVARCHAR(10)) + ' registros';

PRINT '';
PRINT '🎉 Verificación completada!';
GO
