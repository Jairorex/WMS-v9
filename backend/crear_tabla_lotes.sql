-- ============================================
-- Crear tabla lotes
-- Sistema WMS Escasan
-- ============================================

USE wms_escasan;
GO

PRINT '🚀 Creando tabla lotes...';
PRINT '========================================';
GO

-- Verificar y crear tabla lotes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    PRINT 'Creando tabla lotes...';
    
    CREATE TABLE lotes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo_lote NVARCHAR(50) NOT NULL UNIQUE,
        producto_id INT NOT NULL,
        cantidad_inicial DECIMAL(10,2) NOT NULL,
        cantidad_disponible DECIMAL(10,2) NOT NULL,
        fecha_fabricacion DATE NOT NULL,
        fecha_caducidad DATE NULL,
        fecha_vencimiento DATE NULL,
        proveedor NVARCHAR(100) NULL,
        numero_serie NVARCHAR(50) NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
        observaciones NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '✅ Tabla lotes creada exitosamente';
    
    -- Crear Foreign Key hacia productos solo si existe la tabla
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'productos')
    BEGIN
        ALTER TABLE lotes
        ADD CONSTRAINT FK_lotes_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto);
        PRINT '✅ Foreign Key hacia productos agregada';
    END
    ELSE
    BEGIN
        PRINT '⚠️ ADVERTENCIA: Tabla productos no existe. La FK hacia productos será omitida.';
    END
    
    -- Crear índices para optimizar consultas
    CREATE INDEX IX_lotes_producto ON lotes (producto_id);
    CREATE INDEX IX_lotes_codigo ON lotes (codigo_lote);
    CREATE INDEX IX_lotes_fecha_caducidad ON lotes (fecha_caducidad);
    CREATE INDEX IX_lotes_estado ON lotes (estado);
    
    PRINT '✅ Índices creados exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla lotes ya existe';
    
    -- Verificar y agregar columnas faltantes si es necesario
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'lotes' AND COLUMN_NAME = 'fecha_vencimiento')
    BEGIN
        ALTER TABLE lotes ADD fecha_vencimiento DATE NULL;
        PRINT '✅ Columna fecha_vencimiento agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'lotes' AND COLUMN_NAME = 'proveedor')
    BEGIN
        ALTER TABLE lotes ADD proveedor NVARCHAR(100) NULL;
        PRINT '✅ Columna proveedor agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'lotes' AND COLUMN_NAME = 'numero_serie')
    BEGIN
        ALTER TABLE lotes ADD numero_serie NVARCHAR(50) NULL;
        PRINT '✅ Columna numero_serie agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'lotes' AND COLUMN_NAME = 'activo')
    BEGIN
        ALTER TABLE lotes ADD activo BIT NOT NULL DEFAULT 1;
        PRINT '✅ Columna activo agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'lotes' AND COLUMN_NAME = 'created_at')
    BEGIN
        ALTER TABLE lotes ADD created_at DATETIME2 DEFAULT GETDATE();
        PRINT '✅ Columna created_at agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'lotes' AND COLUMN_NAME = 'updated_at')
    BEGIN
        ALTER TABLE lotes ADD updated_at DATETIME2 DEFAULT GETDATE();
        PRINT '✅ Columna updated_at agregada';
    END
    
    -- Verificar y crear índices faltantes
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_lotes_producto' AND object_id = OBJECT_ID('lotes'))
    BEGIN
        CREATE INDEX IX_lotes_producto ON lotes (producto_id);
        PRINT '✅ Índice IX_lotes_producto creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_lotes_codigo' AND object_id = OBJECT_ID('lotes'))
    BEGIN
        CREATE INDEX IX_lotes_codigo ON lotes (codigo_lote);
        PRINT '✅ Índice IX_lotes_codigo creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_lotes_fecha_caducidad' AND object_id = OBJECT_ID('lotes'))
    BEGIN
        CREATE INDEX IX_lotes_fecha_caducidad ON lotes (fecha_caducidad);
        PRINT '✅ Índice IX_lotes_fecha_caducidad creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_lotes_estado' AND object_id = OBJECT_ID('lotes'))
    BEGIN
        CREATE INDEX IX_lotes_estado ON lotes (estado);
        PRINT '✅ Índice IX_lotes_estado creado';
    END
END
GO

-- Verificar la estructura de la tabla
PRINT '';
PRINT '=== Estructura de la tabla lotes ===';
SELECT 
    COLUMN_NAME AS 'Columna',
    DATA_TYPE AS 'Tipo',
    IS_NULLABLE AS 'Nulleable',
    COLUMN_DEFAULT AS 'Valor por Defecto'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'lotes'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '✅ Script completado exitosamente';
PRINT '';
PRINT '📝 NOTA: Si hay errores de Foreign Keys, asegúrate de que exista la tabla:';
PRINT '   - productos (columna id_producto)';
GO

