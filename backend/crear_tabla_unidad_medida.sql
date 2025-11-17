-- Script para crear tabla unidad_de_medida
-- Ejecutar en SQL Server Management Studio

USE [wms_escasan]
GO

-- Crear tabla unidad_de_medida
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[unidad_de_medida]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[unidad_de_medida](
        [id] [int] IDENTITY(1,1) NOT NULL,
        [codigo] [nvarchar](10) NOT NULL,
        [nombre] [nvarchar](50) NOT NULL,
        [activo] [bit] NOT NULL DEFAULT(1),
        [created_at] [datetime2](7) NOT NULL DEFAULT(GETDATE()),
        [updated_at] [datetime2](7) NOT NULL DEFAULT(GETDATE()),
        CONSTRAINT [PK_unidad_de_medida] PRIMARY KEY CLUSTERED ([id] ASC)
    )
END
GO

-- Crear índice único para código
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[unidad_de_medida]') AND name = N'IX_unidad_de_medida_codigo')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [IX_unidad_de_medida_codigo] ON [dbo].[unidad_de_medida]
    (
        [codigo] ASC
    )
END
GO

-- Insertar datos iniciales
IF NOT EXISTS (SELECT * FROM [dbo].[unidad_de_medida] WHERE codigo = 'UN')
BEGIN
    INSERT INTO [dbo].[unidad_de_medida] ([codigo], [nombre]) VALUES ('UN', 'Unidad')
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[unidad_de_medida] WHERE codigo = 'KG')
BEGIN
    INSERT INTO [dbo].[unidad_de_medida] ([codigo], [nombre]) VALUES ('KG', 'Kilogramo')
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[unidad_de_medida] WHERE codigo = 'LT')
BEGIN
    INSERT INTO [dbo].[unidad_de_medida] ([codigo], [nombre]) VALUES ('LT', 'Litro')
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[unidad_de_medida] WHERE codigo = 'CJ')
BEGIN
    INSERT INTO [dbo].[unidad_de_medida] ([codigo], [nombre]) VALUES ('CJ', 'Caja')
END
GO

IF NOT EXISTS (SELECT * FROM [dbo].[unidad_de_medida] WHERE codigo = 'OT')
BEGIN
    INSERT INTO [dbo].[unidad_de_medida] ([codigo], [nombre]) VALUES ('OT', 'Otro')
END
GO

-- Agregar columna fecha_vencimiento a tabla tareas
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tareas]') AND name = 'fecha_vencimiento')
BEGIN
    ALTER TABLE [dbo].[tareas] ADD [fecha_vencimiento] [datetime2](7) NULL
END
GO

PRINT 'Tabla unidad_de_medida creada y datos iniciales insertados'
PRINT 'Columna fecha_vencimiento agregada a tabla tareas'
