-- Script para crear sistema de picking inteligente con oleadas
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

-- 1. Tabla de oleadas de picking
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'oleadas_picking' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[oleadas_picking] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [nombre] VARCHAR(100) NOT NULL,
        [descripcion] VARCHAR(255) NULL,
        [fecha_creacion] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [fecha_inicio] DATETIME2 NULL,
        [fecha_fin] DATETIME2 NULL,
        [fecha_vencimiento] DATETIME2 NOT NULL,
        [estado] VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
        [prioridad] VARCHAR(10) NOT NULL DEFAULT 'MEDIA',
        [zona_id] INT NULL,
        [operario_asignado] INT NULL,
        [total_pedidos] INT NOT NULL DEFAULT 0,
        [pedidos_completados] INT NOT NULL DEFAULT 0,
        [total_items] INT NOT NULL DEFAULT 0,
        [items_completados] INT NOT NULL DEFAULT 0,
        [observaciones] TEXT NULL,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_oleadas_zona] FOREIGN KEY ([zona_id]) 
        REFERENCES [dbo].[zonas_almacen] ([id]),
        
        CONSTRAINT [FK_oleadas_operario] FOREIGN KEY ([operario_asignado]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_oleadas_estado] ON [dbo].[oleadas_picking] ([estado]);
    CREATE INDEX [IX_oleadas_operario] ON [dbo].[oleadas_picking] ([operario_asignado]);
    CREATE INDEX [IX_oleadas_zona] ON [dbo].[oleadas_picking] ([zona_id]);
    CREATE INDEX [IX_oleadas_fecha_vencimiento] ON [dbo].[oleadas_picking] ([fecha_vencimiento]);

    PRINT 'Tabla [dbo].[oleadas_picking] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[oleadas_picking] ya existe.';
END
GO

-- 2. Tabla de pedidos de picking
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'pedidos_picking' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[pedidos_picking] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [numero_pedido] VARCHAR(50) NOT NULL UNIQUE,
        [oleada_id] INT NOT NULL,
        [cliente] VARCHAR(100) NULL,
        [fecha_pedido] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [fecha_vencimiento] DATETIME2 NOT NULL,
        [prioridad] VARCHAR(10) NOT NULL DEFAULT 'MEDIA',
        [estado] VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
        [operario_asignado] INT NULL,
        [fecha_inicio] DATETIME2 NULL,
        [fecha_fin] DATETIME2 NULL,
        [total_items] INT NOT NULL DEFAULT 0,
        [items_completados] INT NOT NULL DEFAULT 0,
        [observaciones] TEXT NULL,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_pedidos_oleada] FOREIGN KEY ([oleada_id]) 
        REFERENCES [dbo].[oleadas_picking] ([id]),
        
        CONSTRAINT [FK_pedidos_operario] FOREIGN KEY ([operario_asignado]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_pedidos_oleada] ON [dbo].[pedidos_picking] ([oleada_id]);
    CREATE INDEX [IX_pedidos_estado] ON [dbo].[pedidos_picking] ([estado]);
    CREATE INDEX [IX_pedidos_operario] ON [dbo].[pedidos_picking] ([operario_asignado]);
    CREATE INDEX [IX_pedidos_fecha_vencimiento] ON [dbo].[pedidos_picking] ([fecha_vencimiento]);

    PRINT 'Tabla [dbo].[pedidos_picking] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[pedidos_picking] ya existe.';
END
GO

-- 3. Tabla de detalles de pedidos de picking
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'pedidos_picking_detalle' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[pedidos_picking_detalle] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [pedido_id] INT NOT NULL,
        [producto_id] INT NOT NULL,
        [lote_id] INT NULL,
        [numero_serie_id] INT NULL,
        [ubicacion_id] INT NOT NULL,
        [cantidad_solicitada] DECIMAL(10,2) NOT NULL,
        [cantidad_pickeada] DECIMAL(10,2) NOT NULL DEFAULT 0,
        [cantidad_confirmada] DECIMAL(10,2) NOT NULL DEFAULT 0,
        [estado] VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
        [operario_asignado] INT NULL,
        [fecha_inicio] DATETIME2 NULL,
        [fecha_fin] DATETIME2 NULL,
        [observaciones] TEXT NULL,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_pedidos_detalle_pedido] FOREIGN KEY ([pedido_id]) 
        REFERENCES [dbo].[pedidos_picking] ([id]),
        
        CONSTRAINT [FK_pedidos_detalle_producto] FOREIGN KEY ([producto_id]) 
        REFERENCES [dbo].[productos] ([id_producto]),
        
        CONSTRAINT [FK_pedidos_detalle_lote] FOREIGN KEY ([lote_id]) 
        REFERENCES [dbo].[lotes] ([id]),
        
        CONSTRAINT [FK_pedidos_detalle_numero_serie] FOREIGN KEY ([numero_serie_id]) 
        REFERENCES [dbo].[numeros_serie] ([id]),
        
        CONSTRAINT [FK_pedidos_detalle_ubicacion] FOREIGN KEY ([ubicacion_id]) 
        REFERENCES [dbo].[ubicaciones] ([id_ubicacion]),
        
        CONSTRAINT [FK_pedidos_detalle_operario] FOREIGN KEY ([operario_asignado]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_pedidos_detalle_pedido] ON [dbo].[pedidos_picking_detalle] ([pedido_id]);
    CREATE INDEX [IX_pedidos_detalle_producto] ON [dbo].[pedidos_picking_detalle] ([producto_id]);
    CREATE INDEX [IX_pedidos_detalle_ubicacion] ON [dbo].[pedidos_picking_detalle] ([ubicacion_id]);
    CREATE INDEX [IX_pedidos_detalle_estado] ON [dbo].[pedidos_picking_detalle] ([estado]);

    PRINT 'Tabla [dbo].[pedidos_picking_detalle] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[pedidos_picking_detalle] ya existe.';
END
GO

-- 4. Tabla de rutas de picking optimizadas
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'rutas_picking' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[rutas_picking] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [oleada_id] INT NOT NULL,
        [operario_id] INT NOT NULL,
        [nombre_ruta] VARCHAR(100) NOT NULL,
        [secuencia] INT NOT NULL,
        [ubicacion_id] INT NOT NULL,
        [producto_id] INT NOT NULL,
        [cantidad] DECIMAL(10,2) NOT NULL,
        [estado] VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
        [fecha_asignacion] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [fecha_inicio] DATETIME2 NULL,
        [fecha_fin] DATETIME2 NULL,
        [tiempo_estimado] INT NULL, -- en minutos
        [tiempo_real] INT NULL, -- en minutos
        [distancia_estimada] DECIMAL(10,2) NULL, -- en metros
        [distancia_real] DECIMAL(10,2) NULL, -- en metros
        [observaciones] TEXT NULL,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_rutas_oleada] FOREIGN KEY ([oleada_id]) 
        REFERENCES [dbo].[oleadas_picking] ([id]),
        
        CONSTRAINT [FK_rutas_operario] FOREIGN KEY ([operario_id]) 
        REFERENCES [dbo].[usuarios] ([id_usuario]),
        
        CONSTRAINT [FK_rutas_ubicacion] FOREIGN KEY ([ubicacion_id]) 
        REFERENCES [dbo].[ubicaciones] ([id_ubicacion]),
        
        CONSTRAINT [FK_rutas_producto] FOREIGN KEY ([producto_id]) 
        REFERENCES [dbo].[productos] ([id_producto])
    );

    -- Crear índices
    CREATE INDEX [IX_rutas_oleada] ON [dbo].[rutas_picking] ([oleada_id]);
    CREATE INDEX [IX_rutas_operario] ON [dbo].[rutas_picking] ([operario_id]);
    CREATE INDEX [IX_rutas_secuencia] ON [dbo].[rutas_picking] ([oleada_id], [operario_id], [secuencia]);
    CREATE INDEX [IX_rutas_estado] ON [dbo].[rutas_picking] ([estado]);

    PRINT 'Tabla [dbo].[rutas_picking] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[rutas_picking] ya existe.';
END
GO

-- 5. Tabla de estadísticas de picking
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'estadisticas_picking' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[estadisticas_picking] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [oleada_id] INT NULL,
        [operario_id] INT NOT NULL,
        [fecha] DATE NOT NULL,
        [total_pedidos] INT NOT NULL DEFAULT 0,
        [pedidos_completados] INT NOT NULL DEFAULT 0,
        [total_items] INT NOT NULL DEFAULT 0,
        [items_completados] INT NOT NULL DEFAULT 0,
        [tiempo_total] INT NOT NULL DEFAULT 0, -- en minutos
        [tiempo_promedio_por_pedido] DECIMAL(10,2) NOT NULL DEFAULT 0,
        [tiempo_promedio_por_item] DECIMAL(10,2) NOT NULL DEFAULT 0,
        [distancia_total] DECIMAL(10,2) NOT NULL DEFAULT 0, -- en metros
        [errores] INT NOT NULL DEFAULT 0,
        [precision_picking] DECIMAL(5,2) NOT NULL DEFAULT 0, -- porcentaje
        [eficiencia] DECIMAL(5,2) NOT NULL DEFAULT 0, -- porcentaje
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_estadisticas_oleada] FOREIGN KEY ([oleada_id]) 
        REFERENCES [dbo].[oleadas_picking] ([id]),
        
        CONSTRAINT [FK_estadisticas_operario] FOREIGN KEY ([operario_id]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_estadisticas_operario] ON [dbo].[estadisticas_picking] ([operario_id]);
    CREATE INDEX [IX_estadisticas_fecha] ON [dbo].[estadisticas_picking] ([fecha]);
    CREATE INDEX [IX_estadisticas_oleada] ON [dbo].[estadisticas_picking] ([oleada_id]);

    PRINT 'Tabla [dbo].[estadisticas_picking] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[estadisticas_picking] ya existe.';
END
GO

PRINT 'Sistema de picking inteligente con oleadas configurado exitosamente.';
