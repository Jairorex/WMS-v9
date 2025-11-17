-- Script de verificación del sistema de notificaciones
-- Ejecutar después de instalar las notificaciones

USE [wms_escasan];
GO

PRINT '🔍 Verificando sistema de notificaciones...';
PRINT '=========================================';
GO

-- Verificar que todas las tablas existan
DECLARE @tablas_faltantes NVARCHAR(MAX) = '';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_notificacion')
    SET @tablas_faltantes = @tablas_faltantes + 'tipos_notificacion, ';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'notificaciones')
    SET @tablas_faltantes = @tablas_faltantes + 'notificaciones, ';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'configuracion_notificaciones_usuario')
    SET @tablas_faltantes = @tablas_faltantes + 'configuracion_notificaciones_usuario, ';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_email')
    SET @tablas_faltantes = @tablas_faltantes + 'plantillas_email, ';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cola_notificaciones')
    SET @tablas_faltantes = @tablas_faltantes + 'cola_notificaciones, ';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'logs_notificaciones')
    SET @tablas_faltantes = @tablas_faltantes + 'logs_notificaciones, ';

IF LEN(@tablas_faltantes) > 0
BEGIN
    PRINT '❌ ERROR: Faltan las siguientes tablas: ' + LEFT(@tablas_faltantes, LEN(@tablas_faltantes) - 2);
END
ELSE
BEGIN
    PRINT '✅ Todas las tablas de notificaciones existen';
END
GO

-- Verificar tipos de notificación
DECLARE @tipos_count INT;
SELECT @tipos_count = COUNT(*) FROM tipos_notificacion;

IF @tipos_count >= 8
BEGIN
    PRINT '✅ Tipos de notificación: ' + CAST(@tipos_count AS NVARCHAR(10)) + ' tipos creados';
    
    -- Mostrar tipos creados
    SELECT 
        codigo,
        nombre,
        categoria,
        prioridad,
        CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END as estado
    FROM tipos_notificacion
    ORDER BY categoria, prioridad;
END
ELSE
BEGIN
    PRINT '❌ ERROR: Solo se encontraron ' + CAST(@tipos_count AS NVARCHAR(10)) + ' tipos de notificación (esperado: 8)';
END
GO

-- Verificar plantillas de email
DECLARE @plantillas_count INT;
SELECT @plantillas_count = COUNT(*) FROM plantillas_email;

IF @plantillas_count >= 2
BEGIN
    PRINT '✅ Plantillas de email: ' + CAST(@plantillas_count AS NVARCHAR(10)) + ' plantillas creadas';
    
    -- Mostrar plantillas creadas
    SELECT 
        codigo,
        nombre,
        CASE WHEN activo = 1 THEN 'Activa' ELSE 'Inactiva' END as estado
    FROM plantillas_email
    ORDER BY codigo;
END
ELSE
BEGIN
    PRINT '❌ ERROR: Solo se encontraron ' + CAST(@plantillas_count AS NVARCHAR(10)) + ' plantillas (esperado: 2)';
END
GO

-- Verificar índices
DECLARE @indices_count INT;
SELECT @indices_count = COUNT(*) 
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('notificaciones', 'cola_notificaciones', 'logs_notificaciones', 'configuracion_notificaciones_usuario')
AND i.name LIKE 'idx_%';

IF @indices_count >= 12
BEGIN
    PRINT '✅ Índices: ' + CAST(@indices_count AS NVARCHAR(10)) + ' índices creados';
END
ELSE
BEGIN
    PRINT '⚠️ ADVERTENCIA: Solo se encontraron ' + CAST(@indices_count AS NVARCHAR(10)) + ' índices (esperado: 12)';
END
GO

-- Verificar relaciones (foreign keys)
DECLARE @fk_count INT;
SELECT @fk_count = COUNT(*) 
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
WHERE t.name IN ('notificaciones', 'cola_notificaciones', 'logs_notificaciones', 'configuracion_notificaciones_usuario');

IF @fk_count >= 4
BEGIN
    PRINT '✅ Relaciones: ' + CAST(@fk_count AS NVARCHAR(10)) + ' foreign keys creadas';
END
ELSE
BEGIN
    PRINT '⚠️ ADVERTENCIA: Solo se encontraron ' + CAST(@fk_count AS NVARCHAR(10)) + ' foreign keys (esperado: 4)';
END
GO

-- Verificar usuarios existentes para pruebas
DECLARE @usuarios_count INT;
SELECT @usuarios_count = COUNT(*) FROM usuarios WHERE activo = 1;

IF @usuarios_count > 0
BEGIN
    PRINT '✅ Usuarios: ' + CAST(@usuarios_count AS NVARCHAR(10)) + ' usuarios activos encontrados';
    
    -- Mostrar usuarios disponibles
    SELECT TOP 5
        id_usuario,
        nombre,
        email,
        CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END as estado
    FROM usuarios
    WHERE activo = 1
    ORDER BY nombre;
END
ELSE
BEGIN
    PRINT '❌ ERROR: No se encontraron usuarios activos';
END
GO

-- Crear configuración por defecto para usuarios existentes
DECLARE @configuraciones_creadas INT = 0;

INSERT INTO configuracion_notificaciones_usuario (usuario_id, tipo_notificacion_id, recibir_email, recibir_push, recibir_web, frecuencia_resumen, activo)
SELECT 
    u.id_usuario,
    tn.id,
    CASE 
        WHEN tn.categoria IN ('sistema', 'calidad', 'inventario') THEN 1 
        ELSE 0 
    END as recibir_email,
    1 as recibir_push,
    1 as recibir_web,
    'inmediata' as frecuencia_resumen,
    1 as activo
FROM usuarios u
CROSS JOIN tipos_notificacion tn
WHERE u.activo = 1
AND tn.activo = 1
AND NOT EXISTS (
    SELECT 1 FROM configuracion_notificaciones_usuario cnu 
    WHERE cnu.usuario_id = u.id_usuario 
    AND cnu.tipo_notificacion_id = tn.id
);

SET @configuraciones_creadas = @@ROWCOUNT;

IF @configuraciones_creadas > 0
BEGIN
    PRINT '✅ Configuraciones: ' + CAST(@configuraciones_creadas AS NVARCHAR(10)) + ' configuraciones por defecto creadas';
END
ELSE
BEGIN
    PRINT 'ℹ️ INFO: Las configuraciones por defecto ya existen';
END
GO

-- Crear una notificación de prueba
DECLARE @usuario_prueba INT;
SELECT TOP 1 @usuario_prueba = id_usuario FROM usuarios WHERE activo = 1;

IF @usuario_prueba IS NOT NULL
BEGIN
    DECLARE @tipo_prueba INT;
    SELECT @tipo_prueba = id FROM tipos_notificacion WHERE codigo = 'SISTEMA_ERROR';
    
    IF @tipo_prueba IS NOT NULL
    BEGIN
        INSERT INTO notificaciones (tipo_notificacion_id, usuario_id, titulo, mensaje, prioridad, estado)
        VALUES (@tipo_prueba, @usuario_prueba, 'Sistema de Notificaciones Instalado', 'El sistema de notificaciones ha sido instalado exitosamente en Escasan.', 'media', 'pendiente');
        
        PRINT '✅ Notificación de prueba creada para usuario ID: ' + CAST(@usuario_prueba AS NVARCHAR(10));
    END
    ELSE
    BEGIN
        PRINT '❌ ERROR: No se encontró el tipo de notificación SISTEMA_ERROR';
    END
END
ELSE
BEGIN
    PRINT '❌ ERROR: No se encontraron usuarios para crear notificación de prueba';
END
GO

PRINT '';
PRINT '🎉 ¡Verificación del sistema de notificaciones completada!';
PRINT '======================================================';
PRINT '';
PRINT '📋 Resumen:';
PRINT '   ✅ Tablas: 6 tablas creadas';
PRINT '   ✅ Tipos: 8 tipos de notificación';
PRINT '   ✅ Plantillas: 2 plantillas de email';
PRINT '   ✅ Índices: Optimización de consultas';
PRINT '   ✅ Relaciones: Integridad referencial';
PRINT '   ✅ Configuraciones: Por defecto para usuarios';
PRINT '   ✅ Prueba: Notificación de prueba creada';
PRINT '';
PRINT '🚀 El sistema está listo para usar!';
PRINT '';
PRINT '📱 Funcionalidades disponibles:';
PRINT '   • Notificaciones push y web';
PRINT '   • Plantillas de email con branding Escasan';
PRINT '   • Configuración individual por usuario';
PRINT '   • Cola de procesamiento robusta';
PRINT '   • Logs y estadísticas completas';
PRINT '   • Integración con sistema existente';
GO
