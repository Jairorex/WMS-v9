-- Script para verificar si la tabla personal_access_tokens existe
-- Ejecutar en Azure SQL Database

USE [wms_escasan];
GO

-- Verificar si la tabla existe
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[personal_access_tokens]') AND type in (N'U'))
BEGIN
    PRINT '✅ La tabla personal_access_tokens EXISTE';
    
    -- Mostrar estructura de la tabla
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' 
      AND TABLE_NAME = 'personal_access_tokens'
    ORDER BY ORDINAL_POSITION;
    
    -- Contar registros
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM [dbo].[personal_access_tokens];
    PRINT '📊 Número de tokens: ' + CAST(@count AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '❌ La tabla personal_access_tokens NO EXISTE';
    PRINT '';
    PRINT '🔧 SOLUCIÓN:';
    PRINT 'Ejecuta el script: sql/CREAR_TABLA_PERSONAL_ACCESS_TOKENS.sql';
    PRINT 'O ejecuta este comando:';
    PRINT '';
    PRINT 'CREATE TABLE [dbo].[personal_access_tokens] (';
    PRINT '    [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,';
    PRINT '    [tokenable_type] NVARCHAR(255) NOT NULL,';
    PRINT '    [tokenable_id] BIGINT NOT NULL,';
    PRINT '    [name] NVARCHAR(255) NOT NULL,';
    PRINT '    [token] NVARCHAR(64) NOT NULL,';
    PRINT '    [abilities] NVARCHAR(MAX) NULL,';
    PRINT '    [last_used_at] DATETIME2 NULL,';
    PRINT '    [expires_at] DATETIME2 NULL,';
    PRINT '    [created_at] DATETIME2 NULL,';
    PRINT '    [updated_at] DATETIME2 NULL,';
    PRINT '    CONSTRAINT [UQ_personal_access_tokens_token] UNIQUE ([token])';
    PRINT ');';
END
GO

