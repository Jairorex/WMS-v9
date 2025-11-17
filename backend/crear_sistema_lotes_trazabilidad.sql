-- Script para crear sistema de lotes y trazabilidad
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

-- 1. Tabla de lotes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'lotes' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[lotes] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [codigo_lote] VARCHAR(50) NOT NULL UNIQUE,
        [producto_id] INT NOT NULL,
        [cantidad_inicial] DECIMAL(10,2) NOT NULL,
        [cantidad_disponible] DECIMAL(10,2) NOT NULL,
        [fecha_fabricacion] DATE NOT NULL,
        [fecha_caducidad] DATE NULL,
        [fecha_vencimiento] DATE NULL,
        [proveedor] VARCHAR(100) NULL,
        [numero_serie] VARCHAR(50) NULL,
        [estado] VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
        [observaciones] TEXT NULL,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_lotes_producto] FOREIGN KEY ([producto_id]) 
        REFERENCES [dbo].[productos] ([id_producto])
    );

    -- Crear índices para optimizar consultas
    CREATE INDEX [IX_lotes_producto] ON [dbo].[lotes] ([producto_id]);
    CREATE INDEX [IX_lotes_codigo] ON [dbo].[lotes] ([codigo_lote]);
    CREATE INDEX [IX_lotes_fecha_caducidad] ON [dbo].[lotes] ([fecha_caducidad]);
    CREATE INDEX [IX_lotes_estado] ON [dbo].[lotes] ([estado]);

    PRINT 'Tabla [dbo].[lotes] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[lotes] ya existe.';
END
GO

-- 2. Tabla de movimientos de inventario (trazabilidad)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'movimientos_inventario' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[movimientos_inventario] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [lote_id] INT NOT NULL,
        [producto_id] INT NOT NULL,
        [ubicacion_id] INT NOT NULL,
        [tipo_movimiento] VARCHAR(20) NOT NULL,
        [cantidad] DECIMAL(10,2) NOT NULL,
        [cantidad_anterior] DECIMAL(10,2) NOT NULL,
        [cantidad_nueva] DECIMAL(10,2) NOT NULL,
        [motivo] VARCHAR(100) NULL,
        [referencia] VARCHAR(50) NULL, -- Referencia a tarea, picking, etc.
        [usuario_id] INT NOT NULL,
        [fecha_movimiento] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [observaciones] TEXT NULL,
        
        CONSTRAINT [FK_movimientos_lote] FOREIGN KEY ([lote_id]) 
        REFERENCES [dbo].[lotes] ([id]),
        
        CONSTRAINT [FK_movimientos_producto] FOREIGN KEY ([producto_id]) 
        REFERENCES [dbo].[productos] ([id_producto]),
        
        CONSTRAINT [FK_movimientos_ubicacion] FOREIGN KEY ([ubicacion_id]) 
        REFERENCES [dbo].[ubicaciones] ([id_ubicacion]),
        
        CONSTRAINT [FK_movimientos_usuario] FOREIGN KEY ([usuario_id]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices para optimizar consultas
    CREATE INDEX [IX_movimientos_lote] ON [dbo].[movimientos_inventario] ([lote_id]);
    CREATE INDEX [IX_movimientos_producto] ON [dbo].[movimientos_inventario] ([producto_id]);
    CREATE INDEX [IX_movimientos_ubicacion] ON [dbo].[movimientos_inventario] ([ubicacion_id]);
    CREATE INDEX [IX_movimientos_tipo] ON [dbo].[movimientos_inventario] ([tipo_movimiento]);
    CREATE INDEX [IX_movimientos_fecha] ON [dbo].[movimientos_inventario] ([fecha_movimiento]);

    PRINT 'Tabla [dbo].[movimientos_inventario] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[movimientos_inventario] ya existe.';
END
GO

-- 3. Tabla de números de serie
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'numeros_serie' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[numeros_serie] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [numero_serie] VARCHAR(50) NOT NULL UNIQUE,
        [numero_serie_ficticio] VARCHAR(50) NULL,
        [producto_id] INT NOT NULL,
        [lote_id] INT NULL,
        [ubicacion_id] INT NOT NULL,
        [estado] VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
        [fecha_fabricacion] DATE NULL,
        [fecha_caducidad] DATE NULL,
        [proveedor] VARCHAR(100) NULL,
        [observaciones] TEXT NULL,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_numeros_serie_producto] FOREIGN KEY ([producto_id]) 
        REFERENCES [dbo].[productos] ([id_producto]),
        
        CONSTRAINT [FK_numeros_serie_lote] FOREIGN KEY ([lote_id]) 
        REFERENCES [dbo].[lotes] ([id]),
        
        CONSTRAINT [FK_numeros_serie_ubicacion] FOREIGN KEY ([ubicacion_id]) 
        REFERENCES [dbo].[ubicaciones] ([id_ubicacion])
    );

    -- Crear índices
    CREATE INDEX [IX_numeros_serie_numero] ON [dbo].[numeros_serie] ([numero_serie]);
    CREATE INDEX [IX_numeros_serie_producto] ON [dbo].[numeros_serie] ([producto_id]);
    CREATE INDEX [IX_numeros_serie_lote] ON [dbo].[numeros_serie] ([lote_id]);
    CREATE INDEX [IX_numeros_serie_ubicacion] ON [dbo].[numeros_serie] ([ubicacion_id]);

    PRINT 'Tabla [dbo].[numeros_serie] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[numeros_serie] ya existe.';
END
GO

-- 4. Tabla de trazabilidad de productos
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'trazabilidad_productos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[trazabilidad_productos] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [producto_id] INT NOT NULL,
        [lote_id] INT NULL,
        [numero_serie_id] INT NULL,
        [evento] VARCHAR(50) NOT NULL,
        [descripcion] VARCHAR(255) NOT NULL,
        [ubicacion_origen] INT NULL,
        [ubicacion_destino] INT NULL,
        [cantidad] DECIMAL(10,2) NULL,
        [usuario_id] INT NOT NULL,
        [fecha_evento] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [referencia] VARCHAR(50) NULL,
        [observaciones] TEXT NULL,
        
        CONSTRAINT [FK_trazabilidad_producto] FOREIGN KEY ([producto_id]) 
        REFERENCES [dbo].[productos] ([id_producto]),
        
        CONSTRAINT [FK_trazabilidad_lote] FOREIGN KEY ([lote_id]) 
        REFERENCES [dbo].[lotes] ([id]),
        
        CONSTRAINT [FK_trazabilidad_numero_serie] FOREIGN KEY ([numero_serie_id]) 
        REFERENCES [dbo].[numeros_serie] ([id]),
        
        CONSTRAINT [FK_trazabilidad_ubicacion_origen] FOREIGN KEY ([ubicacion_origen]) 
        REFERENCES [dbo].[ubicaciones] ([id_ubicacion]),
        
        CONSTRAINT [FK_trazabilidad_ubicacion_destino] FOREIGN KEY ([ubicacion_destino]) 
        REFERENCES [dbo].[ubicaciones] ([id_ubicacion]),
        
        CONSTRAINT [FK_trazabilidad_usuario] FOREIGN KEY ([usuario_id]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_trazabilidad_producto] ON [dbo].[trazabilidad_productos] ([producto_id]);
    CREATE INDEX [IX_trazabilidad_lote] ON [dbo].[trazabilidad_productos] ([lote_id]);
    CREATE INDEX [IX_trazabilidad_numero_serie] ON [dbo].[trazabilidad_productos] ([numero_serie_id]);
    CREATE INDEX [IX_trazabilidad_evento] ON [dbo].[trazabilidad_productos] ([evento]);
    CREATE INDEX [IX_trazabilidad_fecha] ON [dbo].[trazabilidad_productos] ([fecha_evento]);

    PRINT 'Tabla [dbo].[trazabilidad_productos] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[trazabilidad_productos] ya existe.';
END
GO

-- 5. Actualizar tabla inventario para incluir lote_id
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.inventario') AND name = 'lote_id')
BEGIN
    ALTER TABLE [dbo].[inventario]
    ADD [lote_id] INT NULL,
        [numero_serie_id] INT NULL;

    -- Crear foreign keys
    ALTER TABLE [dbo].[inventario]
    ADD CONSTRAINT [FK_inventario_lote] FOREIGN KEY ([lote_id]) 
    REFERENCES [dbo].[lotes] ([id]);

    ALTER TABLE [dbo].[inventario]
    ADD CONSTRAINT [FK_inventario_numero_serie] FOREIGN KEY ([numero_serie_id]) 
    REFERENCES [dbo].[numeros_serie] ([id]);

    -- Crear índices
    CREATE INDEX [IX_inventario_lote] ON [dbo].[inventario] ([lote_id]);
    CREATE INDEX [IX_inventario_numero_serie] ON [dbo].[inventario] ([numero_serie_id]);

    PRINT 'Campos de lote y número de serie añadidos a [dbo].[inventario].';
END
ELSE
BEGIN
    PRINT 'Los campos de lote y número de serie ya existen en [dbo].[inventario].';
END
GO

PRINT 'Sistema de lotes y trazabilidad configurado exitosamente.';
