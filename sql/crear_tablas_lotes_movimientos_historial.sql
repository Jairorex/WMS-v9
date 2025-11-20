-- ============================================================================
-- SCRIPT PARA CREAR TABLAS FALTANTES: LOTES, MOVIMIENTOS_INVENTARIO Y TAREAS_LOG
-- ============================================================================
-- Este script crea las siguientes tablas en el esquema wms:
-- 1. wms.lotes - Gestión de lotes de productos
-- 2. wms.movimientos_inventario - Historial de movimientos de inventario
-- 3. wms.tareas_log - Historial de cambios en tareas
-- ============================================================================

USE [tu_base_de_datos]; -- Cambiar por el nombre de tu base de datos
GO

-- ============================================================================
-- TABLA: wms.lotes
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'lotes' AND schema_id = SCHEMA_ID('wms'))
BEGIN
    PRINT '📦 Creando tabla wms.lotes...';
    
    CREATE TABLE wms.lotes(
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo_lote NVARCHAR(50) NOT NULL,
        producto_id INT NOT NULL,
        cantidad_inicial DECIMAL(10,2) NOT NULL,
        cantidad_disponible DECIMAL(10,2) NOT NULL,
        fecha_fabricacion DATE NULL,
        fecha_caducidad DATE NULL,
        fecha_vencimiento DATE NULL,
        proveedor NVARCHAR(100) NULL,
        numero_serie NVARCHAR(50) NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
        observaciones NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2(7) NOT NULL DEFAULT (SYSDATETIME()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (SYSDATETIME()),
        CONSTRAINT uk_lotes_codigo UNIQUE (codigo_lote),
        CONSTRAINT fk_lotes_producto FOREIGN KEY (producto_id) REFERENCES wms.productos(id_producto) ON UPDATE CASCADE,
        CONSTRAINT chk_lotes_estado CHECK (estado IN ('DISPONIBLE', 'RESERVADO', 'AGOTADO', 'CADUCADO', 'BLOQUEADO'))
    );
    
    -- Índices para mejorar consultas
    CREATE INDEX IX_lotes_producto_id ON wms.lotes(producto_id);
    CREATE INDEX IX_lotes_codigo_lote ON wms.lotes(codigo_lote);
    CREATE INDEX IX_lotes_fecha_caducidad ON wms.lotes(fecha_caducidad);
    CREATE INDEX IX_lotes_estado ON wms.lotes(estado);
    CREATE INDEX IX_lotes_activo ON wms.lotes(activo);
    
    PRINT '✅ Tabla wms.lotes creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.lotes ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.movimientos_inventario
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'movimientos_inventario' AND schema_id = SCHEMA_ID('wms'))
BEGIN
    PRINT '📊 Creando tabla wms.movimientos_inventario...';
    
    CREATE TABLE wms.movimientos_inventario(
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
        usuario_id INT NULL,
        fecha_movimiento DATETIME2(7) NOT NULL DEFAULT (SYSDATETIME()),
        observaciones NVARCHAR(MAX) NULL,
        CONSTRAINT chk_movimientos_tipo CHECK (tipo_movimiento IN (
            'ENTRADA', 
            'SALIDA', 
            'TRASLADO', 
            'AJUSTE', 
            'DEVOLUCION',
            'RESERVA',
            'LIBERACION'
        )),
        CONSTRAINT fk_movimientos_lote FOREIGN KEY (lote_id) REFERENCES wms.lotes(id) ON DELETE SET NULL,
        CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id) REFERENCES wms.productos(id_producto) ON UPDATE CASCADE,
        CONSTRAINT fk_movimientos_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES wms.ubicaciones(id_ubicacion) ON DELETE SET NULL,
        CONSTRAINT fk_movimientos_usuario FOREIGN KEY (usuario_id) REFERENCES wms.usuarios(id_usuario) ON DELETE SET NULL
    );
    
    -- Índices para mejorar consultas
    CREATE INDEX IX_movimientos_lote_id ON wms.movimientos_inventario(lote_id);
    CREATE INDEX IX_movimientos_producto_id ON wms.movimientos_inventario(producto_id);
    CREATE INDEX IX_movimientos_ubicacion_id ON wms.movimientos_inventario(ubicacion_id);
    CREATE INDEX IX_movimientos_usuario_id ON wms.movimientos_inventario(usuario_id);
    CREATE INDEX IX_movimientos_tipo_movimiento ON wms.movimientos_inventario(tipo_movimiento);
    CREATE INDEX IX_movimientos_fecha_movimiento ON wms.movimientos_inventario(fecha_movimiento);
    
    PRINT '✅ Tabla wms.movimientos_inventario creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.movimientos_inventario ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.tareas_log
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tareas_log' AND schema_id = SCHEMA_ID('wms'))
BEGIN
    PRINT '📝 Creando tabla wms.tareas_log...';
    
    CREATE TABLE wms.tareas_log(
        id_log BIGINT IDENTITY(1,1) PRIMARY KEY,
        id_tarea INT NOT NULL,
        usuario_id INT NULL,
        estado_anterior NVARCHAR(50) NULL,
        estado_nuevo NVARCHAR(50) NULL,
        accion NVARCHAR(100) NULL,
        dispositivo NVARCHAR(500) NULL,
        ip_address NVARCHAR(50) NULL,
        comentarios NVARCHAR(MAX) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (SYSDATETIME()),
        CONSTRAINT fk_tareas_log_tarea FOREIGN KEY (id_tarea) REFERENCES wms.tareas(id_tarea) ON DELETE CASCADE,
        CONSTRAINT fk_tareas_log_usuario FOREIGN KEY (usuario_id) REFERENCES wms.usuarios(id_usuario) ON DELETE SET NULL
    );
    
    -- Índices para mejorar consultas
    CREATE INDEX IX_tareas_log_id_tarea ON wms.tareas_log(id_tarea);
    CREATE INDEX IX_tareas_log_usuario_id ON wms.tareas_log(usuario_id);
    CREATE INDEX IX_tareas_log_created_at ON wms.tareas_log(created_at);
    CREATE INDEX IX_tareas_log_estado_nuevo ON wms.tareas_log(estado_nuevo);
    
    PRINT '✅ Tabla wms.tareas_log creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.tareas_log ya existe';
END
GO

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT '✅ VERIFICACIÓN DE TABLAS CREADAS';
PRINT '========================================';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'lotes' AND schema_id = SCHEMA_ID('wms'))
    PRINT '✅ wms.lotes - EXISTE';
ELSE
    PRINT '❌ wms.lotes - NO EXISTE';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'movimientos_inventario' AND schema_id = SCHEMA_ID('wms'))
    PRINT '✅ wms.movimientos_inventario - EXISTE';
ELSE
    PRINT '❌ wms.movimientos_inventario - NO EXISTE';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tareas_log' AND schema_id = SCHEMA_ID('wms'))
    PRINT '✅ wms.tareas_log - EXISTE';
ELSE
    PRINT '❌ wms.tareas_log - NO EXISTE';

PRINT '';
PRINT '========================================';
PRINT '📊 RESUMEN DE COLUMNAS';
PRINT '========================================';

-- Mostrar columnas de lotes
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'lotes' AND schema_id = SCHEMA_ID('wms'))
BEGIN
    PRINT '';
    PRINT '📦 wms.lotes:';
    SELECT 
        COLUMN_NAME AS 'Columna',
        DATA_TYPE AS 'Tipo',
        IS_NULLABLE AS 'Nullable',
        COLUMN_DEFAULT AS 'Default'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'lotes'
    ORDER BY ORDINAL_POSITION;
END

-- Mostrar columnas de movimientos_inventario
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'movimientos_inventario' AND schema_id = SCHEMA_ID('wms'))
BEGIN
    PRINT '';
    PRINT '📊 wms.movimientos_inventario:';
    SELECT 
        COLUMN_NAME AS 'Columna',
        DATA_TYPE AS 'Tipo',
        IS_NULLABLE AS 'Nullable',
        COLUMN_DEFAULT AS 'Default'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'movimientos_inventario'
    ORDER BY ORDINAL_POSITION;
END

-- Mostrar columnas de tareas_log
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tareas_log' AND schema_id = SCHEMA_ID('wms'))
BEGIN
    PRINT '';
    PRINT '📝 wms.tareas_log:';
    SELECT 
        COLUMN_NAME AS 'Columna',
        DATA_TYPE AS 'Tipo',
        IS_NULLABLE AS 'Nullable',
        COLUMN_DEFAULT AS 'Default'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'tareas_log'
    ORDER BY ORDINAL_POSITION;
END

PRINT '';
PRINT '========================================';
PRINT '✅ Script completado';
PRINT '========================================';
GO

