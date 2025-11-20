# 🔍 Diferencias entre Base de Datos Local y Azure

## 📊 Resumen Ejecutivo

Este documento detalla las diferencias entre la base de datos local (localhost) y la base de datos en Azure SQL Database para el sistema WMS Escasan.

---

## 🗄️ Estructura General

### Base de Datos Local (localhost)
- **Esquema principal**: `wms`
- **Tablas estimadas**: 30+ tablas
- **Estado**: Completa con módulos avanzados

### Base de Datos Azure
- **Esquema principal**: `wms`
- **Tablas según script**: 18 tablas básicas + 4 tablas Laravel = 22 tablas
- **Estado**: Estructura básica implementada

---

## 📋 Tablas por Categoría

### ✅ Tablas que EXISTEN en AMBAS bases

#### Gestión de Usuarios y Seguridad
1. `wms.roles` - Roles de usuario
2. `wms.usuarios` - Usuarios del sistema
3. `dbo.personal_access_tokens` - Tokens de autenticación (Laravel Sanctum)
4. `dbo.sessions` - Sesiones (Laravel)
5. `dbo.migrations` - Migraciones (Laravel)
6. `dbo.password_reset_tokens` - Reset de contraseñas (Laravel)

#### Catálogos Base
7. `wms.estados_producto` - Estados de productos
8. `wms.productos` - Catálogo de productos
9. `wms.ubicaciones` - Ubicaciones físicas
10. `wms.inventario` - Stock por producto y ubicación

#### Sistema de Tareas
11. `wms.tipos_tarea` - Tipos de tareas
12. `wms.estados_tarea` - Estados de tareas
13. `wms.tareas` - Tareas del sistema
14. `wms.tarea_usuario` - Asignación de tareas a usuarios
15. `wms.tarea_detalle` - Detalles de productos en tareas

#### Operaciones
16. `wms.incidencias` - Sistema de incidencias
17. `wms.notificaciones` - Sistema de notificaciones
18. `wms.picking` - Órdenes de picking
19. `wms.picking_det` - Detalles de picking
20. `wms.orden_salida` - Órdenes de salida
21. `wms.orden_salida_det` - Detalles de órdenes de salida

#### Historial
22. `wms.tareas_log` - Historial de cambios en tareas (✅ Existe en Azure según script)

---

## ❌ Tablas que FALTAN en Azure (pero existen en Local)

### Módulo de Lotes y Trazabilidad
1. **`wms.lotes`** - Gestión de lotes con fechas de caducidad
   - Campos: `id`, `codigo_lote`, `producto_id`, `cantidad_inicial`, `cantidad_disponible`, `fecha_fabricacion`, `fecha_caducidad`, `fecha_vencimiento`, `proveedor`, `numero_serie`, `estado`, `observaciones`, `activo`, `created_at`, `updated_at`
   - **Script para crear**: `sql/crear_tablas_lotes_movimientos_historial.sql`

2. **`wms.movimientos_inventario`** - Historial de movimientos de inventario
   - Campos: `id`, `lote_id`, `producto_id`, `ubicacion_id`, `tipo_movimiento`, `cantidad`, `cantidad_anterior`, `cantidad_nueva`, `motivo`, `referencia`, `usuario_id`, `fecha_movimiento`, `observaciones`
   - **Script para crear**: `sql/crear_tablas_lotes_movimientos_historial.sql`

3. **`wms.numeros_serie`** - Números de serie para productos específicos
   - Probablemente existe en local pero no en Azure

4. **`wms.trazabilidad_productos`** - Trazabilidad completa de productos
   - Probablemente existe en local pero no en Azure

### Módulo de Unidades de Medida
5. **`wms.unidad_de_medida`** - Catálogo de unidades de medida
   - Campo `unidad_medida_id` en `wms.productos` hace referencia a esta tabla
   - **Script para crear**: `sql/crear_tabla_unidad_medida.sql`

### Módulo de Picking Inteligente
6. **`wms.oleadas_picking`** - Oleadas de picking
7. **`wms.pedidos_picking`** - Pedidos agrupados
8. **`wms.pedidos_picking_detalle`** - Detalles de pedidos
9. **`wms.rutas_picking`** - Rutas optimizadas
10. **`wms.estadisticas_picking`** - Estadísticas de rendimiento
   - **Script para crear**: `sql/crear_sistema_picking_inteligente.sql`

### Módulo de Incidencias Avanzado
11. **`wms.tipos_incidencia`** - Tipos de incidencia categorizados
12. **`wms.seguimiento_incidencias`** - Seguimiento de resolución
13. **`wms.plantillas_resolucion`** - Plantillas de resolución automática
14. **`wms.metricas_incidencias`** - Métricas y KPIs de incidencias
   - **Script para crear**: `sql/crear_sistema_incidencias_avanzado.sql`

### Módulo de Ubicaciones Avanzado
15. **`wms.tipos_ubicacion`** - Tipos de ubicación
16. **`wms.zonas_almacen`** - Zonas con capacidades y condiciones ambientales

### Módulo de Dashboard y KPIs
17. **`wms.kpi_sistema`** - KPIs del sistema
18. **`wms.kpi_historico`** - Historial de KPIs
19. **`wms.metricas_tiempo_real`** - Métricas en tiempo real
20. **`wms.widgets_dashboard`** - Widgets personalizables
21. **`wms.alertas_dashboard`** - Alertas del sistema
   - **Script para crear**: `sql/crear_dashboard_tiempo_real.sql`

### Módulo de Notificaciones Avanzado
22. **`wms.tipos_notificacion`** - Tipos de notificaciones
23. **`wms.cola_notificaciones`** - Cola de envío
24. **`wms.log_notificaciones`** - Log de notificaciones enviadas
25. **`wms.configuracion_notificacion_usuario`** - Configuración por usuario
   - **Script para crear**: `sql/crear_sistema_notificaciones.sql` o `sql/instalar_notificaciones_escasan.sql`

### Módulo de Reportes
26. **`wms.reportes_avanzados`** - Sistema de reportes (si existe)
   - **Script para crear**: `sql/crear_sistema_reportes_avanzados.sql`

---

## 🔍 Diferencias en Columnas

### Tabla `wms.productos`

#### Local (completo):
- `id_producto`
- `nombre`
- `descripcion`
- `codigo_barra`
- `lote`
- `estado_producto_id`
- `fecha_caducidad`
- `unidad_medida` (NVARCHAR)
- **`unidad_medida_id`** (INT) - ⚠️ **FALTA en Azure**
- `stock_minimo`
- `precio`
- `created_at`
- `updated_at`

#### Azure (según script):
- `id_producto`
- `nombre`
- `descripcion`
- `codigo_barra`
- `lote`
- `estado_producto_id`
- `fecha_caducidad`
- `unidad_medida` (NVARCHAR)
- `stock_minimo`
- `precio`
- `created_at`
- `updated_at`

**Diferencia**: Azure no tiene la columna `unidad_medida_id` que referencia a `wms.unidad_de_medida`.

---

## 📊 Resumen de Diferencias

| Categoría | Local | Azure | Diferencia |
|-----------|-------|-------|------------|
| **Tablas básicas** | ✅ | ✅ | 0 |
| **Tablas de lotes** | ✅ | ❌ | 2-4 tablas faltantes |
| **Tablas de picking inteligente** | ✅ | ❌ | 5 tablas faltantes |
| **Tablas de incidencias avanzado** | ✅ | ❌ | 4 tablas faltantes |
| **Tablas de dashboard/KPIs** | ✅ | ❌ | 5 tablas faltantes |
| **Tablas de notificaciones avanzado** | ✅ | ❌ | 4 tablas faltantes |
| **Tablas de ubicaciones avanzado** | ✅ | ❌ | 2 tablas faltantes |
| **Unidad de medida** | ✅ | ❌ | 1 tabla faltante |
| **TOTAL ESTIMADO** | **30+ tablas** | **22 tablas** | **~23 tablas faltantes** |

---

## 🚀 Scripts para Sincronizar Azure

Para sincronizar Azure con la base local, ejecuta los siguientes scripts en orden:

### 1. Módulo de Lotes y Movimientos
```sql
-- Ejecutar en Azure
sql/crear_tablas_lotes_movimientos_historial.sql
```

### 2. Unidad de Medida
```sql
-- Ejecutar en Azure
sql/crear_tabla_unidad_medida.sql
sql/actualizar_productos_unidad_medida.sql
```

### 3. Picking Inteligente
```sql
-- Ejecutar en Azure
sql/crear_sistema_picking_inteligente.sql
```

### 4. Incidencias Avanzado
```sql
-- Ejecutar en Azure
sql/crear_sistema_incidencias_avanzado.sql
```

### 5. Dashboard y KPIs
```sql
-- Ejecutar en Azure
sql/crear_dashboard_tiempo_real.sql
```

### 6. Notificaciones Avanzado
```sql
-- Ejecutar en Azure
sql/crear_sistema_notificaciones.sql
-- O
sql/instalar_notificaciones_escasan.sql
```

### 7. Ubicaciones Avanzado
```sql
-- Revisar si existe script específico
-- O crear manualmente basándose en los modelos
```

---

## 🔧 Cómo Comparar las Bases

### Opción 1: Script PHP (Recomendado)
```bash
cd backend
php comparar_bases_datos.php
```

**Requisitos**:
- Configurar variables de entorno en `.env`:
  ```
  AZURE_DB_HOST=tu-servidor-azure.database.windows.net
  AZURE_DB_DATABASE=wms_escasan
  AZURE_DB_USERNAME=tu_usuario
  AZURE_DB_PASSWORD=tu_contraseña
  ```

### Opción 2: Script SQL Manual
Ejecuta estas consultas en ambas bases y compara:

```sql
-- Listar todas las tablas
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'wms'
ORDER BY TABLE_NAME;

-- Listar columnas de una tabla específica
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'productos'
ORDER BY ORDINAL_POSITION;
```

---

## ⚠️ Consideraciones Importantes

1. **Datos Existentes**: Antes de ejecutar scripts de sincronización, asegúrate de:
   - Hacer backup de la base de datos Azure
   - Verificar que no haya conflictos con datos existentes
   - Probar en un entorno de desarrollo primero

2. **Foreign Keys**: Algunas tablas nuevas pueden tener foreign keys que referencian tablas que aún no existen en Azure.

3. **Índices**: Los scripts incluyen índices, pero verifica que no haya conflictos.

4. **Datos Iniciales**: Algunos scripts incluyen datos iniciales (seeders). Decide si quieres incluirlos o no.

---

## 📝 Notas Adicionales

- La base local parece tener una estructura más completa y actualizada.
- Azure tiene la estructura básica funcional pero le faltan módulos avanzados.
- Los scripts SQL en la carpeta `sql/` están diseñados para crear las tablas faltantes.
- Algunas tablas pueden tener nombres ligeramente diferentes (ej: `picking_det` vs `picking_detalle`).

---

## 🔄 Próximos Pasos

1. **Ejecutar script de comparación** para obtener un reporte detallado
2. **Revisar scripts SQL** en la carpeta `sql/` para identificar cuáles aplicar
3. **Crear script de migración** que sincronice Azure con Local
4. **Probar en desarrollo** antes de aplicar en producción
5. **Documentar cambios** realizados

---

**Última actualización**: Noviembre 2025
**Versión del documento**: 1.0

