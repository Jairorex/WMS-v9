-- Script simplificado para crear solo las tablas de lotes necesarias
-- Ejecutar en SQL Server Management Studio

USE [wms_escasan];
GO

PRINT '📦 Creando módulo de lotes simplificado...';
PRINT '========================================';
GO

-- 1. Tabla de lotes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
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
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_lotes_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto)
    );
    
    -- Crear índices
    CREATE INDEX IX_lotes_producto ON lotes (producto_id);
    CREATE INDEX IX_lotes_codigo ON lotes (codigo_lote);
    CREATE INDEX IX_lotes_fecha_caducidad ON lotes (fecha_caducidad);
    CREATE INDEX IX_lotes_estado ON lotes (estado);
    
    PRINT '✅ Tabla lotes creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla lotes ya existe';
END
GO

-- 2. Tabla de movimientos de inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
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
        usuario_id INT NOT NULL,
        fecha_movimiento DATETIME2 DEFAULT GETDATE(),
        observaciones NVARCHAR(MAX) NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_movimientos_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id),
        CONSTRAINT FK_movimientos_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto),
        CONSTRAINT FK_movimientos_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios (id),
        CONSTRAINT CHK_movimientos_tipo CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'TRASLADO', 'AJUSTE', 'DEVOLUCION'))
    );
    
    -- Crear índices
    CREATE INDEX IX_movimientos_lote ON movimientos_inventario (lote_id);
    CREATE INDEX IX_movimientos_producto ON movimientos_inventario (producto_id);
    CREATE INDEX IX_movimientos_fecha ON movimientos_inventario (fecha_movimiento);
    CREATE INDEX IX_movimientos_tipo ON movimientos_inventario (tipo_movimiento);
    
    PRINT '✅ Tabla movimientos_inventario creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla movimientos_inventario ya existe';
END
GO

-- 3. Tabla de números de serie
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
BEGIN
    CREATE TABLE numeros_serie (
        id INT IDENTITY(1,1) PRIMARY KEY,
        lote_id INT NULL,
        producto_id INT NOT NULL,
        numero_serie NVARCHAR(100) NOT NULL UNIQUE,
        estado NVARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
        ubicacion_id INT NULL,
        fecha_asignacion DATETIME2 NULL,
        usuario_asignacion INT NULL,
        observaciones NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_numeros_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id),
        CONSTRAINT FK_numeros_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto),
        CONSTRAINT FK_numeros_usuario FOREIGN KEY (usuario_asignacion) 
        REFERENCES usuarios (id),
        CONSTRAINT CHK_numeros_estado CHECK (estado IN ('DISPONIBLE', 'ASIGNADO', 'EN_TRANSITO', 'DANADO', 'PERDIDO'))
    );
    
    -- Crear índices
    CREATE INDEX IX_numeros_lote ON numeros_serie (lote_id);
    CREATE INDEX IX_numeros_producto ON numeros_serie (producto_id);
    CREATE INDEX IX_numeros_serie ON numeros_serie (numero_serie);
    CREATE INDEX IX_numeros_estado ON numeros_serie (estado);
    
    PRINT '✅ Tabla numeros_serie creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla numeros_serie ya existe';
END
GO

-- 4. Tabla de trazabilidad de productos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
BEGIN
    CREATE TABLE trazabilidad_productos (
        id INT IDENTITY(1,1) PRIMARY KEY,
        lote_id INT NULL,
        numero_serie_id INT NULL,
        producto_id INT NOT NULL,
        tipo_evento NVARCHAR(50) NOT NULL,
        descripcion_evento NVARCHAR(500) NULL,
        ubicacion_id INT NULL,
        usuario_id INT NOT NULL,
        fecha_evento DATETIME2 DEFAULT GETDATE(),
        referencia_documento NVARCHAR(100) NULL,
        datos_adicionales NVARCHAR(MAX) NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_trazabilidad_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id),
        CONSTRAINT FK_trazabilidad_numero FOREIGN KEY (numero_serie_id) 
        REFERENCES numeros_serie (id),
        CONSTRAINT FK_trazabilidad_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto),
        CONSTRAINT FK_trazabilidad_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios (id)
    );
    
    -- Crear índices
    CREATE INDEX IX_trazabilidad_lote ON trazabilidad_productos (lote_id);
    CREATE INDEX IX_trazabilidad_numero ON trazabilidad_productos (numero_serie_id);
    CREATE INDEX IX_trazabilidad_producto ON trazabilidad_productos (producto_id);
    CREATE INDEX IX_trazabilidad_fecha ON trazabilidad_productos (fecha_evento);
    
    PRINT '✅ Tabla trazabilidad_productos creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla trazabilidad_productos ya existe';
END
GO

-- 5. Agregar columnas de lote al inventario si no existen
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    -- Agregar columna lote_id si no existe
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'lote_id')
    BEGIN
        ALTER TABLE inventario ADD lote_id INT NULL;
        ALTER TABLE inventario ADD CONSTRAINT FK_inventario_lote FOREIGN KEY (lote_id) REFERENCES lotes (id);
        CREATE INDEX IX_inventario_lote ON inventario (lote_id);
        PRINT '✅ Columna lote_id agregada a tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Columna lote_id ya existe en tabla inventario';
    END
    
    -- Agregar columna numero_serie_id si no existe
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'numero_serie_id')
    BEGIN
        ALTER TABLE inventario ADD numero_serie_id INT NULL;
        ALTER TABLE inventario ADD CONSTRAINT FK_inventario_numero FOREIGN KEY (numero_serie_id) REFERENCES numeros_serie (id);
        CREATE INDEX IX_inventario_numero ON inventario (numero_serie_id);
        PRINT '✅ Columna numero_serie_id agregada a tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Columna numero_serie_id ya existe en tabla inventario';
    END
END
ELSE
BEGIN
    PRINT '❌ Tabla inventario no existe - no se pueden agregar columnas de lote';
END
GO

-- Insertar datos de prueba
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @lotes_count INT;
    SELECT @lotes_count = COUNT(*) FROM lotes;
    
    IF @lotes_count = 0
    BEGIN
        -- Insertar lotes de prueba
        INSERT INTO lotes (codigo_lote, producto_id, cantidad_inicial, cantidad_disponible, fecha_fabricacion, fecha_caducidad, proveedor, estado) VALUES
        ('LOTE-001-2024', 1, 100.00, 100.00, '2024-01-15', '2024-12-31', 'Proveedor A', 'DISPONIBLE'),
        ('LOTE-002-2024', 1, 50.00, 50.00, '2024-02-01', '2024-11-30', 'Proveedor B', 'DISPONIBLE'),
        ('LOTE-003-2024', 2, 75.00, 75.00, '2024-01-20', '2024-10-31', 'Proveedor A', 'DISPONIBLE');
        
        PRINT '✅ Datos de prueba insertados en tabla lotes';
    END
    ELSE
    BEGIN
        PRINT 'ℹ️ Tabla lotes ya contiene ' + CAST(@lotes_count AS NVARCHAR(10)) + ' registros';
    END
END
GO

PRINT '';
PRINT '🎉 ¡Módulo de lotes creado exitosamente!';
PRINT '======================================';
PRINT '';
PRINT '✅ Tablas creadas:';
PRINT '   📦 lotes - Gestión de lotes de productos';
PRINT '   📊 movimientos_inventario - Trazabilidad de movimientos';
PRINT '   🔢 numeros_serie - Gestión de números de serie';
PRINT '   📋 trazabilidad_productos - Historial de eventos';
PRINT '';
PRINT '✅ Modificaciones:';
PRINT '   🔗 Columnas lote_id y numero_serie_id agregadas a inventario';
PRINT '   📈 Índices optimizados para consultas rápidas';
PRINT '   🔒 Relaciones (foreign keys) establecidas';
PRINT '';
PRINT '✅ Datos:';
PRINT '   📝 Datos de prueba insertados';
PRINT '   🎯 Sistema listo para usar';
PRINT '';
PRINT '🚀 El módulo de lotes está completamente funcional!';
GO
