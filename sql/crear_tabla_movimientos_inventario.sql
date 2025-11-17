-- ============================================
-- Crear tabla movimientos_inventario
-- Sistema WMS Escasan
-- ============================================

USE wms_escasan;
GO

PRINT '🚀 Creando tabla movimientos_inventario...';
PRINT '========================================';
GO

-- Verificar y crear tabla movimientos_inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
    PRINT 'Creando tabla movimientos_inventario...';
    
    CREATE TABLE movimientos_inventario (
        id INT IDENTITY(1,1) PRIMARY KEY,
        lote_id INT NULL,
        producto_id INT NOT NULL,
        ubicacion_id INT NULL,
        tipo_movimiento NVARCHAR(20) NOT NULL,
        cantidad DECIMAL(10,2) NOT NULL,
        cantidad_anterior DECIMAL(10,2) NULL,
        cantidad_nueva DECIMAL(10,2) NULL,
        motivo NVARCHAR(200) NULL,
        referencia NVARCHAR(100) NULL,
        usuario_id INT NOT NULL,
        fecha_movimiento DATETIME2 NOT NULL DEFAULT GETDATE(),
        observaciones NVARCHAR(MAX) NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        
        -- Constraint para tipos de movimiento
        CONSTRAINT CHK_movimientos_tipo CHECK (tipo_movimiento IN (
            'ENTRADA', 
            'SALIDA', 
            'TRASLADO', 
            'AJUSTE', 
            'DEVOLUCION',
            'RESERVA',
            'LIBERACION'
        ))
    );
    
    PRINT '✅ Tabla movimientos_inventario creada exitosamente';
    
    -- Crear Foreign Keys solo si las tablas existen
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'productos')
    BEGIN
        ALTER TABLE movimientos_inventario
        ADD CONSTRAINT FK_movimientos_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto);
        PRINT '✅ Foreign Key hacia productos agregada';
    END
    
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ubicaciones')
    BEGIN
        ALTER TABLE movimientos_inventario
        ADD CONSTRAINT FK_movimientos_ubicacion FOREIGN KEY (ubicacion_id) 
        REFERENCES ubicaciones (id_ubicacion);
        PRINT '✅ Foreign Key hacia ubicaciones agregada';
    END
    
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'usuarios')
    BEGIN
        ALTER TABLE movimientos_inventario
        ADD CONSTRAINT FK_movimientos_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios (id);
        PRINT '✅ Foreign Key hacia usuarios agregada';
    END
    
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
    BEGIN
        ALTER TABLE movimientos_inventario
        ADD CONSTRAINT FK_movimientos_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id);
        PRINT '✅ Foreign Key hacia lotes agregada';
    END
    
    -- Crear índices para optimizar consultas
    CREATE INDEX IX_movimientos_lote ON movimientos_inventario (lote_id);
    CREATE INDEX IX_movimientos_producto ON movimientos_inventario (producto_id);
    CREATE INDEX IX_movimientos_ubicacion ON movimientos_inventario (ubicacion_id);
    CREATE INDEX IX_movimientos_fecha ON movimientos_inventario (fecha_movimiento);
    CREATE INDEX IX_movimientos_tipo ON movimientos_inventario (tipo_movimiento);
    CREATE INDEX IX_movimientos_usuario ON movimientos_inventario (usuario_id);
    
    PRINT '✅ Índices creados exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla movimientos_inventario ya existe';
    
    -- Verificar si necesita agregar campos faltantes
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'movimientos_inventario' AND COLUMN_NAME = 'referencia')
    BEGIN
        ALTER TABLE movimientos_inventario ADD referencia NVARCHAR(100) NULL;
        PRINT '✅ Columna referencia agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'movimientos_inventario' AND COLUMN_NAME = 'cantidad_anterior')
    BEGIN
        ALTER TABLE movimientos_inventario ADD cantidad_anterior DECIMAL(10,2) NULL;
        PRINT '✅ Columna cantidad_anterior agregada';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'movimientos_inventario' AND COLUMN_NAME = 'cantidad_nueva')
    BEGIN
        ALTER TABLE movimientos_inventario ADD cantidad_nueva DECIMAL(10,2) NULL;
        PRINT '✅ Columna cantidad_nueva agregada';
    END
    
    -- Verificar y crear índices faltantes
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_movimientos_lote' AND object_id = OBJECT_ID('movimientos_inventario'))
    BEGIN
        CREATE INDEX IX_movimientos_lote ON movimientos_inventario (lote_id);
        PRINT '✅ Índice IX_movimientos_lote creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_movimientos_producto' AND object_id = OBJECT_ID('movimientos_inventario'))
    BEGIN
        CREATE INDEX IX_movimientos_producto ON movimientos_inventario (producto_id);
        PRINT '✅ Índice IX_movimientos_producto creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_movimientos_ubicacion' AND object_id = OBJECT_ID('movimientos_inventario'))
    BEGIN
        CREATE INDEX IX_movimientos_ubicacion ON movimientos_inventario (ubicacion_id);
        PRINT '✅ Índice IX_movimientos_ubicacion creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_movimientos_fecha' AND object_id = OBJECT_ID('movimientos_inventario'))
    BEGIN
        CREATE INDEX IX_movimientos_fecha ON movimientos_inventario (fecha_movimiento);
        PRINT '✅ Índice IX_movimientos_fecha creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_movimientos_tipo' AND object_id = OBJECT_ID('movimientos_inventario'))
    BEGIN
        CREATE INDEX IX_movimientos_tipo ON movimientos_inventario (tipo_movimiento);
        PRINT '✅ Índice IX_movimientos_tipo creado';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_movimientos_usuario' AND object_id = OBJECT_ID('movimientos_inventario'))
    BEGIN
        CREATE INDEX IX_movimientos_usuario ON movimientos_inventario (usuario_id);
        PRINT '✅ Índice IX_movimientos_usuario creado';
    END
END
GO

-- Verificar la estructura de la tabla
PRINT '';
PRINT '=== Estructura de la tabla movimientos_inventario ===';
SELECT 
    COLUMN_NAME AS 'Columna',
    DATA_TYPE AS 'Tipo',
    IS_NULLABLE AS 'Nulleable',
    COLUMN_DEFAULT AS 'Valor por Defecto'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'movimientos_inventario'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '✅ Script completado exitosamente';
PRINT '';
PRINT '📝 NOTA: Si hay errores de Foreign Keys, asegúrate de que existan las tablas:';
PRINT '   - productos (columna id_producto)';
PRINT '   - ubicaciones (columna id_ubicacion)';
PRINT '   - usuarios (columna id)';
PRINT '   - lotes (columna id) - opcional';
GO