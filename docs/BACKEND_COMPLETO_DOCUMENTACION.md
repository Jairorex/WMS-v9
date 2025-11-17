# 📋 DOCUMENTACIÓN COMPLETA DEL BACKEND WMS ESCASAN

## 🎯 RESUMEN DEL SISTEMA
Sistema de gestión de almacén (WMS) desarrollado con Laravel 11 y SQL Server, diseñado para ESCASAN con esquema `wms` y autenticación multiusuario.

---

## 🗄️ ESTRUCTURA DE BASE DE DATOS

### Esquema Principal: `wms`

#### Tablas Principales:
1. **wms.roles** - Roles de usuario (Admin, Supervisor, Operario)
2. **wms.usuarios** - Usuarios del sistema
3. **wms.productos** - Catálogo de productos
4. **wms.estados_producto** - Estados de productos (Disponible, Dañado, Retenido, Calidad)
5. **wms.ubicaciones** - Ubicaciones físicas del almacén
6. **wms.inventario** - Stock por producto y ubicación
7. **wms.tipos_tarea** - Tipos de tareas (Picking, Putaway, Reubicación, etc.)
8. **wms.estados_tarea** - Estados de tareas (Nueva, En Proceso, Completada, etc.)
9. **wms.tareas** - Tareas del sistema
10. **wms.tarea_usuario** - Asignación de tareas a usuarios
11. **wms.tarea_detalle** - Detalles de tareas (productos, cantidades, ubicaciones)
12. **wms.incidencias** - Reporte de incidencias
13. **wms.picking** - Órdenes de picking
14. **wms.picking_det** - Detalles de picking
15. **wms.orden_salida** - Órdenes de salida
16. **wms.orden_salida_det** - Detalles de órdenes de salida
17. **wms.notificaciones** - Sistema de notificaciones
18. **personal_access_tokens** - Tokens de autenticación (Laravel Sanctum)

---

## ⚙️ CONFIGURACIÓN DE BASE DE DATOS

### Archivo: `config/database.php`
```php
'default' => env('DB_CONNECTION', 'wms'),

'wms' => [
    'driver' => 'sqlsrv',
    'url' => env('DB_URL'),
    'host' => env('DB_HOST', 'localhost'),
    'port' => env('DB_PORT', '1433'),
    'database' => env('DB_DATABASE', 'wms_escasan'),
    'username' => env('DB_USERNAME', ''),
    'password' => env('DB_PASSWORD', ''),
    'charset' => env('DB_CHARSET', 'utf8'),
    'prefix' => '',
    'prefix_indexes' => true,
    'encrypt' => env('DB_ENCRYPT', 'no'),
    'trust_server_certificate' => env('DB_TRUST_SERVER_CERTIFICATE', 'true'),
    'options' => [
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::ATTR_STRINGIFY_FETCHES => false,
    ],
    'schema' => 'wms',
],
```

### Archivo: `.env`
```env
DB_CONNECTION=wms
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=
DB_PASSWORD=
DB_ENCRYPT=no
DB_TRUST_SERVER_CERTIFICATE=true
```

---

## 🏗️ MIGRACIONES DE BASE DE DATOS

### Orden de Ejecución (CRÍTICO):
1. `2025_10_05_030000_create_roles_table.php`
2. `2025_10_05_030001_create_usuarios_table.php`
3. `2025_10_05_030002_create_productos_table.php`
4. `2025_10_05_030003_create_estado_producto_table.php`
5. `2025_10_05_030004_create_ubicaciones_table.php`
6. `2025_10_05_030005_create_inventario_table.php`
7. `2025_10_05_030006_create_tipo_tarea_table.php`
8. `2025_10_05_030007_create_estado_tarea_table.php`
9. `2025_10_05_030008_create_tareas_table.php`
10. `2025_10_05_030009_create_tarea_usuario_table.php`
11. `2025_10_05_030010_create_tarea_detalle_table.php`
12. `2025_10_05_030011_create_incidencias_table.php`
13. `2025_10_05_030012_create_personal_access_tokens_table.php`
14. `2025_10_05_030013_create_picking_table.php`
15. `2025_10_05_030014_create_picking_det_table.php`
16. `2025_10_05_030015_create_orden_salida_table.php`
17. `2025_10_05_030016_create_orden_salida_det_table.php`

---

## 🌱 SEEDER DE DATOS INICIALES

### Archivo: `database/seeders/WmsSeed.php`
- Roles: Admin, Supervisor, Operario
- Estados de productos: Disponible, Dañado, Retenido, Calidad
- Tipos de tareas: PICK_ENTRADA, PICK_SALIDA, PUTAWAY, REUBICACION, INVENTARIO
- Estados de tareas: NUEVA, ABIERTA, EN_PROCESO, COMPLETADA, CANCELADA
- Usuario admin por defecto
- Ubicaciones de ejemplo
- Productos de ejemplo

---

## 🎭 MODELOS ELOQUENT

### Configuración Estándar para Todos los Modelos:
```php
protected $connection = 'wms';
protected $table = 'wms.nombre_tabla';
protected $primaryKey = 'id_campo';
```

### Modelos Principales:
- `Usuario.php` - Gestión de usuarios
- `Producto.php` - Gestión de productos
- `Ubicacion.php` - Gestión de ubicaciones
- `Tarea.php` - Gestión de tareas
- `TipoTarea.php` - Tipos de tareas
- `EstadoTarea.php` - Estados de tareas
- `Incidencias.php` - Gestión de incidencias
- `Picking.php` - Órdenes de picking
- `OrdenSalida.php` - Órdenes de salida

---

## 🎮 CONTROLADORES API

### Endpoints Principales:

#### TareaController (`/api/tareas`)
- `GET /api/tareas` - Lista de tareas con filtros
- `POST /api/tareas` - Crear nueva tarea
- `GET /api/tareas/{id}` - Obtener tarea específica
- `PUT /api/tareas/{id}` - Actualizar tarea
- `POST /api/tareas/{id}/cambiar-estado` - Cambiar estado
- `POST /api/tareas/{id}/asignar-usuario` - Asignar usuario
- `POST /api/tareas/{id}/desasignar-usuario` - Desasignar usuario
- `GET /api/tareas/catalogos` - Obtener catálogos
- `GET /api/tareas/estadisticas` - Estadísticas de tareas

#### ProductoController (`/api/productos`)
- `GET /api/productos` - Lista de productos
- `POST /api/productos` - Crear producto
- `GET /api/productos/{id}` - Obtener producto
- `PUT /api/productos/{id}` - Actualizar producto
- `GET /api/productos/catalogos` - Obtener catálogos
- `GET /api/productos/{id}/existencias` - Existencias por ubicación

#### UbicacionController (`/api/ubicaciones`)
- `GET /api/ubicaciones` - Lista de ubicaciones
- `POST /api/ubicaciones` - Crear ubicación
- `GET /api/ubicaciones/{id}` - Obtener ubicación
- `PUT /api/ubicaciones/{id}` - Actualizar ubicación
- `GET /api/ubicaciones/catalogos` - Obtener catálogos
- `GET /api/ubicaciones/{id}/inventario` - Inventario por ubicación

#### IncidenciaController (`/api/incidencias`)
- `GET /api/incidencias` - Lista de incidencias
- `POST /api/incidencias` - Crear incidencia
- `GET /api/incidencias/{id}` - Obtener incidencia
- `PUT /api/incidencias/{id}` - Actualizar incidencia
- `POST /api/incidencias/{id}/resolver` - Resolver incidencia
- `GET /api/incidencias/catalogos` - Obtener catálogos
- `GET /api/incidencias/estadisticas` - Estadísticas de incidencias

#### AuthController (`/api/auth`)
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/auth/user` - Obtener usuario actual

---

## 🔐 AUTENTICACIÓN Y AUTORIZACIÓN

### Laravel Sanctum
- Autenticación basada en tokens
- Middleware `auth:sanctum` para rutas protegidas
- Token almacenado en `personal_access_tokens`

### Políticas de Autorización
- `ProductPolicy.php` - Autorización para productos
- `LocationPolicy.php` - Autorización para ubicaciones
- Registradas en `config/policies.php`

### Middleware
- `auth:sanctum` - Verificar autenticación
- `throttle:api` - Rate limiting

---

## 🛠️ SERVICIOS DE NEGOCIO

### Servicios Principales:
- `PickingAllocatorService.php` - Asignación de picking
- `PickingScanService.php` - Escaneo de productos
- `PickingCloseService.php` - Cierre de picking
- `StockReservationService.php` - Reserva de stock

---

## 📊 VALIDACIONES

### Validaciones Estándar:
```php
// Tareas
'tipo_tarea_id' => 'required|exists:wms.tipos_tarea,id_tipo_tarea'
'estado_tarea_id' => 'required|exists:wms.estados_tarea,id_estado_tarea'
'prioridad' => 'required|in:Baja,Media,Alta,Critica'

// Productos
'estado_producto_id' => 'required|exists:wms.estados_producto,id_estado_producto'
'unidad_medida' => 'required|in:Unidad,Caja,Kg,Litro,Otro'

// Usuarios
'rol_id' => 'required|exists:wms.roles,id_rol'
```

---

## 🚀 COMANDOS DE INSTALACIÓN

### 1. Configuración Inicial:
```bash
composer install
cp .env.example .env
php artisan key:generate
```

### 2. Configuración de Base de Datos:
```bash
# Configurar .env con datos de SQL Server
# Ejecutar migraciones
php artisan migrate:fresh --seed
```

### 3. Iniciar Servidor:
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 🔧 SCRIPTS DE AUTOMATIZACIÓN

### PowerShell Scripts:
- `configurar-sqlserver.ps1` - Configuración automática
- `ejecutar-migraciones.ps1` - Ejecutar migraciones y seeder

---

## 📝 NOTAS IMPORTANTES

### SQL Server Específico:
- Usar `onDelete('no action')` en lugar de `onDelete('restrict')`
- Esquema `wms` debe existir antes de ejecutar migraciones
- Windows Authentication configurada por defecto

### Validaciones:
- Todas las validaciones `exists` deben usar esquema completo `wms.tabla`
- Conexión `wms` configurada en todos los modelos

### Cache:
- Cache de configuración, rutas y vistas funciona correctamente
- Cache de base de datos requiere tabla `cache` (opcional)

---

## 🎯 FUNCIONALIDADES PRINCIPALES

1. **Gestión de Usuarios** - Roles y permisos
2. **Gestión de Productos** - Catálogo con estados y lotes
3. **Gestión de Ubicaciones** - Ubicaciones físicas del almacén
4. **Gestión de Inventario** - Stock por producto y ubicación
5. **Gestión de Tareas** - Sistema completo de tareas
6. **Gestión de Picking** - Órdenes de picking
7. **Gestión de Incidencias** - Reporte y resolución
8. **Sistema de Notificaciones** - Alertas y notificaciones
9. **Reportes y Estadísticas** - Dashboards y métricas

---

## 📞 SOPORTE

Para recrear el backend desde cero:
1. Seguir el orden de migraciones
2. Configurar conexión `wms` en `database.php`
3. Ejecutar seeder para datos iniciales
4. Configurar políticas de autorización
5. Probar endpoints con Postman

**¡Sistema completamente funcional y documentado!**
