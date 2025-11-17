-- Script para verificar tablas existentes antes de las migraciones
USE [wms_escasan];
GO

PRINT '🔍 Verificando tablas existentes antes de las migraciones...';
GO

-- Verificar tablas del sistema básico
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN (
    'productos',
    'ubicaciones',
    'inventario',
    'usuarios',
    'roles',
    'tareas',
    'incidencias',
    'tipos_tarea',
    'estados_producto',
    'unidad_de_medida'
)
ORDER BY TABLE_NAME;
GO

-- Verificar tablas del sistema avanzado (deberían NO existir)
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN (
    'tipos_ubicacion',
    'zonas_almacen',
    'lotes',
    'movimientos_inventario',
    'numeros_serie',
    'trazabilidad_productos',
    'oleadas_picking',
    'pedidos_picking',
    'pedidos_picking_detalle',
    'rutas_picking',
    'estadisticas_picking',
    'tipos_incidencia',
    'seguimiento_incidencias',
    'plantillas_resolucion',
    'metricas_incidencias'
)
ORDER BY TABLE_NAME;
GO

PRINT '📋 Resumen:';
PRINT '   - Tablas del sistema básico: Deben existir';
PRINT '   - Tablas del sistema avanzado: NO deben existir (se crearán con las migraciones)';
GO
