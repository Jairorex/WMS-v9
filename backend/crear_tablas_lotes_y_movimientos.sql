-- ============================================
-- Crear tablas de Lotes y Movimientos de Inventario
-- Sistema WMS Escasan
-- Ejecutar este script para instalar ambas tablas
-- ============================================

USE wms_escasan;
GO

PRINT '🚀 Instalando tablas de Lotes y Movimientos...';
PRINT '==============================================';
GO

-- ============================================
-- PASO 1: Crear tabla lotes (debe ir primero)
-- ============================================

PRINT '';
PRINT '📦 PASO 1: Creando tabla lotes...';
PRINT '================================';

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
        PRINT '⚠️ ADVERTENCIA: Tabla productos no existe. La FK será omitida.';
    END
    
    -- Crear índices
    CREATE INDEX IX_lotes_producto ON lotes (producto_id);
    CREATE INDEX IX_lotes_codigo ON lotes (codigo_lote);
    CREATE INDEX IX_lotes_fecha_caducidad ON lotes (fecha_caducidad);
    CREATE INDEX IX_lotes_estado ON lotes (estado);
    
    PRINT '✅ Índices de lotes creados exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla lotes ya existe';
END
GO

-- ============================================
-- PASO 2: Crear tabla movimientos_inventario
-- ============================================

PRINT '';
PRINT '📋 PASO 2: Creando tabla movimientos_inventario...';
PRINT '================================================';

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
    
    -- Crear índices
    CREATE INDEX IX_movimientos_lote ON movimientos_inventario (lote_id);
    CREATE INDEX IX_movimientos_producto ON movimientos_inventario (producto_id);
    CREATE INDEX IX_movimientos_ubicacion ON movimientos_inventario (ubicacion_id);
    CREATE INDEX IX_movimientos_fecha ON movimientos_inventario (fecha_movimiento);
    CREATE INDEX IX_movimientos_tipo ON movimientos_inventario (tipo_movimiento);
    CREATE INDEX IX_movimientos_usuario ON movimientos_inventario (usuario_id);
    
    PRINT '✅ Índices de movimientos_inventario creados exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla movimientos_inventario ya existe';
END
GO

-- ============================================
-- RESUMEN
-- ============================================

PRINT '';
PRINT '========================================';
PRINT '✅ INSTALACIÓN COMPLETADA';
PRINT '========================================';
PRINT '';

-- Verificar tablas creadas
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
    PRINT '✅ Tabla lotes: EXISTE';
ELSE
    PRINT '❌ Tabla lotes: NO EXISTE';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
    PRINT '✅ Tabla movimientos_inventario: EXISTE';
ELSE
    PRINT '❌ Tabla movimientos_inventario: NO EXISTE';

PRINT '';
PRINT '📝 NOTAS:';
PRINT '   - Si hay errores de Foreign Keys, asegúrate de que existan las tablas:';
PRINT '     • productos (columna id_producto)';
PRINT '     • ubicaciones (columna id_ubicacion)';
PRINT '     • usuarios (columna id)';
PRINT '   - La tabla lotes debe crearse ANTES que movimientos_inventario';
PRINT '';
GO
