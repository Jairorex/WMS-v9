-- Script para crear la tabla personal_access_tokens en Azure SQL Database
-- Esta tabla es necesaria para Laravel Sanctum

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[personal_access_tokens]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[personal_access_tokens] (
        [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [tokenable_type] NVARCHAR(255) NOT NULL,
        [tokenable_id] BIGINT NOT NULL,
        [name] NVARCHAR(255) NOT NULL,
        [token] NVARCHAR(64) NOT NULL,
        [abilities] NVARCHAR(MAX) NULL,
        [last_used_at] DATETIME2 NULL,
        [expires_at] DATETIME2 NULL,
        [created_at] DATETIME2 NULL,
        [updated_at] DATETIME2 NULL,
        CONSTRAINT [UQ_personal_access_tokens_token] UNIQUE ([token])
    );

    -- Crear índice compuesto para búsquedas rápidas
    CREATE INDEX [IX_personal_access_tokens_tokenable] 
    ON [dbo].[personal_access_tokens] ([tokenable_type], [tokenable_id]);

    -- Crear índice para expires_at
    CREATE INDEX [IX_personal_access_tokens_expires_at] 
    ON [dbo].[personal_access_tokens] ([expires_at]);

    PRINT 'Tabla personal_access_tokens creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla personal_access_tokens ya existe';
END
GO

