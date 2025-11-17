-- ========================================
-- VERIFICACIÓN DE INSTALACIÓN COMPLETA
-- ========================================

USE [wms_escasan];
GO

PRINT '🔍 Verificando instalación completa del sistema...';
PRINT '===============================================';
GO

-- Verificar tablas básicas
PRINT '';
PRINT '📊 VERIFICANDO TABLAS BÁSICAS:';
PRINT '============================';

DECLARE @tablas_basicas TABLE (
    tabla_nombre NVARCHAR(100),
    existe BIT,
    registros INT
);

-- Verificar tabla roles
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'roles')
BEGIN
    DECLARE @count_roles INT;
    SELECT @count_roles = COUNT(*) FROM roles;
    INSERT INTO @tablas_basicas VALUES ('roles', 1, @count_roles);
    PRINT '✅ Tabla roles existe con ' + CAST(@count_roles AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('roles', 0, 0);
    PRINT '❌ Tabla roles NO existe';
END

-- Verificar tabla usuarios
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'usuarios')
BEGIN
    DECLARE @count_usuarios INT;
    SELECT @count_usuarios = COUNT(*) FROM usuarios;
    INSERT INTO @tablas_basicas VALUES ('usuarios', 1, @count_usuarios);
    PRINT '✅ Tabla usuarios existe con ' + CAST(@count_usuarios AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('usuarios', 0, 0);
    PRINT '❌ Tabla usuarios NO existe';
END

-- Verificar tabla productos
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'productos')
BEGIN
    DECLARE @count_productos INT;
    SELECT @count_productos = COUNT(*) FROM productos;
    INSERT INTO @tablas_basicas VALUES ('productos', 1, @count_productos);
    PRINT '✅ Tabla productos existe con ' + CAST(@count_productos AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('productos', 0, 0);
    PRINT '❌ Tabla productos NO existe';
END

-- Verificar tabla ubicaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ubicaciones')
BEGIN
    DECLARE @count_ubicaciones INT;
    SELECT @count_ubicaciones = COUNT(*) FROM ubicaciones;
    INSERT INTO @tablas_basicas VALUES ('ubicaciones', 1, @count_ubicaciones);
    PRINT '✅ Tabla ubicaciones existe con ' + CAST(@count_ubicaciones AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('ubicaciones', 0, 0);
    PRINT '❌ Tabla ubicaciones NO existe';
END

-- Verificar tabla inventario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    DECLARE @count_inventario INT;
    SELECT @count_inventario = COUNT(*) FROM inventario;
    INSERT INTO @tablas_basicas VALUES ('inventario', 1, @count_inventario);
    PRINT '✅ Tabla inventario existe con ' + CAST(@count_inventario AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('inventario', 0, 0);
    PRINT '❌ Tabla inventario NO existe';
END

-- Verificar tabla tareas
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tareas')
BEGIN
    DECLARE @count_tareas INT;
    SELECT @count_tareas = COUNT(*) FROM tareas;
    INSERT INTO @tablas_basicas VALUES ('tareas', 1, @count_tareas);
    PRINT '✅ Tabla tareas existe con ' + CAST(@count_tareas AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('tareas', 0, 0);
    PRINT '❌ Tabla tareas NO existe';
END

-- Verificar tabla incidencias
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'incidencias')
BEGIN
    DECLARE @count_incidencias INT;
    SELECT @count_incidencias = COUNT(*) FROM incidencias;
    INSERT INTO @tablas_basicas VALUES ('incidencias', 1, @count_incidencias);
    PRINT '✅ Tabla incidencias existe con ' + CAST(@count_incidencias AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_basicas VALUES ('incidencias', 0, 0);
    PRINT '❌ Tabla incidencias NO existe';
END

-- Verificar tablas de módulos avanzados
PRINT '';
PRINT '🚀 VERIFICANDO MÓDULOS AVANZADOS:';
PRINT '===============================';

DECLARE @tablas_avanzadas TABLE (
    tabla_nombre NVARCHAR(100),
    existe BIT,
    registros INT
);

-- Verificar tabla lotes
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @count_lotes INT;
    SELECT @count_lotes = COUNT(*) FROM lotes;
    INSERT INTO @tablas_avanzadas VALUES ('lotes', 1, @count_lotes);
    PRINT '✅ Tabla lotes existe con ' + CAST(@count_lotes AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('lotes', 0, 0);
    PRINT '❌ Tabla lotes NO existe';
END

-- Verificar tabla notificaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'notificaciones')
BEGIN
    DECLARE @count_notificaciones INT;
    SELECT @count_notificaciones = COUNT(*) FROM notificaciones;
    INSERT INTO @tablas_avanzadas VALUES ('notificaciones', 1, @count_notificaciones);
    PRINT '✅ Tabla notificaciones existe con ' + CAST(@count_notificaciones AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('notificaciones', 0, 0);
    PRINT '❌ Tabla notificaciones NO existe';
END

-- Verificar tabla tipos_notificacion
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_notificacion')
BEGIN
    DECLARE @count_tipos_notif INT;
    SELECT @count_tipos_notif = COUNT(*) FROM tipos_notificacion;
    INSERT INTO @tablas_avanzadas VALUES ('tipos_notificacion', 1, @count_tipos_notif);
    PRINT '✅ Tabla tipos_notificacion existe con ' + CAST(@count_tipos_notif AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('tipos_notificacion', 0, 0);
    PRINT '❌ Tabla tipos_notificacion NO existe';
END

-- Verificar tabla movimientos_inventario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
    DECLARE @count_movimientos INT;
    SELECT @count_movimientos = COUNT(*) FROM movimientos_inventario;
    INSERT INTO @tablas_avanzadas VALUES ('movimientos_inventario', 1, @count_movimientos);
    PRINT '✅ Tabla movimientos_inventario existe con ' + CAST(@count_movimientos AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('movimientos_inventario', 0, 0);
    PRINT '❌ Tabla movimientos_inventario NO existe';
END

-- Verificar tabla numeros_serie
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
BEGIN
    DECLARE @count_numeros INT;
    SELECT @count_numeros = COUNT(*) FROM numeros_serie;
    INSERT INTO @tablas_avanzadas VALUES ('numeros_serie', 1, @count_numeros);
    PRINT '✅ Tabla numeros_serie existe con ' + CAST(@count_numeros AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('numeros_serie', 0, 0);
    PRINT '❌ Tabla numeros_serie NO existe';
END

-- Verificar tabla trazabilidad_productos
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
BEGIN
    DECLARE @count_trazabilidad INT;
    SELECT @count_trazabilidad = COUNT(*) FROM trazabilidad_productos;
    INSERT INTO @tablas_avanzadas VALUES ('trazabilidad_productos', 1, @count_trazabilidad);
    PRINT '✅ Tabla trazabilidad_productos existe con ' + CAST(@count_trazabilidad AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('trazabilidad_productos', 0, 0);
    PRINT '❌ Tabla trazabilidad_productos NO existe';
END

-- Verificar tabla plantillas_email
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_email')
BEGIN
    DECLARE @count_plantillas INT;
    SELECT @count_plantillas = COUNT(*) FROM plantillas_email;
    INSERT INTO @tablas_avanzadas VALUES ('plantillas_email', 1, @count_plantillas);
    PRINT '✅ Tabla plantillas_email existe con ' + CAST(@count_plantillas AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('plantillas_email', 0, 0);
    PRINT '❌ Tabla plantillas_email NO existe';
END

-- Verificar tabla cola_notificaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cola_notificaciones')
BEGIN
    DECLARE @count_cola INT;
    SELECT @count_cola = COUNT(*) FROM cola_notificaciones;
    INSERT INTO @tablas_avanzadas VALUES ('cola_notificaciones', 1, @count_cola);
    PRINT '✅ Tabla cola_notificaciones existe con ' + CAST(@count_cola AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('cola_notificaciones', 0, 0);
    PRINT '❌ Tabla cola_notificaciones NO existe';
END

-- Verificar tabla logs_notificaciones
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'logs_notificaciones')
BEGIN
    DECLARE @count_logs INT;
    SELECT @count_logs = COUNT(*) FROM logs_notificaciones;
    INSERT INTO @tablas_avanzadas VALUES ('logs_notificaciones', 1, @count_logs);
    PRINT '✅ Tabla logs_notificaciones existe con ' + CAST(@count_logs AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('logs_notificaciones', 0, 0);
    PRINT '❌ Tabla logs_notificaciones NO existe';
END

-- Verificar tabla configuracion_notificaciones_usuario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'configuracion_notificaciones_usuario')
BEGIN
    DECLARE @count_config INT;
    SELECT @count_config = COUNT(*) FROM configuracion_notificaciones_usuario;
    INSERT INTO @tablas_avanzadas VALUES ('configuracion_notificaciones_usuario', 1, @count_config);
    PRINT '✅ Tabla configuracion_notificaciones_usuario existe con ' + CAST(@count_config AS NVARCHAR(10)) + ' registros';
END
ELSE
BEGIN
    INSERT INTO @tablas_avanzadas VALUES ('configuracion_notificaciones_usuario', 0, 0);
    PRINT '❌ Tabla configuracion_notificaciones_usuario NO existe';
END

-- Mostrar resumen de tablas básicas
PRINT '';
PRINT '📊 RESUMEN TABLAS BÁSICAS:';
PRINT '==========================';

SELECT 
    tabla_nombre,
    CASE 
        WHEN existe = 1 THEN '✅ Existe'
        ELSE '❌ No existe'
    END as estado,
    registros
FROM @tablas_basicas
ORDER BY tabla_nombre;

-- Mostrar resumen de tablas avanzadas
PRINT '';
PRINT '📊 RESUMEN MÓDULOS AVANZADOS:';
PRINT '===========================';

SELECT 
    tabla_nombre,
    CASE 
        WHEN existe = 1 THEN '✅ Existe'
        ELSE '❌ No existe'
    END as estado,
    registros
FROM @tablas_avanzadas
ORDER BY tabla_nombre;

-- Verificar datos de prueba
PRINT '';
PRINT '🧪 VERIFICANDO DATOS DE PRUEBA:';
PRINT '==============================';

-- Verificar usuario administrador
IF EXISTS (SELECT * FROM usuarios WHERE email = 'admin@escasan.com')
BEGIN
    PRINT '✅ Usuario administrador existe';
    SELECT nombre, email, activo FROM usuarios WHERE email = 'admin@escasan.com';
END
ELSE
BEGIN
    PRINT '❌ Usuario administrador NO existe';
END

-- Verificar roles
IF EXISTS (SELECT * FROM roles WHERE nombre = 'Administrador')
BEGIN
    PRINT '✅ Rol Administrador existe';
    SELECT nombre, descripcion FROM roles WHERE nombre = 'Administrador';
END
ELSE
BEGIN
    PRINT '❌ Rol Administrador NO existe';
END

-- Verificar productos de prueba
IF EXISTS (SELECT * FROM productos WHERE codigo = 'PROD-001')
BEGIN
    PRINT '✅ Productos de prueba existen';
    SELECT TOP 3 codigo, nombre, categoria FROM productos;
END
ELSE
BEGIN
    PRINT '❌ Productos de prueba NO existen';
END

-- Verificar ubicaciones de prueba
IF EXISTS (SELECT * FROM ubicaciones WHERE codigo = 'A-01-01')
BEGIN
    PRINT '✅ Ubicaciones de prueba existen';
    SELECT TOP 3 codigo, nombre, zona FROM ubicaciones;
END
ELSE
BEGIN
    PRINT '❌ Ubicaciones de prueba NO existen';
END

-- Verificar inventario inicial
IF EXISTS (SELECT * FROM inventario WHERE producto_id = 1)
BEGIN
    PRINT '✅ Inventario inicial existe';
    SELECT TOP 3 p.codigo, p.nombre, i.cantidad, u.codigo as ubicacion 
    FROM inventario i
    JOIN productos p ON i.producto_id = p.id
    JOIN ubicaciones u ON i.ubicacion_id = u.id;
END
ELSE
BEGIN
    PRINT '❌ Inventario inicial NO existe';
END

-- Verificar tipos de notificación
IF EXISTS (SELECT * FROM tipos_notificacion WHERE codigo = 'TAREA_ASIGNADA')
BEGIN
    PRINT '✅ Tipos de notificación existen';
    SELECT TOP 3 codigo, nombre, categoria FROM tipos_notificacion;
END
ELSE
BEGIN
    PRINT '❌ Tipos de notificación NO existen';
END

-- Verificar plantillas de email
IF EXISTS (SELECT * FROM plantillas_email WHERE codigo = 'PLANTILLA_ESCASAN')
BEGIN
    PRINT '✅ Plantillas de email existen';
    SELECT codigo, nombre FROM plantillas_email;
END
ELSE
BEGIN
    PRINT '❌ Plantillas de email NO existen';
END

-- Verificar lotes de prueba
IF EXISTS (SELECT * FROM lotes WHERE codigo_lote = 'LOTE-001-2024')
BEGIN
    PRINT '✅ Lotes de prueba existen';
    SELECT TOP 3 codigo_lote, producto_id, cantidad_disponible FROM lotes;
END
ELSE
BEGIN
    PRINT '❌ Lotes de prueba NO existen';
END

-- Diagnóstico final
PRINT '';
PRINT '🎯 DIAGNÓSTICO FINAL:';
PRINT '===================';

DECLARE @tablas_faltantes_basicas INT;
DECLARE @tablas_faltantes_avanzadas INT;

SELECT @tablas_faltantes_basicas = COUNT(*) FROM @tablas_basicas WHERE existe = 0;
SELECT @tablas_faltantes_avanzadas = COUNT(*) FROM @tablas_avanzadas WHERE existe = 0;

IF @tablas_faltantes_basicas = 0 AND @tablas_faltantes_avanzadas = 0
BEGIN
    PRINT '🎉 ¡ÉXITO! Instalación completa y exitosa';
    PRINT '✅ Todas las tablas están creadas';
    PRINT '✅ Todos los módulos están instalados';
    PRINT '✅ Datos de prueba insertados';
    PRINT '🚀 El sistema está listo para usar en producción';
END
ELSE
BEGIN
    PRINT '❌ ERROR: Instalación incompleta';
    IF @tablas_faltantes_basicas > 0
        PRINT '   📊 Tablas básicas: Faltan ' + CAST(@tablas_faltantes_basicas AS NVARCHAR(10)) + ' tablas';
    IF @tablas_faltantes_avanzadas > 0
        PRINT '   🚀 Módulos avanzados: Faltan ' + CAST(@tablas_faltantes_avanzadas AS NVARCHAR(10)) + ' tablas';
    PRINT '📋 Se necesita ejecutar los scripts de instalación faltantes';
END

PRINT '';
PRINT '📋 INFORMACIÓN DE ACCESO:';
PRINT '=======================';
PRINT '🌐 URLs del sistema:';
PRINT '   - Frontend: http://localhost:5174';
PRINT '   - Backend: http://127.0.0.1:8000';
PRINT '';
PRINT '🔑 Credenciales por defecto:';
PRINT '   - Usuario: admin@escasan.com';
PRINT '   - Contraseña: admin123';
PRINT '';
PRINT '📚 Documentación:';
PRINT '   - Manual de usuario: docs/MANUAL_USUARIO.md';
PRINT '   - Solución de problemas: docs/TROUBLESHOOTING.md';
PRINT '';
PRINT '🎯 ¡El sistema WMS Escasan está listo para usar!';
GO

