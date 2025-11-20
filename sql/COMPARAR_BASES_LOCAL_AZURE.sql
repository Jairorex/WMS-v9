-- ============================================================================
-- SCRIPT PARA COMPARAR ESTRUCTURA DE BASES DE DATOS
-- ============================================================================
-- Este script debe ejecutarse en la base de datos LOCAL
-- Compara la estructura con Azure (debes tener acceso a ambas)
-- ============================================================================

USE wms_escasan;
GO

-- ============================================================================
-- 1. LISTAR TODAS LAS TABLAS EN ESQUEMA wms
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '📋 TABLAS EN ESQUEMA wms (LOCAL)';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

SELECT 
    TABLE_NAME AS 'Tabla',
    (SELECT COUNT(*) 
     FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'wms' 
     AND TABLE_NAME = t.TABLE_NAME) AS 'Columnas'
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_SCHEMA = 'wms'
ORDER BY TABLE_NAME;

PRINT '';
PRINT 'Total de tablas: ' + CAST((SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms') AS NVARCHAR(10));
PRINT '';

-- ============================================================================
-- 2. DETALLE DE COLUMNAS POR TABLA
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '📊 DETALLE DE COLUMNAS - wms.productos';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

SELECT 
    COLUMN_NAME AS 'Columna',
    DATA_TYPE AS 'Tipo',
    CASE 
        WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL 
        THEN CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(10))
        WHEN NUMERIC_PRECISION IS NOT NULL 
        THEN CAST(NUMERIC_PRECISION AS NVARCHAR(10)) + ',' + CAST(NUMERIC_SCALE AS NVARCHAR(10))
        ELSE ''
    END AS 'Longitud/Precisión',
    IS_NULLABLE AS 'Nullable',
    COLUMN_DEFAULT AS 'Default',
    ORDINAL_POSITION AS 'Posición'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'productos'
ORDER BY ORDINAL_POSITION;

PRINT '';

-- ============================================================================
-- 3. ÍNDICES POR TABLA
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '🔍 ÍNDICES - wms.productos';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

SELECT 
    i.name AS 'Nombre Índice',
    CASE 
        WHEN i.is_primary_key = 1 THEN 'PRIMARY KEY'
        WHEN i.is_unique = 1 THEN 'UNIQUE'
        ELSE 'INDEX'
    END AS 'Tipo',
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS 'Columnas'
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'wms' AND t.name = 'productos' AND i.name IS NOT NULL
GROUP BY i.name, i.is_primary_key, i.is_unique
ORDER BY i.is_primary_key DESC, i.is_unique DESC, i.name;

PRINT '';

-- ============================================================================
-- 4. TABLAS QUE PROBABLEMENTE FALTAN EN AZURE
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '⚠️ TABLAS AVANZADAS (Probablemente faltantes en Azure)';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

-- Lista de tablas avanzadas que probablemente no están en Azure
DECLARE @TablasAvanzadas TABLE (nombre NVARCHAR(255));

INSERT INTO @TablasAvanzadas VALUES
('lotes'),
('movimientos_inventario'),
('numeros_serie'),
('trazabilidad_productos'),
('unidad_de_medida'),
('oleadas_picking'),
('pedidos_picking'),
('pedidos_picking_detalle'),
('rutas_picking'),
('estadisticas_picking'),
('tipos_incidencia'),
('seguimiento_incidencias'),
('plantillas_resolucion'),
('metricas_incidencias'),
('tipos_ubicacion'),
('zonas_almacen'),
('kpi_sistema'),
('kpi_historico'),
('metricas_tiempo_real'),
('widgets_dashboard'),
('alertas_dashboard'),
('tipos_notificacion'),
('cola_notificaciones'),
('log_notificaciones'),
('configuracion_notificacion_usuario');

SELECT 
    t.nombre AS 'Tabla',
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = t.nombre
        ) 
        THEN '✅ EXISTE' 
        ELSE '❌ NO EXISTE' 
    END AS 'Estado en Local'
FROM @TablasAvanzadas t
ORDER BY t.nombre;

PRINT '';

-- ============================================================================
-- 5. FOREIGN KEYS Y RELACIONES
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '🔗 FOREIGN KEYS - wms.productos';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

SELECT 
    fk.name AS 'Foreign Key',
    OBJECT_NAME(fk.parent_object_id) AS 'Tabla Origen',
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS 'Columna Origen',
    OBJECT_NAME(fk.referenced_object_id) AS 'Tabla Referenciada',
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS 'Columna Referenciada'
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fc ON fk.object_id = fc.constraint_object_id
INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'wms' AND OBJECT_NAME(fk.parent_object_id) = 'productos'
ORDER BY fk.name;

PRINT '';

-- ============================================================================
-- 6. RESUMEN DE ESTRUCTURA
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '📊 RESUMEN DE ESTRUCTURA';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

DECLARE @TotalTablas INT;
DECLARE @TotalColumnas INT;
DECLARE @TotalIndices INT;
DECLARE @TotalForeignKeys INT;

SELECT @TotalTablas = COUNT(*) 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'wms';

SELECT @TotalColumnas = COUNT(*) 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'wms';

SELECT @TotalIndices = COUNT(*) 
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'wms' AND i.name IS NOT NULL;

SELECT @TotalForeignKeys = COUNT(*) 
FROM sys.foreign_keys fk
INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'wms';

PRINT 'Total de tablas: ' + CAST(@TotalTablas AS NVARCHAR(10));
PRINT 'Total de columnas: ' + CAST(@TotalColumnas AS NVARCHAR(10));
PRINT 'Total de índices: ' + CAST(@TotalIndices AS NVARCHAR(10));
PRINT 'Total de foreign keys: ' + CAST(@TotalForeignKeys AS NVARCHAR(10));
PRINT '';

-- ============================================================================
-- 7. SCRIPT PARA COMPARAR CON AZURE (MANUAL)
-- ============================================================================
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '💡 INSTRUCCIONES PARA COMPARAR CON AZURE';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Para comparar con Azure, ejecuta este mismo script en Azure y compara:';
PRINT '1. El número total de tablas';
PRINT '2. Las tablas listadas en la sección "TABLAS AVANZADAS"';
PRINT '3. Las columnas de wms.productos';
PRINT '4. Los índices de wms.productos';
PRINT '';
PRINT 'O usa el script PHP: backend/comparar_bases_datos.php';
PRINT '';

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

