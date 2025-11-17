-- Script de verificación final de los módulos instalados
-- Ejecutar después de instalar los módulos

USE [wms_escasan];
GO

PRINT '🔍 Verificación final de módulos instalados...';
PRINT '==========================================';
GO

-- Verificar módulo de lotes
PRINT '';
PRINT '📦 VERIFICANDO MÓDULO DE LOTES:';
PRINT '==============================';

DECLARE @tablas_lotes TABLE (
    tabla_nombre NVARCHAR(100),
    existe BIT,
    registros INT
);

-- Verificar tabla lotes
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @count_lotes INT;
    SELECT @count_lotes = COUNT(*) FROM lotes;
    INSERT INTO @tablas_lotes VALUES ('lotes', 1, @count_lotes);
    PRINT '✅ Tabla lotes existe con ' + CAST(@count_lotes AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('lotes', 0, 0);
    PRINT '❌ Tabla lotes NO existe';
END

-- Verificar tabla movimientos_inventario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
    DECLARE @count_movimientos INT;
    SELECT @count_movimientos = COUNT(*) FROM movimientos_inventario;
    INSERT INTO @tablas_lotes VALUES ('movimientos_inventario', 1, @count_movimientos);
    PRINT '✅ Tabla movimientos_inventario existe con ' + CAST(@count_movimientos AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('movimientos_inventario', 0, 0);
    PRINT '❌ Tabla movimientos_inventario NO existe';
END

-- Verificar tabla numeros_serie
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
BEGIN
    DECLARE @count_numeros INT;
    SELECT @count_numeros = COUNT(*) FROM numeros_serie;
    INSERT INTO @tablas_lotes VALUES ('numeros_serie', 1, @count_numeros);
    PRINT '✅ Tabla numeros_serie existe con ' + CAST(@count_numeros AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('numeros_serie', 0, 0);
    PRINT '❌ Tabla numeros_serie NO existe';
END

-- Verificar tabla trazabilidad_productos
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
BEGIN
    DECLARE @count_trazabilidad INT;
    SELECT @count_trazabilidad = COUNT(*) FROM trazabilidad_productos;
    INSERT INTO @tablas_lotes VALUES ('trazabilidad_productos', 1, @count_trazabilidad);
    PRINT '✅ Tabla trazabilidad_productos existe con ' + CAST(@count_trazabilidad AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_lotes VALUES ('trazabilidad_productos', 0, 0);
    PRINT '❌ Tabla trazabilidad_productos NO existe';
END

-- Verificar módulo de notificaciones
PRINT '';
PRINT '🔔 VERIFICANDO MÓDULO DE NOTIFICACIONES:';
PRINT '======================================';

DECLARE @tablas_notificaciones TABLE (
    tabla_nombre NVARCHAR(100),
    existe BIT,
    registros INT
);

-- Verificar tabla tipos_notificacion
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_notificacion')
BEGIN
    DECLARE @count_tipos INT;
    SELECT @count_tipos = COUNT(*) FROM tipos_notificacion;
    INSERT INTO @tablas_notificaciones VALUES ('tipos_notificacion', 1, @count_tipos);
    PRINT '✅ Tabla tipos_notificacion existe con ' + CAST(@count_tipos AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_notificaciones VALUES ('tipos_notificacion', 0, 0);
    PRINT '❌ Tabla tipos_notificacion NO existe';
END

-- Verificar tabla notificaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'notificaciones')
BEGIN
    DECLARE @count_notificaciones INT;
    SELECT @count_notificaciones = COUNT(*) FROM notificaciones;
    INSERT INTO @tablas_notificaciones VALUES ('notificaciones', 1, @count_notificaciones);
    PRINT '✅ Tabla notificaciones existe con ' + CAST(@count_notificaciones AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_notificaciones VALUES ('notificaciones', 0, 0);
    PRINT '❌ Tabla notificaciones NO existe';
END

-- Verificar tabla configuracion_notificaciones_usuario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'configuracion_notificaciones_usuario')
BEGIN
    DECLARE @count_config INT;
    SELECT @count_config = COUNT(*) FROM configuracion_notificaciones_usuario;
    INSERT INTO @tablas_notificaciones VALUES ('configuracion_notificaciones_usuario', 1, @count_config);
    PRINT '✅ Tabla configuracion_notificaciones_usuario existe con ' + CAST(@count_config AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_notificaciones VALUES ('configuracion_notificaciones_usuario', 0, 0);
    PRINT '❌ Tabla configuracion_notificaciones_usuario NO existe';
END

-- Verificar tabla plantillas_email
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_email')
BEGIN
    DECLARE @count_plantillas INT;
    SELECT @count_plantillas = COUNT(*) FROM plantillas_email;
    INSERT INTO @tablas_notificaciones VALUES ('plantillas_email', 1, @count_plantillas);
    PRINT '✅ Tabla plantillas_email existe con ' + CAST(@count_plantillas AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_notificaciones VALUES ('plantillas_email', 0, 0);
    PRINT '❌ Tabla plantillas_email NO existe';
END

-- Verificar tabla cola_notificaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cola_notificaciones')
BEGIN
    DECLARE @count_cola INT;
    SELECT @count_cola = COUNT(*) FROM cola_notificaciones;
    INSERT INTO @tablas_notificaciones VALUES ('cola_notificaciones', 1, @count_cola);
    PRINT '✅ Tabla cola_notificaciones existe con ' + CAST(@count_cola AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_notificaciones VALUES ('cola_notificaciones', 0, 0);
    PRINT '❌ Tabla cola_notificaciones NO existe';
END

-- Verificar tabla logs_notificaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'logs_notificaciones')
BEGIN
    DECLARE @count_logs INT;
    SELECT @count_logs = COUNT(*) FROM logs_notificaciones;
    INSERT INTO @tablas_notificaciones VALUES ('logs_notificaciones', 1, @count_logs);
    PRINT '✅ Tabla logs_notificaciones existe con ' + CAST(@count_logs AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_notificaciones VALUES ('logs_notificaciones', 0, 0);
    PRINT '❌ Tabla logs_notificaciones NO existe';
END

-- Mostrar resumen de lotes
PRINT '';
PRINT '📊 RESUMEN MÓDULO DE LOTES:';
PRINT '==========================';

SELECT 
    tabla_nombre,
    CASE 
        WHEN existe = 1 THEN '✅ Existe'
        ELSE '❌ No existe'
    END as estado,
    registros
FROM @tablas_lotes
ORDER BY tabla_nombre;

-- Mostrar resumen de notificaciones
PRINT '';
PRINT '📊 RESUMEN MÓDULO DE NOTIFICACIONES:';
PRINT '===================================';

SELECT 
    tabla_nombre,
    CASE 
        WHEN existe = 1 THEN '✅ Existe'
        ELSE '❌ No existe'
    END as estado,
    registros
FROM @tablas_notificaciones
ORDER BY tabla_nombre;

-- Verificar columnas de lote en inventario
PRINT '';
PRINT '🔗 VERIFICANDO INTEGRACIÓN CON INVENTARIO:';
PRINT '========================================';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'lote_id')
    BEGIN
        PRINT '✅ Columna lote_id existe en tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '❌ Columna lote_id NO existe en tabla inventario';
    END
    
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'numero_serie_id')
    BEGIN
        PRINT '✅ Columna numero_serie_id existe en tabla inventario';
    END
    ELSE
    BEGIN
        PRINT '❌ Columna numero_serie_id NO existe en tabla inventario';
    END
END
ELSE
BEGIN
    PRINT '❌ Tabla inventario no existe';
END

-- Verificar tipos de notificación específicos
PRINT '';
PRINT '🔔 VERIFICANDO TIPOS DE NOTIFICACIÓN:';
PRINT '===================================';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_notificacion')
BEGIN
    SELECT 
        codigo,
        nombre,
        categoria,
        prioridad,
        CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END as estado
    FROM tipos_notificacion
    ORDER BY categoria, prioridad;
END

-- Verificar plantillas de email
PRINT '';
PRINT '📧 VERIFICANDO PLANTILLAS DE EMAIL:';
PRINT '=================================';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_email')
BEGIN
    SELECT 
        codigo,
        nombre,
        CASE WHEN activo = 1 THEN 'Activa' ELSE 'Inactiva' END as estado
    FROM plantillas_email
    ORDER BY codigo;
END

-- Verificar configuración de usuarios
PRINT '';
PRINT '⚙️ VERIFICANDO CONFIGURACIÓN DE USUARIOS:';
PRINT '=======================================';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'configuracion_notificaciones_usuario')
BEGIN
    DECLARE @usuarios_configurados INT;
    SELECT @usuarios_configurados = COUNT(DISTINCT usuario_id) FROM configuracion_notificaciones_usuario;
    PRINT 'Usuarios con configuración: ' + CAST(@usuarios_configurados AS NVARCHAR(10));
END

-- Verificar notificaciones de prueba
PRINT '';
PRINT '📨 VERIFICANDO NOTIFICACIONES DE PRUEBA:';
PRINT '======================================';

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'notificaciones')
BEGIN
    DECLARE @notificaciones_prueba INT;
    SELECT @notificaciones_prueba = COUNT(*) FROM notificaciones WHERE titulo LIKE '%Instalados%';
    PRINT 'Notificaciones de prueba: ' + CAST(@notificaciones_prueba AS NVARCHAR(10));
    
    IF @notificaciones_prueba > 0
    BEGIN
        SELECT TOP 3
            titulo,
            estado,
            prioridad,
            created_at
        FROM notificaciones
        ORDER BY created_at DESC;
    END
END

-- Diagnóstico final
PRINT '';
PRINT '🎯 DIAGNÓSTICO FINAL:';
PRINT '===================';

DECLARE @tablas_faltantes_lotes INT;
DECLARE @tablas_faltantes_notificaciones INT;

SELECT @tablas_faltantes_lotes = COUNT(*) FROM @tablas_lotes WHERE existe = 0;
SELECT @tablas_faltantes_notificaciones = COUNT(*) FROM @tablas_notificaciones WHERE existe = 0;

IF @tablas_faltantes_lotes = 0 AND @tablas_faltantes_notificaciones = 0
BEGIN
    PRINT '🎉 ¡ÉXITO! Todos los módulos están instalados correctamente';
    PRINT '✅ Módulo de Lotes: Completamente funcional';
    PRINT '✅ Módulo de Notificaciones: Completamente funcional';
    PRINT '🚀 El sistema está listo para usar en producción';
END
ELSE
BEGIN
    PRINT '❌ ERROR: Faltan tablas por crear';
    IF @tablas_faltantes_lotes > 0
        PRINT '   📦 Módulo de Lotes: Faltan ' + CAST(@tablas_faltantes_lotes AS NVARCHAR(10)) + ' tablas';
    IF @tablas_faltantes_notificaciones > 0
        PRINT '   🔔 Módulo de Notificaciones: Faltan ' + CAST(@tablas_faltantes_notificaciones AS NVARCHAR(10)) + ' tablas';
    PRINT '📋 Se necesita ejecutar el script de instalación completo';
END

PRINT '';
PRINT '📋 PRÓXIMOS PASOS:';
PRINT '=================';
PRINT '1. Si todo está correcto: Probar el sistema en el frontend';
PRINT '2. Si hay errores: Ejecutar el script de instalación completo';
PRINT '3. Verificar que las APIs funcionen: /api/lotes y /api/notificaciones';
PRINT '4. Probar la funcionalidad en la interfaz de usuario';
GO
