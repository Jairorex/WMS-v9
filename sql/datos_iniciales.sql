-- ========================================
-- DATOS INICIALES DEL SISTEMA WMS
-- ========================================

USE [wms_escasan];
GO

PRINT '🚀 Insertando datos iniciales del sistema...';
PRINT '==========================================';
GO

-- 1. Insertar roles
PRINT '';
PRINT '👥 Insertando roles...';

IF NOT EXISTS (SELECT * FROM roles WHERE nombre = 'Administrador')
BEGIN
    INSERT INTO roles (nombre, descripcion, permisos) VALUES
    ('Administrador', 'Acceso completo al sistema', '["*"]'),
    ('Supervisor', 'Supervisión y gestión de operaciones', '["tareas.*", "incidencias.*", "reportes.*"]'),
    ('Operario', 'Ejecución de tareas asignadas', '["tareas.ver", "tareas.completar", "inventario.ver"]'),
    ('Almacenista', 'Gestión de inventario y ubicaciones', '["inventario.*", "ubicaciones.*", "productos.ver"]');
    
    PRINT '✅ Roles insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Roles ya existen';
END
GO

-- 2. Insertar usuarios
PRINT '';
PRINT '👤 Insertando usuarios...';

IF NOT EXISTS (SELECT * FROM usuarios WHERE email = 'admin@escasan.com')
BEGIN
    DECLARE @admin_rol_id INT;
    SELECT @admin_rol_id = id FROM roles WHERE nombre = 'Administrador';
    
    INSERT INTO usuarios (nombre, email, password, rol_id) VALUES
    ('Administrador', 'admin@escasan.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @admin_rol_id),
    ('Juan Pérez', 'juan.perez@escasan.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @admin_rol_id),
    ('María García', 'maria.garcia@escasan.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', @admin_rol_id);
    
    PRINT '✅ Usuarios insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Usuarios ya existen';
END
GO

-- 3. Insertar unidades de medida
PRINT '';
PRINT '📏 Insertando unidades de medida...';

IF NOT EXISTS (SELECT * FROM unidad_de_medida WHERE codigo = 'UN')
BEGIN
    INSERT INTO unidad_de_medida (codigo, nombre, descripcion) VALUES
    ('UN', 'Unidad', 'Unidad individual'),
    ('KG', 'Kilogramo', 'Peso en kilogramos'),
    ('GR', 'Gramo', 'Peso en gramos'),
    ('LT', 'Litro', 'Volumen en litros'),
    ('ML', 'Mililitro', 'Volumen en mililitros'),
    ('M', 'Metro', 'Longitud en metros'),
    ('CM', 'Centímetro', 'Longitud en centímetros'),
    ('CAJ', 'Caja', 'Unidad por caja'),
    ('PAQ', 'Paquete', 'Unidad por paquete'),
    ('ROL', 'Rollo', 'Unidad por rollo');
    
    PRINT '✅ Unidades de medida insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Unidades de medida ya existen';
END
GO

-- 4. Insertar estados de producto
PRINT '';
PRINT '🏷️ Insertando estados de producto...';

IF NOT EXISTS (SELECT * FROM estados_producto WHERE nombre = 'Disponible')
BEGIN
    INSERT INTO estados_producto (nombre, descripcion, color) VALUES
    ('Disponible', 'Producto disponible para uso', '#28a745'),
    ('Reservado', 'Producto reservado para pedido', '#ffc107'),
    ('En Uso', 'Producto actualmente en uso', '#17a2b8'),
    ('Mantenimiento', 'Producto en mantenimiento', '#6c757d'),
    ('Dañado', 'Producto dañado', '#dc3545'),
    ('Obsoleto', 'Producto obsoleto', '#6f42c1');
    
    PRINT '✅ Estados de producto insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Estados de producto ya existen';
END
GO

-- 5. Insertar tipos de tarea
PRINT '';
PRINT '📋 Insertando tipos de tarea...';

IF NOT EXISTS (SELECT * FROM tipos_tarea WHERE nombre = 'Picking')
BEGIN
    INSERT INTO tipos_tarea (nombre, descripcion) VALUES
    ('Picking', 'Recolección de productos para pedidos'),
    ('Reabastecimiento', 'Reabastecimiento de ubicaciones'),
    ('Inventario', 'Conteo y verificación de inventario'),
    ('Mantenimiento', 'Mantenimiento de equipos y ubicaciones'),
    ('Limpieza', 'Limpieza de áreas del almacén'),
    ('Auditoría', 'Auditoría de procesos y procedimientos'),
    ('Capacitación', 'Capacitación de personal'),
    ('Inspección', 'Inspección de productos y áreas');
    
    PRINT '✅ Tipos de tarea insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Tipos de tarea ya existen';
END
GO

-- 6. Insertar ubicaciones
PRINT '';
PRINT '📍 Insertando ubicaciones...';

IF NOT EXISTS (SELECT * FROM ubicaciones WHERE codigo = 'A-01-01')
BEGIN
    INSERT INTO ubicaciones (codigo, nombre, descripcion, zona, capacidad_maxima) VALUES
    ('A-01-01', 'Zona A - Estante 1 - Nivel 1', 'Ubicación principal zona A', 'A', 100.00),
    ('A-01-02', 'Zona A - Estante 1 - Nivel 2', 'Ubicación secundaria zona A', 'A', 100.00),
    ('A-02-01', 'Zona A - Estante 2 - Nivel 1', 'Ubicación principal zona A', 'A', 100.00),
    ('B-01-01', 'Zona B - Estante 1 - Nivel 1', 'Ubicación principal zona B', 'B', 150.00),
    ('B-01-02', 'Zona B - Estante 1 - Nivel 2', 'Ubicación secundaria zona B', 'B', 150.00),
    ('C-01-01', 'Zona C - Estante 1 - Nivel 1', 'Ubicación principal zona C', 'C', 200.00),
    ('RECEPCION', 'Área de Recepción', 'Área para recepción de mercancías', 'RECEPCION', 500.00),
    ('DESPACHO', 'Área de Despacho', 'Área para despacho de pedidos', 'DESPACHO', 300.00),
    ('CALIDAD', 'Área de Control de Calidad', 'Área para inspección de productos', 'CALIDAD', 100.00);
    
    PRINT '✅ Ubicaciones insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Ubicaciones ya existen';
END
GO

-- 7. Insertar productos
PRINT '';
PRINT '📦 Insertando productos...';

IF NOT EXISTS (SELECT * FROM productos WHERE codigo = 'PROD-001')
BEGIN
    INSERT INTO productos (codigo, nombre, descripcion, categoria, precio, unidad_medida, stock_minimo, stock_maximo) VALUES
    ('PROD-001', 'Producto de Prueba 1', 'Producto de prueba para demostración', 'General', 25.50, 'UN', 10.00, 100.00),
    ('PROD-002', 'Producto de Prueba 2', 'Segundo producto de prueba', 'General', 15.75, 'KG', 5.00, 50.00),
    ('PROD-003', 'Producto de Prueba 3', 'Tercer producto de prueba', 'Electrónicos', 150.00, 'UN', 2.00, 20.00),
    ('PROD-004', 'Producto de Prueba 4', 'Cuarto producto de prueba', 'Textiles', 45.25, 'M', 20.00, 200.00),
    ('PROD-005', 'Producto de Prueba 5', 'Quinto producto de prueba', 'Químicos', 75.80, 'LT', 3.00, 30.00);
    
    PRINT '✅ Productos insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Productos ya existen';
END
GO

-- 8. Insertar inventario inicial
PRINT '';
PRINT '📊 Insertando inventario inicial...';

IF NOT EXISTS (SELECT * FROM inventario WHERE producto_id = 1 AND ubicacion_id = 1)
BEGIN
    INSERT INTO inventario (producto_id, ubicacion_id, cantidad, cantidad_reservada) VALUES
    (1, 1, 50.00, 5.00),
    (1, 2, 30.00, 0.00),
    (2, 3, 25.00, 2.00),
    (2, 4, 15.00, 0.00),
    (3, 5, 10.00, 1.00),
    (3, 6, 8.00, 0.00),
    (4, 7, 100.00, 10.00),
    (4, 8, 75.00, 5.00),
    (5, 9, 20.00, 2.00);
    
    PRINT '✅ Inventario inicial insertado';
END
ELSE
BEGIN
    PRINT '⚠️ Inventario inicial ya existe';
END
GO

-- 9. Insertar tareas de ejemplo
PRINT '';
PRINT '📋 Insertando tareas de ejemplo...';

IF NOT EXISTS (SELECT * FROM tareas WHERE titulo = 'Tarea de Prueba 1')
BEGIN
    DECLARE @picking_tipo_id INT;
    DECLARE @admin_user_id INT;
    
    SELECT @picking_tipo_id = id FROM tipos_tarea WHERE nombre = 'Picking';
    SELECT @admin_user_id = id FROM usuarios WHERE email = 'admin@escasan.com';
    
    INSERT INTO tareas (titulo, descripcion, tipo_tarea_id, estado, prioridad, usuario_asignado_id, fecha_vencimiento) VALUES
    ('Tarea de Prueba 1', 'Picking de productos para pedido #001', @picking_tipo_id, 'PENDIENTE', 'ALTA', @admin_user_id, DATEADD(day, 1, GETDATE())),
    ('Tarea de Prueba 2', 'Reabastecimiento de zona A', @picking_tipo_id, 'EN_PROGRESO', 'MEDIA', @admin_user_id, DATEADD(day, 2, GETDATE())),
    ('Tarea de Prueba 3', 'Inventario de productos electrónicos', @picking_tipo_id, 'COMPLETADA', 'BAJA', @admin_user_id, DATEADD(day, -1, GETDATE()));
    
    PRINT '✅ Tareas de ejemplo insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Tareas de ejemplo ya existen';
END
GO

-- 10. Insertar incidencias de ejemplo
PRINT '';
PRINT '⚠️ Insertando incidencias de ejemplo...';

IF NOT EXISTS (SELECT * FROM incidencias WHERE titulo = 'Incidencia de Prueba 1')
BEGIN
    DECLARE @admin_user_id_inc INT;
    SELECT @admin_user_id_inc = id FROM usuarios WHERE email = 'admin@escasan.com';
    
    INSERT INTO incidencias (titulo, descripcion, tipo, estado, prioridad, usuario_reporta_id, usuario_asignado_id) VALUES
    ('Incidencia de Prueba 1', 'Producto dañado en zona A', 'CALIDAD', 'ABIERTA', 'ALTA', @admin_user_id_inc, @admin_user_id_inc),
    ('Incidencia de Prueba 2', 'Equipo de picking fuera de servicio', 'EQUIPO', 'EN_PROGRESO', 'MEDIA', @admin_user_id_inc, @admin_user_id_inc),
    ('Incidencia de Prueba 3', 'Falta de espacio en zona B', 'ESPACIO', 'RESUELTA', 'BAJA', @admin_user_id_inc, @admin_user_id_inc);
    
    PRINT '✅ Incidencias de ejemplo insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Incidencias de ejemplo ya existen';
END
GO

-- Actualizar contraseñas de usuarios (usar admin123)
PRINT '';
PRINT '🔐 Actualizando contraseñas de usuarios...';

UPDATE usuarios 
SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE email IN ('admin@escasan.com', 'juan.perez@escasan.com', 'maria.garcia@escasan.com');

PRINT '✅ Contraseñas actualizadas (admin123 para todos)';

-- Mostrar resumen de datos insertados
PRINT '';
PRINT '📊 RESUMEN DE DATOS INSERTADOS:';
PRINT '==============================';

DECLARE @count_roles INT, @count_usuarios INT, @count_unidades INT, @count_estados INT;
DECLARE @count_tipos INT, @count_ubicaciones INT, @count_productos INT, @count_inventario INT;
DECLARE @count_tareas INT, @count_incidencias INT;

SELECT @count_roles = COUNT(*) FROM roles;
SELECT @count_usuarios = COUNT(*) FROM usuarios;
SELECT @count_unidades = COUNT(*) FROM unidad_de_medida;
SELECT @count_estados = COUNT(*) FROM estados_producto;
SELECT @count_tipos = COUNT(*) FROM tipos_tarea;
SELECT @count_ubicaciones = COUNT(*) FROM ubicaciones;
SELECT @count_productos = COUNT(*) FROM productos;
SELECT @count_inventario = COUNT(*) FROM inventario;
SELECT @count_tareas = COUNT(*) FROM tareas;
SELECT @count_incidencias = COUNT(*) FROM incidencias;

PRINT '👥 Roles: ' + CAST(@count_roles AS NVARCHAR(10));
PRINT '👤 Usuarios: ' + CAST(@count_usuarios AS NVARCHAR(10));
PRINT '📏 Unidades de medida: ' + CAST(@count_unidades AS NVARCHAR(10));
PRINT '🏷️ Estados de producto: ' + CAST(@count_estados AS NVARCHAR(10));
PRINT '📋 Tipos de tarea: ' + CAST(@count_tipos AS NVARCHAR(10));
PRINT '📍 Ubicaciones: ' + CAST(@count_ubicaciones AS NVARCHAR(10));
PRINT '📦 Productos: ' + CAST(@count_productos AS NVARCHAR(10));
PRINT '📊 Registros de inventario: ' + CAST(@count_inventario AS NVARCHAR(10));
PRINT '📋 Tareas: ' + CAST(@count_tareas AS NVARCHAR(10));
PRINT '⚠️ Incidencias: ' + CAST(@count_incidencias AS NVARCHAR(10));

PRINT '';
PRINT '🎉 Datos iniciales insertados exitosamente!';
PRINT '=========================================';
PRINT '';
PRINT '🔑 Credenciales de acceso:';
PRINT '   Usuario: admin@escasan.com';
PRINT '   Contraseña: admin123';
PRINT '';
PRINT '📋 Próximo paso: Ejecutar script de verificación';
GO

