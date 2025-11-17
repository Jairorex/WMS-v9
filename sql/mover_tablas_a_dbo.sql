-- Script para mover todas las tablas del esquema wms al esquema dbo
-- Ejecutar en SQL Server Management Studio

-- 1. Mover tablas principales
ALTER SCHEMA dbo TRANSFER wms.usuarios;
ALTER SCHEMA dbo TRANSFER wms.roles;
ALTER SCHEMA dbo TRANSFER wms.productos;
ALTER SCHEMA dbo TRANSFER wms.estados_producto;
ALTER SCHEMA dbo TRANSFER wms.ubicaciones;
ALTER SCHEMA dbo TRANSFER wms.inventario;
ALTER SCHEMA dbo TRANSFER wms.tipos_tarea;
ALTER SCHEMA dbo TRANSFER wms.estados_tarea;
ALTER SCHEMA dbo TRANSFER wms.tareas;
ALTER SCHEMA dbo TRANSFER wms.tarea_detalle;
ALTER SCHEMA dbo TRANSFER wms.tarea_usuario;
ALTER SCHEMA dbo TRANSFER wms.incidencias;
ALTER SCHEMA dbo TRANSFER wms.picking;
ALTER SCHEMA dbo TRANSFER wms.picking_det;
ALTER SCHEMA dbo TRANSFER wms.orden_salida;
ALTER SCHEMA dbo TRANSFER wms.orden_salida_det;
ALTER SCHEMA dbo TRANSFER wms.notificaciones;

-- 2. Verificar que las tablas se movieron correctamente
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' 
ORDER BY TABLE_NAME;

PRINT 'Todas las tablas han sido movidas al esquema dbo';
