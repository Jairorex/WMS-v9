# 🚀 SCRIPT DE INSTALACIÓN AUTOMÁTICA DEL BACKEND WMS ESCASAN

## 📋 Descripción
Este script automatiza la instalación completa del backend WMS ESCASAN desde cero.

## 🛠️ Requisitos Previos
- PHP 8.1+
- Composer
- SQL Server con ODBC Driver 17
- Node.js (para frontend)

## 📁 Estructura de Archivos Generados
```
wms-escasan/
├── BACKEND_COMPLETO_DOCUMENTACION.md    # Documentación completa
├── CREAR_BACKEND_COMPLETO.php           # Script de instalación
├── DATABASE_COMPLETE_SCRIPT.sql         # Script SQL completo
├── INSTALACION_AUTOMATICA.md            # Este archivo
└── [archivos del proyecto Laravel]
```

## 🎯 Pasos de Instalación

### 1. Preparar Entorno
```bash
# Clonar o descargar el proyecto
cd wms-escasan

# Instalar dependencias PHP
composer install

# Configurar archivo de entorno
cp .env.example .env
```

### 2. Configurar Base de Datos
```bash
# Generar clave de aplicación
php artisan key:generate

# Configurar .env con datos de SQL Server
# DB_CONNECTION=wms
# DB_HOST=localhost
# DB_PORT=1433
# DB_DATABASE=wms_escasan
# DB_USERNAME=
# DB_PASSWORD=
```

### 3. Crear Base de Datos
```sql
-- Ejecutar en SQL Server Management Studio
-- Crear base de datos y esquema
CREATE DATABASE wms_escasan;
USE wms_escasan;
CREATE SCHEMA wms;
```

### 4. Ejecutar Migraciones y Seeder
```bash
# Ejecutar migraciones con datos iniciales
php artisan migrate:fresh --seed
```

### 5. Verificar Instalación
```bash
# Iniciar servidor
php artisan serve --host=0.0.0.0 --port=8000

# Probar endpoints
curl http://127.0.0.1:8000/api/tareas/catalogos
curl http://127.0.0.1:8000/api/productos/catalogos
```

## 🔧 Configuración Avanzada

### Políticas de Autorización
Las políticas ya están configuradas:
- `ProductPolicy.php` - Gestión de productos
- `LocationPolicy.php` - Gestión de ubicaciones
- `config/policies.php` - Registro de políticas

### Servicios de Negocio
Servicios incluidos:
- `PickingAllocatorService.php` - Asignación de picking
- `PickingScanService.php` - Escaneo de productos
- `PickingCloseService.php` - Cierre de picking
- `StockReservationService.php` - Reserva de stock

### Validaciones
Todas las validaciones están configuradas para usar el esquema `wms`:
```php
'exists:wms.tipos_tarea,id_tipo_tarea'
'exists:wms.estados_tarea,id_estado_tarea'
'exists:wms.usuarios,id_usuario'
```

## 📊 Estructura de Base de Datos

### Tablas Principales (17 tablas)
1. `wms.roles` - Roles de usuario
2. `wms.usuarios` - Usuarios del sistema
3. `wms.productos` - Catálogo de productos
4. `wms.estados_producto` - Estados de productos
5. `wms.ubicaciones` - Ubicaciones físicas
6. `wms.inventario` - Stock por ubicación
7. `wms.tipos_tarea` - Tipos de tareas
8. `wms.estados_tarea` - Estados de tareas
9. `wms.tareas` - Tareas del sistema
10. `wms.tarea_usuario` - Asignación de tareas
11. `wms.tarea_detalle` - Detalles de tareas
12. `wms.incidencias` - Reporte de incidencias
13. `wms.picking` - Órdenes de picking
14. `wms.picking_det` - Detalles de picking
15. `wms.orden_salida` - Órdenes de salida
16. `wms.orden_salida_det` - Detalles de órdenes
17. `wms.notificaciones` - Sistema de notificaciones
18. `personal_access_tokens` - Tokens de autenticación

### Modelos Eloquent (15 modelos)
- `Usuario.php` - Gestión de usuarios
- `Producto.php` - Gestión de productos
- `Ubicacion.php` - Gestión de ubicaciones
- `Tarea.php` - Gestión de tareas
- `TipoTarea.php` - Tipos de tareas
- `EstadoTarea.php` - Estados de tareas
- `Incidencias.php` - Gestión de incidencias
- `Picking.php` - Órdenes de picking
- `OrdenSalida.php` - Órdenes de salida
- `EstadoProducto.php` - Estados de productos
- `TareaUsuario.php` - Asignación de tareas
- `TareaDetalle.php` - Detalles de tareas
- `PickingDet.php` - Detalles de picking
- `OrdenSalidaDet.php` - Detalles de órdenes
- `Rol.php` - Roles de usuario

### Controladores API (5 controladores)
- `TareaController.php` - API de tareas
- `ProductoController.php` - API de productos
- `UbicacionController.php` - API de ubicaciones
- `IncidenciaController.php` - API de incidencias
- `AuthController.php` - API de autenticación

## 🎯 Funcionalidades Incluidas

### Gestión de Usuarios
- Sistema de roles (Admin, Supervisor, Operario)
- Autenticación con Laravel Sanctum
- Políticas de autorización

### Gestión de Productos
- Catálogo completo con estados
- Control de lotes y fechas de caducidad
- Múltiples unidades de medida
- Control de precios

### Gestión de Ubicaciones
- Ubicaciones físicas del almacén
- Control de capacidad
- Tipos de ubicación (Almacén, Picking, Devoluciones)

### Gestión de Inventario
- Stock por producto y ubicación
- Control de existencias
- Actualización automática

### Gestión de Tareas
- Sistema completo de tareas
- Asignación a usuarios
- Estados y prioridades
- Detalles de productos y cantidades

### Gestión de Picking
- Órdenes de picking
- Asignación automática
- Control de estados
- Detalles por producto

### Gestión de Incidencias
- Reporte de incidencias
- Asignación a operarios
- Estados de resolución
- Seguimiento completo

### Sistema de Notificaciones
- Notificaciones por usuario
- Tipos de notificación
- Control de lectura

## 🔍 Verificación de Instalación

### Comandos de Verificación
```bash
# Verificar configuración
php artisan config:show database

# Verificar migraciones
php artisan migrate:status

# Verificar rutas
php artisan route:list

# Verificar cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### Endpoints de Prueba
```bash
# Catálogos
GET /api/tareas/catalogos
GET /api/productos/catalogos
GET /api/ubicaciones/catalogos
GET /api/incidencias/catalogos

# Listas
GET /api/tareas
GET /api/productos
GET /api/ubicaciones
GET /api/incidencias

# Estadísticas
GET /api/tareas/estadisticas
GET /api/incidencias/estadisticas
```

## 🚨 Solución de Problemas

### Error: "Database connection [wms] not configured"
```bash
# Verificar configuración
php artisan config:show database.connections.wms

# Regenerar configuración
php artisan config:clear
php artisan config:cache
```

### Error: "Invalid object name 'wms.tabla'"
```bash
# Verificar que el esquema existe
# Ejecutar en SQL Server:
SELECT * FROM sys.schemas WHERE name = 'wms'

# Verificar que las tablas existen
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('wms')
```

### Error: "This action is unauthorized"
```bash
# Verificar políticas
php artisan route:list --name=api

# Verificar middleware
# Las políticas están configuradas para permitir acceso temporal
```

## 📚 Documentación Adicional

- `BACKEND_COMPLETO_DOCUMENTACION.md` - Documentación técnica completa
- `CREAR_BACKEND_COMPLETO.php` - Script de instalación paso a paso
- `DATABASE_COMPLETE_SCRIPT.sql` - Script SQL completo

## 🎉 ¡Instalación Completada!

Una vez completada la instalación, tendrás:
- ✅ Backend Laravel completamente funcional
- ✅ Base de datos SQL Server con esquema wms
- ✅ 17 tablas con datos iniciales
- ✅ 15 modelos Eloquent configurados
- ✅ 5 controladores API funcionando
- ✅ Sistema de autenticación
- ✅ Políticas de autorización
- ✅ Servicios de negocio
- ✅ Validaciones completas

**¡El sistema WMS ESCASAN está listo para usar!**
