-- Script para verificar el estado del módulo de lotes
-- Ejecutar en SQL Server Management Studio

USE [wms_escasan];
GO

PRINT '🔍 Verificando estado del módulo de lotes...';
PRINT '=========================================';
GO

-- Verificar tablas relacionadas con lotes
DECLARE @tablas_lotes TABLE (
    tabla_nombre NVARCHAR(100),
    existe BIT,
    registros INT
);

-- Verificar tabla lotes
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @count_lotes INT;
    SELECT @count_lotes = COUNT(*) FROM lotes;
    INSERT INTO @tablas_lotes VALUES ('lotes', 1, @count_lotes);
    PRINT '✅ Tabla lotes existe con ' + CAST(@count_lotes AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('lotes', 0, 0);
    PRINT '❌ Tabla lotes NO existe';
END

-- Verificar tabla movimientos_inventario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
    DECLARE @count_movimientos INT;
    SELECT @count_movimientos = COUNT(*) FROM movimientos_inventario;
    INSERT INTO @tablas_lotes VALUES ('movimientos_inventario', 1, @count_movimientos);
    PRINT '✅ Tabla movimientos_inventario existe con ' + CAST(@count_movimientos AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('movimientos_inventario', 0, 0);
    PRINT '❌ Tabla movimientos_inventario NO existe';
END

-- Verificar tabla numeros_serie
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
BEGIN
    DECLARE @count_numeros INT;
    SELECT @count_numeros = COUNT(*) FROM numeros_serie;
    INSERT INTO @tablas_lotes VALUES ('numeros_serie', 1, @count_numeros);
    PRINT '✅ Tabla numeros_serie existe con ' + CAST(@count_numeros AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('numeros_serie', 0, 0);
    PRINT '❌ Tabla numeros_serie NO existe';
END

-- Verificar tabla trazabilidad_productos
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
BEGIN
    DECLARE @count_trazabilidad INT;
    SELECT @count_trazabilidad = COUNT(*) FROM trazabilidad_productos;
    INSERT INTO @tablas_lotes VALUES ('trazabilidad_productos', 1, @count_trazabilidad);
    PRINT '✅ Tabla trazabilidad_productos existe con ' + CAST(@count_trazabilidad AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('trazabilidad_productos', 0, 0);
    PRINT '❌ Tabla trazabilidad_productos NO existe';
END

-- Verificar tabla productos (necesaria para lotes)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'productos')
BEGIN
    DECLARE @count_productos INT;
    SELECT @count_productos = COUNT(*) FROM productos;
    INSERT INTO @tablas_lotes VALUES ('productos', 1, @count_productos);
    PRINT '✅ Tabla productos existe con ' + CAST(@count_productos AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('productos', 0, 0);
    PRINT '❌ Tabla productos NO existe';
END

-- Verificar tabla inventario (necesaria para lotes)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    DECLARE @count_inventario INT;
    SELECT @count_inventario = COUNT(*) FROM inventario;
    INSERT INTO @tablas_lotes VALUES ('inventario', 1, @count_inventario);
    PRINT '✅ Tabla inventario existe con ' + CAST(@count_inventario AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('inventario', 0, 0);
    PRINT '❌ Tabla inventario NO existe';
END

-- Mostrar resumen
PRINT '';
PRINT '📊 RESUMEN DEL MÓDULO DE LOTES:';
PRINT '==============================';

SELECT 
    tabla_nombre,
    CASE 
        WHEN existe = 1 THEN '✅ Existe'
        ELSE '❌ No existe'
    END as estado,
    registros
FROM @tablas_lotes
ORDER BY tabla_nombre;

-- Verificar si hay columnas de lote en inventario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'lote_id')
    BEGIN
        PRINT '✅ Columna lote_id existe en tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '❌ Columna lote_id NO existe en tabla inventario';
    END
    
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'numero_serie_id')
    BEGIN
        PRINT '✅ Columna numero_serie_id existe en tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '❌ Columna numero_serie_id NO existe en tabla inventario';
    END
END

-- Verificar foreign keys
PRINT '';
PRINT '🔗 VERIFICANDO RELACIONES:';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @fk_count INT;
    SELECT @fk_count = COUNT(*) 
    FROM sys.foreign_keys fk
    JOIN sys.tables t ON fk.parent_object_id = t.object_id
    WHERE t.name = 'lotes';
    
    PRINT 'Foreign keys en tabla lotes: ' + CAST(@fk_count AS NVARCHAR(10));
END

-- Verificar índices
PRINT '';
PRINT '📈 VERIFICANDO ÍNDICES:';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @indices_count INT;
    SELECT @indices_count = COUNT(*) 
    FROM sys.indexes i
    JOIN sys.tables t ON i.object_id = t.object_id
    WHERE t.name = 'lotes' AND i.name LIKE 'IX_%';
    
    PRINT 'Índices en tabla lotes: ' + CAST(@indices_count AS NVARCHAR(10));
END

PRINT '';
PRINT '🎯 DIAGNÓSTICO:';
PRINT '==============';

DECLARE @tablas_faltantes INT;
SELECT @tablas_faltantes = COUNT(*) FROM @tablas_lotes WHERE existe = 0;

IF @tablas_faltantes = 0
BEGIN
    PRINT '✅ Todas las tablas del módulo de lotes existen';
    PRINT '🚀 El módulo está listo para usar';
END
ELSE
BEGIN
    PRINT '❌ Faltan ' + CAST(@tablas_faltantes AS NVARCHAR(10)) + ' tablas del módulo de lotes';
    PRINT '📋 Se necesita ejecutar el script de creación de lotes';
END

GO
