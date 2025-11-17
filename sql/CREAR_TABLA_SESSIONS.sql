-- Script para crear la tabla de sesiones en SQL Server
-- Ejecutar este script en Azure SQL Database si la tabla sessions no existe
-- IMPORTANTE: Usa el esquema [dbo] explícitamente

USE [wms_escasan];
GO

-- Verificar si la tabla existe en el esquema dbo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sessions]') 
    AND type in (N'U')
)
BEGIN
    -- Crear la tabla sessions en el esquema dbo
    CREATE TABLE [dbo].[sessions] (
        [id] NVARCHAR(255) NOT NULL,
        [user_id] BIGINT NULL,
        [ip_address] NVARCHAR(45) NULL,
        [user_agent] NVARCHAR(MAX) NULL,
        [payload] NVARCHAR(MAX) NOT NULL,
        [last_activity] INT NOT NULL,
        CONSTRAINT [PK_sessions] PRIMARY KEY CLUSTERED ([id] ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 
                  IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, 
                  ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY];
    
    -- Crear índices para mejorar el rendimiento
    CREATE NONCLUSTERED INDEX [sessions_user_id_index] 
    ON [dbo].[sessions] ([user_id] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 
          SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, 
          ONLINE = OFF, ALLOW_ROW_LOCKS = ON, 
          ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
    
    CREATE NONCLUSTERED INDEX [sessions_last_activity_index] 
    ON [dbo].[sessions] ([last_activity] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 
          SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, 
          ONLINE = OFF, ALLOW_ROW_LOCKS = ON, 
          ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
    
    PRINT 'Tabla [dbo].[sessions] creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla [dbo].[sessions] ya existe';
    
    -- Verificar que tenga todas las columnas necesarias
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID(N'[dbo].[sessions]') 
        AND name = 'id'
    )
    BEGIN
        PRINT 'ERROR: La tabla existe pero no tiene la estructura correcta';
    END
    ELSE
    BEGIN
        PRINT 'La tabla [dbo].[sessions] tiene la estructura correcta';
    END
END
GO

-- Verificar la estructura de la tabla
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME = 'sessions'
ORDER BY ORDINAL_POSITION;
GO

