# Backend Laravel WMS - Instrucciones de Instalación

## Requisitos Previos

1. **PHP 8.1 o superior**
2. **Composer** (gestor de dependencias de PHP)
3. **SQL Server** (2016 o superior)
4. **SQL Server Management Studio** (opcional, para administración)

## Instalación del Backend

### 1. Configuración de la Base de Datos

#### Instalar SQL Server
- Descargar e instalar SQL Server desde: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
- Durante la instalación, asegúrate de habilitar la autenticación mixta (Windows + SQL Server)
- Configurar el usuario `sa` con una contraseña segura

#### Crear la Base de Datos
```sql
-- Ejecutar en SQL Server Management Studio
CREATE DATABASE wms_escasan;
GO

USE wms_escasan;
GO

-- Crear el esquema wms
CREATE SCHEMA wms;
GO
```

#### Ejecutar el Script de Base de Datos
```bash
# Ejecutar el script SQL completo
sqlcmd -S localhost -U sa -P "tu_password" -i DATABASE_COMPLETE_SCRIPT.sql
```

### 2. Configuración del Proyecto Laravel

#### Instalar Dependencias
```bash
cd backend
composer install
```

#### Configurar Variables de Entorno
Editar el archivo `.env`:
```env
APP_NAME="WMS Escasan"
APP_ENV=local
APP_KEY=base64:tu_app_key_aqui
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=sqlsrv
DB_HOST=127.0.0.1
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=sa
DB_PASSWORD=tu_password_sql_server

SANCTUM_STATEFUL_DOMAINS=localhost:5173,127.0.0.1:5173
```

#### Generar Clave de Aplicación
```bash
php artisan key:generate
```

#### Ejecutar Migraciones
```bash
php artisan migrate
```

### 3. Configuración de Sanctum

#### Publicar Archivos de Sanctum
```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

#### Configurar Sanctum
El archivo `config/sanctum.php` ya está configurado correctamente.

### 4. Iniciar el Servidor

```bash
php artisan serve
```

El servidor estará disponible en: http://localhost:8000

## Estructura del Backend

### Modelos Implementados
- **Rol**: Gestión de roles de usuario
- **Usuario**: Usuarios del sistema con autenticación
- **EstadoProducto**: Estados de productos (Disponible, Retenido, etc.)
- **Producto**: Productos del almacén
- **Ubicacion**: Ubicaciones físicas del almacén
- **Inventario**: Stock de productos por ubicación
- **TipoTarea**: Tipos de tareas del sistema
- **EstadoTarea**: Estados de tareas
- **Tarea**: Tareas del sistema
- **TareaDetalle**: Detalles de productos en tareas
- **Incidencia**: Incidencias reportadas
- **Picking**: Tareas de picking
- **PickingDetalle**: Detalles de picking
- **OrdenSalida**: Órdenes de salida
- **OrdenSalidaDetalle**: Detalles de órdenes de salida

### Controladores API Implementados
- **AuthController**: Autenticación (login, logout, me)
- **DashboardController**: Estadísticas del dashboard
- **ProductoController**: CRUD de productos
- **InventarioController**: Gestión de inventario
- **UbicacionController**: CRUD de ubicaciones
- **TareaController**: CRUD de tareas
- **IncidenciaController**: CRUD de incidencias
- **PickingController**: Gestión de picking
- **OrdenSalidaController**: CRUD de órdenes de salida

### Endpoints Disponibles

#### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/me` - Obtener usuario actual

#### Dashboard
- `GET /api/dashboard/estadisticas` - Estadísticas generales
- `GET /api/dashboard/actividad` - Actividad reciente
- `GET /api/dashboard/resumen` - Resumen completo

#### Productos
- `GET /api/productos` - Listar productos
- `POST /api/productos` - Crear producto
- `GET /api/productos/{id}` - Ver producto
- `PUT /api/productos/{id}` - Actualizar producto
- `DELETE /api/productos/{id}` - Eliminar producto
- `PATCH /api/productos/{id}/activar` - Activar producto
- `PATCH /api/productos/{id}/desactivar` - Desactivar producto
- `GET /api/productos-catalogos` - Catálogos para productos

#### Inventario
- `GET /api/inventario` - Listar inventario
- `GET /api/inventario/{id}` - Ver inventario
- `PUT /api/inventario/{id}` - Actualizar inventario
- `PATCH /api/inventario/{id}/ajustar` - Ajustar inventario

#### Ubicaciones
- `GET /api/ubicaciones` - Listar ubicaciones
- `POST /api/ubicaciones` - Crear ubicación
- `GET /api/ubicaciones/{id}` - Ver ubicación
- `PUT /api/ubicaciones/{id}` - Actualizar ubicación
- `DELETE /api/ubicaciones/{id}` - Eliminar ubicación
- `PATCH /api/ubicaciones/{id}/activar` - Activar ubicación
- `PATCH /api/ubicaciones/{id}/desactivar` - Desactivar ubicación
- `GET /api/ubicaciones-catalogos` - Catálogos para ubicaciones

#### Tareas
- `GET /api/tareas` - Listar tareas
- `POST /api/tareas` - Crear tarea
- `GET /api/tareas/{id}` - Ver tarea
- `PUT /api/tareas/{id}` - Actualizar tarea
- `DELETE /api/tareas/{id}` - Eliminar tarea
- `PATCH /api/tareas/{id}/asignar` - Asignar tarea
- `PATCH /api/tareas/{id}/cambiar-estado` - Cambiar estado de tarea
- `GET /api/tareas-catalogos` - Catálogos para tareas

#### Incidencias
- `GET /api/incidencias` - Listar incidencias
- `POST /api/incidencias` - Crear incidencia
- `GET /api/incidencias/{id}` - Ver incidencia
- `PUT /api/incidencias/{id}` - Actualizar incidencia
- `DELETE /api/incidencias/{id}` - Eliminar incidencia
- `PATCH /api/incidencias/{id}/resolver` - Resolver incidencia
- `PATCH /api/incidencias/{id}/reabrir` - Reabrir incidencia
- `GET /api/incidencias-catalogos` - Catálogos para incidencias

#### Picking
- `GET /api/picking` - Listar picking
- `POST /api/picking` - Crear picking
- `GET /api/picking/{id}` - Ver picking
- `PUT /api/picking/{id}` - Actualizar picking
- `DELETE /api/picking/{id}` - Eliminar picking
- `PATCH /api/picking/{id}/asignar` - Asignar picking
- `PATCH /api/picking/{id}/completar` - Completar picking
- `PATCH /api/picking/{id}/cancelar` - Cancelar picking

#### Órdenes de Salida
- `GET /api/ordenes-salida` - Listar órdenes
- `POST /api/ordenes-salida` - Crear orden
- `GET /api/ordenes-salida/{id}` - Ver orden
- `PUT /api/ordenes-salida/{id}` - Actualizar orden
- `DELETE /api/ordenes-salida/{id}` - Eliminar orden
- `PATCH /api/ordenes-salida/{id}/confirmar` - Confirmar orden
- `PATCH /api/ordenes-salida/{id}/cancelar` - Cancelar orden
- `GET /api/ordenes-salida-catalogos` - Catálogos para órdenes

## Configuración del Frontend

### Variables de Entorno del Frontend
Crear archivo `.env` en el directorio `frontend`:
```env
VITE_API_URL=http://localhost:8000
```

### Iniciar el Frontend
```bash
cd frontend
npm install
npm run dev
```

## Pruebas

### Probar Autenticación
```bash
# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario": "admin", "password": "admin123"}'

# Usar el token en requests posteriores
curl -X GET http://localhost:8000/api/me \
  -H "Authorization: Bearer tu_token_aqui"
```

### Probar Endpoints
```bash
# Obtener productos
curl -X GET http://localhost:8000/api/productos \
  -H "Authorization: Bearer tu_token_aqui"

# Obtener estadísticas del dashboard
curl -X GET http://localhost:8000/api/dashboard/estadisticas \
  -H "Authorization: Bearer tu_token_aqui"
```

## Notas Importantes

1. **CORS**: El middleware CORS está configurado para permitir todas las conexiones desde el frontend.

2. **Autenticación**: Se utiliza Laravel Sanctum para la autenticación basada en tokens.

3. **Base de Datos**: El sistema está configurado para usar SQL Server con el esquema `wms`.

4. **Validación**: Todos los endpoints incluyen validación de datos de entrada.

5. **Relaciones**: Los modelos incluyen todas las relaciones necesarias para el funcionamiento del sistema.

6. **Filtros**: Los endpoints de listado incluyen filtros avanzados para búsquedas.

## Solución de Problemas

### Error de Conexión a SQL Server
- Verificar que SQL Server esté ejecutándose
- Verificar las credenciales en el archivo `.env`
- Verificar que el puerto 1433 esté abierto

### Error de CORS
- Verificar que el middleware CORS esté registrado
- Verificar las URLs del frontend en `SANCTUM_STATEFUL_DOMAINS`

### Error de Autenticación
- Verificar que Sanctum esté configurado correctamente
- Verificar que el token se esté enviando en el header Authorization
