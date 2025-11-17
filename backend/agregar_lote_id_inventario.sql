-- Script para agregar columnas lote_id y numero_serie_id a la tabla inventario
-- Ejecutar en SQL Server Management Studio

USE wms;
GO

PRINT 'Agregando columnas lote_id y numero_serie_id a tabla inventario...';
PRINT '========================================';

-- Verificar si la tabla existe
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'inventario')
BEGIN
    -- Agregar columna lote_id si no existe
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = 'dbo' 
                   AND TABLE_NAME = 'inventario' 
                   AND COLUMN_NAME = 'lote_id')
    BEGIN
        ALTER TABLE dbo.inventario 
        ADD lote_id INT NULL;
        
        -- Verificar si la tabla lotes existe antes de crear la FK
        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'lotes')
        BEGIN
            ALTER TABLE dbo.inventario 
            ADD CONSTRAINT FK_inventario_lote 
            FOREIGN KEY (lote_id) REFERENCES dbo.lotes (id);
            
            CREATE INDEX IX_inventario_lote ON dbo.inventario (lote_id);
        END
        
        PRINT '✅ Columna lote_id agregada a tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Columna lote_id ya existe en tabla inventario';
    END
    
    -- Agregar columna numero_serie_id si no existe
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = 'dbo' 
                   AND TABLE_NAME = 'inventario' 
                   AND COLUMN_NAME = 'numero_serie_id')
    BEGIN
        ALTER TABLE dbo.inventario 
        ADD numero_serie_id INT NULL;
        
        -- Verificar si la tabla numeros_serie existe antes de crear la FK
        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'numeros_serie')
        BEGIN
            ALTER TABLE dbo.inventario 
            ADD CONSTRAINT FK_inventario_numero_serie 
            FOREIGN KEY (numero_serie_id) REFERENCES dbo.numeros_serie (id);
            
            CREATE INDEX IX_inventario_numero_serie ON dbo.inventario (numero_serie_id);
        END
        
        PRINT '✅ Columna numero_serie_id agregada a tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Columna numero_serie_id ya existe en tabla inventario';
    END
END
ELSE
BEGIN
    PRINT '❌ Tabla inventario no existe';
END

GO

PRINT '';
PRINT '✅ Script completado';
GO

