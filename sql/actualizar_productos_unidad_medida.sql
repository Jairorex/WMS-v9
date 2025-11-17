-- Script para actualizar tabla productos para usar unidad_de_medida
-- Ejecutar en SQL Server Management Studio DESPUÉS de crear la tabla unidad_de_medida

USE [wms_escasan]
GO

-- Agregar columna unidad_medida_id a tabla productos
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[productos]') AND name = 'unidad_medida_id')
BEGIN
    ALTER TABLE [dbo].[productos] ADD [unidad_medida_id] [int] NULL
END
GO

-- Crear foreign key constraint
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_productos_unidad_de_medida]') AND parent_object_id = OBJECT_ID(N'[dbo].[productos]'))
BEGIN
    ALTER TABLE [dbo].[productos] 
    ADD CONSTRAINT [FK_productos_unidad_de_medida] 
    FOREIGN KEY([unidad_medida_id]) REFERENCES [dbo].[unidad_de_medida] ([id])
END
GO

-- Migrar datos existentes de unidad_medida a unidad_medida_id
-- Mapear valores actuales a los nuevos IDs
UPDATE p 
SET unidad_medida_id = um.id
FROM productos p
INNER JOIN unidad_de_medida um ON 
    CASE p.unidad_medida
        WHEN 'Unidad' THEN 'UN'
        WHEN 'Kg' THEN 'KG'
        WHEN 'Litro' THEN 'LT'
        WHEN 'Caja' THEN 'CJ'
        WHEN 'Otro' THEN 'OT'
        ELSE 'OT'
    END = um.codigo
WHERE p.unidad_medida_id IS NULL
GO

-- Hacer la columna unidad_medida_id NOT NULL después de migrar datos
-- ALTER TABLE [dbo].[productos] ALTER COLUMN [unidad_medida_id] [int] NOT NULL
-- (Comentado por ahora para evitar errores si hay datos NULL)

PRINT 'Columna unidad_medida_id agregada a tabla productos'
PRINT 'Foreign key constraint creada'
PRINT 'Datos migrados de unidad_medida a unidad_medida_id'
