-- Script para renombrar tablas con prefijo wms_
-- Ejecutar en SQL Server Management Studio

-- Renombrar tablas del esquema wms al esquema dbo con prefijo
EXEC sp_rename 'wms.usuarios', 'wms_usuarios';
ALTER SCHEMA dbo TRANSFER wms.wms_usuarios;

EXEC sp_rename 'wms.roles', 'wms_roles';
ALTER SCHEMA dbo TRANSFER wms.wms_roles;

EXEC sp_rename 'wms.productos', 'wms_productos';
ALTER SCHEMA dbo TRANSFER wms.wms_productos;

EXEC sp_rename 'wms.estados_producto', 'wms_estados_producto';
ALTER SCHEMA dbo TRANSFER wms.wms_estados_producto;

EXEC sp_rename 'wms.ubicaciones', 'wms_ubicaciones';
ALTER SCHEMA dbo TRANSFER wms.wms_ubicaciones;

EXEC sp_rename 'wms.inventario', 'wms_inventario';
ALTER SCHEMA dbo TRANSFER wms.wms_inventario;

EXEC sp_rename 'wms.tipos_tarea', 'wms_tipos_tarea';
ALTER SCHEMA dbo TRANSFER wms.wms_tipos_tarea;

EXEC sp_rename 'wms.estados_tarea', 'wms_estados_tarea';
ALTER SCHEMA dbo TRANSFER wms.wms_estados_tarea;

EXEC sp_rename 'wms.tareas', 'wms_tareas';
ALTER SCHEMA dbo TRANSFER wms.wms_tareas;

EXEC sp_rename 'wms.tarea_detalle', 'wms_tarea_detalle';
ALTER SCHEMA dbo TRANSFER wms.wms_tarea_detalle;

EXEC sp_rename 'wms.tarea_usuario', 'wms_tarea_usuario';
ALTER SCHEMA dbo TRANSFER wms.wms_tarea_usuario;

EXEC sp_rename 'wms.incidencias', 'wms_incidencias';
ALTER SCHEMA dbo TRANSFER wms.wms_incidencias;

EXEC sp_rename 'wms.picking', 'wms_picking';
ALTER SCHEMA dbo TRANSFER wms.wms_picking;

EXEC sp_rename 'wms.picking_det', 'wms_picking_det';
ALTER SCHEMA dbo TRANSFER wms.wms_picking_det;

EXEC sp_rename 'wms.orden_salida', 'wms_orden_salida';
ALTER SCHEMA dbo TRANSFER wms.wms_orden_salida;

EXEC sp_rename 'wms.orden_salida_det', 'wms_orden_salida_det';
ALTER SCHEMA dbo TRANSFER wms.wms_orden_salida_det;

EXEC sp_rename 'wms.notificaciones', 'wms_notificaciones';
ALTER SCHEMA dbo TRANSFER wms.wms_notificaciones;

PRINT 'Todas las tablas han sido renombradas con prefijo wms_ y movidas al esquema dbo';
