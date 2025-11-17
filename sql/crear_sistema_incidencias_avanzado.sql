-- Script para crear sistema de incidencias avanzado
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

-- 1. Tabla de tipos de incidencia
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tipos_incidencia' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[tipos_incidencia] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [codigo] VARCHAR(20) NOT NULL UNIQUE,
        [nombre] VARCHAR(50) NOT NULL,
        [descripcion] VARCHAR(255) NULL,
        [categoria] VARCHAR(30) NOT NULL,
        [tiempo_resolucion_estimado] INT NULL, -- en minutos
        [es_critica] BIT NOT NULL DEFAULT 0,
        [requiere_aprobacion] BIT NOT NULL DEFAULT 0,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE()
    );

    -- Insertar tipos básicos
    INSERT INTO [dbo].[tipos_incidencia] ([codigo], [nombre], [descripcion], [categoria], [tiempo_resolucion_estimado], [es_critica]) VALUES
    ('DIF_INVENTARIO', 'Diferencia de Inventario', 'Diferencias entre stock físico y registrado', 'INVENTARIO', 30, 0),
    ('PROD_DANADO', 'Producto Dañado', 'Productos encontrados en mal estado', 'CALIDAD', 15, 1),
    ('UBIC_BLOQUEADA', 'Ubicación Bloqueada', 'Ubicación no disponible para uso', 'UBICACION', 60, 0),
    ('PEDIDO_INCOMPLETO', 'Pedido Incompleto', 'Pedido con items faltantes', 'PICKING', 45, 1),
    ('EQUIPO_FALLA', 'Falla de Equipo', 'Malfuncionamiento de equipos', 'EQUIPO', 120, 1),
    ('SEGURIDAD', 'Incidente de Seguridad', 'Problemas relacionados con seguridad', 'SEGURIDAD', 30, 1),
    ('CALIDAD_DEFECTUOSO', 'Producto Defectuoso', 'Productos con defectos de calidad', 'CALIDAD', 20, 0),
    ('UBIC_INCORRECTA', 'Ubicación Incorrecta', 'Producto en ubicación incorrecta', 'UBICACION', 15, 0);

    PRINT 'Tabla [dbo].[tipos_incidencia] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[tipos_incidencia] ya existe.';
END
GO

-- 2. Actualizar tabla incidencias existente con campos avanzados
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.incidencias') AND name = 'tipo_incidencia_id')
BEGIN
    ALTER TABLE [dbo].[incidencias]
    ADD [tipo_incidencia_id] INT NULL,
        [prioridad] VARCHAR(10) NOT NULL DEFAULT 'MEDIA',
        [categoria] VARCHAR(30) NULL,
        [fecha_estimada_resolucion] DATETIME2 NULL,
        [fecha_resolucion_real] DATETIME2 NULL,
        [tiempo_resolucion_estimado] INT NULL, -- en minutos
        [tiempo_resolucion_real] INT NULL, -- en minutos
        [operario_resolucion] INT NULL,
        [supervisor_aprobacion] INT NULL,
        [fecha_aprobacion] DATETIME2 NULL,
        [evidencia_fotos] TEXT NULL, -- JSON con URLs de fotos
        [acciones_correctivas] TEXT NULL,
        [acciones_preventivas] TEXT NULL,
        [costo_estimado] DECIMAL(10,2) NULL,
        [costo_real] DECIMAL(10,2) NULL,
        [impacto_operaciones] VARCHAR(20) NULL,
        [recurrencia] BIT NOT NULL DEFAULT 0,
        [incidencia_padre_id] INT NULL,
        [escalado] BIT NOT NULL DEFAULT 0,
        [fecha_escalado] DATETIME2 NULL,
        [nivel_escalado] INT NOT NULL DEFAULT 0,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE();

    -- Crear foreign keys
    ALTER TABLE [dbo].[incidencias]
    ADD CONSTRAINT [FK_incidencias_tipo] FOREIGN KEY ([tipo_incidencia_id]) 
    REFERENCES [dbo].[tipos_incidencia] ([id]);

    ALTER TABLE [dbo].[incidencias]
    ADD CONSTRAINT [FK_incidencias_operario_resolucion] FOREIGN KEY ([operario_resolucion]) 
    REFERENCES [dbo].[usuarios] ([id_usuario]);

    ALTER TABLE [dbo].[incidencias]
    ADD CONSTRAINT [FK_incidencias_supervisor] FOREIGN KEY ([supervisor_aprobacion]) 
    REFERENCES [dbo].[usuarios] ([id_usuario]);

    ALTER TABLE [dbo].[incidencias]
    ADD CONSTRAINT [FK_incidencias_padre] FOREIGN KEY ([incidencia_padre_id]) 
    REFERENCES [dbo].[incidencias] ([id_incidencia]);

    -- Crear índices
    CREATE INDEX [IX_incidencias_tipo] ON [dbo].[incidencias] ([tipo_incidencia_id]);
    CREATE INDEX [IX_incidencias_prioridad] ON [dbo].[incidencias] ([prioridad]);
    CREATE INDEX [IX_incidencias_categoria] ON [dbo].[incidencias] ([categoria]);
    CREATE INDEX [IX_incidencias_operario_resolucion] ON [dbo].[incidencias] ([operario_resolucion]);
    CREATE INDEX [IX_incidencias_fecha_estimada] ON [dbo].[incidencias] ([fecha_estimada_resolucion]);
    CREATE INDEX [IX_incidencias_escalado] ON [dbo].[incidencias] ([escalado]);

    PRINT 'Campos avanzados añadidos a [dbo].[incidencias].';
END
ELSE
BEGIN
    PRINT 'Los campos avanzados ya existen en [dbo].[incidencias].';
END
GO

-- 3. Tabla de seguimiento de incidencias
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'seguimiento_incidencias' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[seguimiento_incidencias] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [incidencia_id] INT NOT NULL,
        [usuario_id] INT NOT NULL,
        [accion] VARCHAR(50) NOT NULL,
        [descripcion] TEXT NOT NULL,
        [estado_anterior] VARCHAR(20) NULL,
        [estado_nuevo] VARCHAR(20) NULL,
        [fecha_seguimiento] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [archivos_adjuntos] TEXT NULL, -- JSON con URLs de archivos
        [tiempo_invertido] INT NULL, -- en minutos
        [observaciones] TEXT NULL,
        
        CONSTRAINT [FK_seguimiento_incidencia] FOREIGN KEY ([incidencia_id]) 
        REFERENCES [dbo].[incidencias] ([id_incidencia]),
        
        CONSTRAINT [FK_seguimiento_usuario] FOREIGN KEY ([usuario_id]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_seguimiento_incidencia] ON [dbo].[seguimiento_incidencias] ([incidencia_id]);
    CREATE INDEX [IX_seguimiento_usuario] ON [dbo].[seguimiento_incidencias] ([usuario_id]);
    CREATE INDEX [IX_seguimiento_fecha] ON [dbo].[seguimiento_incidencias] ([fecha_seguimiento]);

    PRINT 'Tabla [dbo].[seguimiento_incidencias] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[seguimiento_incidencias] ya existe.';
END
GO

-- 4. Tabla de plantillas de resolución
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'plantillas_resolucion' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[plantillas_resolucion] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [tipo_incidencia_id] INT NOT NULL,
        [nombre] VARCHAR(100) NOT NULL,
        [descripcion] TEXT NOT NULL,
        [pasos_resolucion] TEXT NOT NULL, -- JSON con pasos
        [tiempo_estimado] INT NOT NULL, -- en minutos
        [requiere_aprobacion] BIT NOT NULL DEFAULT 0,
        [es_plantilla_default] BIT NOT NULL DEFAULT 0,
        [activo] BIT NOT NULL DEFAULT 1,
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_plantillas_tipo_incidencia] FOREIGN KEY ([tipo_incidencia_id]) 
        REFERENCES [dbo].[tipos_incidencia] ([id])
    );

    -- Insertar plantillas básicas
    INSERT INTO [dbo].[plantillas_resolucion] ([tipo_incidencia_id], [nombre], [descripcion], [pasos_resolucion], [tiempo_estimado], [es_plantilla_default]) VALUES
    (1, 'Resolución Diferencia Inventario', 'Plantilla para resolver diferencias de inventario', 
     '["1. Verificar ubicación física", "2. Recontar productos", "3. Comparar con sistema", "4. Registrar ajuste", "5. Investigar causa"]', 30, 1),
    (2, 'Resolución Producto Dañado', 'Plantilla para manejar productos dañados', 
     '["1. Fotografiar producto", "2. Evaluar daño", "3. Determinar causa", "4. Registrar pérdida", "5. Notificar supervisor"]', 15, 1),
    (3, 'Resolución Ubicación Bloqueada', 'Plantilla para desbloquear ubicaciones', 
     '["1. Evaluar obstáculo", "2. Remover obstáculo", "3. Verificar funcionalidad", "4. Liberar ubicación", "5. Actualizar estado"]', 60, 1);

    PRINT 'Tabla [dbo].[plantillas_resolucion] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[plantillas_resolucion] ya existe.';
END
GO

-- 5. Tabla de métricas de incidencias
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'metricas_incidencias' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[metricas_incidencias] (
        [id] INT IDENTITY(1,1) PRIMARY KEY,
        [fecha] DATE NOT NULL,
        [tipo_incidencia_id] INT NULL,
        [operario_id] INT NULL,
        [total_incidencias] INT NOT NULL DEFAULT 0,
        [incidencias_resueltas] INT NOT NULL DEFAULT 0,
        [incidencias_pendientes] INT NOT NULL DEFAULT 0,
        [incidencias_escaladas] INT NOT NULL DEFAULT 0,
        [tiempo_promedio_resolucion] DECIMAL(10,2) NOT NULL DEFAULT 0, -- en minutos
        [tiempo_total_resolucion] INT NOT NULL DEFAULT 0, -- en minutos
        [costo_total] DECIMAL(10,2) NOT NULL DEFAULT 0,
        [satisfaccion_cliente] DECIMAL(3,2) NULL, -- escala 1-5
        [eficiencia_resolucion] DECIMAL(5,2) NOT NULL DEFAULT 0, -- porcentaje
        [created_at] DATETIME2 DEFAULT GETDATE(),
        [updated_at] DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT [FK_metricas_tipo_incidencia] FOREIGN KEY ([tipo_incidencia_id]) 
        REFERENCES [dbo].[tipos_incidencia] ([id]),
        
        CONSTRAINT [FK_metricas_operario] FOREIGN KEY ([operario_id]) 
        REFERENCES [dbo].[usuarios] ([id_usuario])
    );

    -- Crear índices
    CREATE INDEX [IX_metricas_fecha] ON [dbo].[metricas_incidencias] ([fecha]);
    CREATE INDEX [IX_metricas_tipo] ON [dbo].[metricas_incidencias] ([tipo_incidencia_id]);
    CREATE INDEX [IX_metricas_operario] ON [dbo].[metricas_incidencias] ([operario_id]);

    PRINT 'Tabla [dbo].[metricas_incidencias] creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[metricas_incidencias] ya existe.';
END
GO

PRINT 'Sistema de incidencias avanzado configurado exitosamente.';
