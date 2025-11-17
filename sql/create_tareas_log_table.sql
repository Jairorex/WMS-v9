-- Script SQL para crear tabla de logs de tareas
-- Ejecutar este script en SQL Server si la tabla no existe

USE wms;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'tareas_log')
BEGIN
    CREATE TABLE dbo.tareas_log (
        id_log BIGINT IDENTITY(1,1) PRIMARY KEY,
        id_tarea INT NOT NULL,
        usuario_id INT NULL,
        estado_anterior NVARCHAR(50) NULL,
        estado_nuevo NVARCHAR(50) NULL,
        accion NVARCHAR(100) NULL,
        dispositivo NVARCHAR(500) NULL,
        ip_address NVARCHAR(50) NULL,
        comentarios NVARCHAR(MAX) NULL,
        created_at DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_tareas_log_tarea FOREIGN KEY (id_tarea) REFERENCES dbo.tareas(id_tarea) ON DELETE CASCADE,
        CONSTRAINT FK_tareas_log_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id_usuario) ON DELETE SET NULL
    );
    
    -- Índices para mejorar consultas
    CREATE INDEX IX_tareas_log_id_tarea ON dbo.tareas_log(id_tarea);
    CREATE INDEX IX_tareas_log_usuario_id ON dbo.tareas_log(usuario_id);
    CREATE INDEX IX_tareas_log_created_at ON dbo.tareas_log(created_at);
    CREATE INDEX IX_tareas_log_estado_nuevo ON dbo.tareas_log(estado_nuevo);
    
    PRINT '✅ Tabla tareas_log creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tareas_log ya existe';
END
GO

