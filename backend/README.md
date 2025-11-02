# 📦 Paquete de Instalación WMS Escasan - Manual Completo

## 🎯 Descripción General

Este paquete contiene todo lo necesario para instalar el **Sistema WMS Escasan** en cualquier PC con Windows. El sistema incluye gestión completa de almacén con módulos avanzados de lotes, trazabilidad y notificaciones.

## 📋 Contenido del Paquete

### 🗂️ Estructura de Archivos
```
WMS-Escasan-Installer/
├── 📁 backend/                    # Backend Laravel completo
│   ├── 📁 app/                    # Aplicación Laravel
│   │   ├── 📁 Http/Controllers/   # Controladores API
│   │   ├── 📁 Models/             # Modelos Eloquent
│   │   └── 📁 Traits/             # Traits personalizados
│   ├── 📁 config/                 # Configuraciones
│   ├── 📁 routes/                 # Rutas API
│   ├── 📁 database/               # Scripts de base de datos
│   ├── 📄 composer.json           # Dependencias PHP
│   ├── 📄 .env.example           # Variables de entorno
│   └── 📄 artisan                 # CLI Laravel
├── 📁 frontend/                   # Frontend React completo
│   ├── 📁 src/                    # Código fuente React
│   │   ├── 📁 components/        # Componentes React
│   │   ├── 📁 pages/              # Páginas de la aplicación
│   │   ├── 📁 contexts/           # Contextos de React
│   │   └── 📁 lib/                # Utilidades
│   ├── 📁 public/                 # Archivos públicos
│   ├── 📄 package.json            # Dependencias Node.js
│   ├── 📄 vite.config.ts          # Configuración Vite
│   └── 📄 tailwind.config.js      # Configuración Tailwind
├── 📁 database/                   # Scripts de base de datos
│   ├── 📄 crear_base_datos.sql    # Crear base de datos
│   ├── 📄 crear_tablas_basicas.sql # Tablas básicas
│   ├── 📄 instalar_modulos.sql    # Módulos avanzados
│   ├── 📄 datos_iniciales.sql     # Datos de prueba
│   └── 📄 verificar_instalacion.sql # Verificación
├── 📁 scripts/                    # Scripts de instalación
│   ├── 📄 instalar_windows.bat    # Instalación automática
│   ├── 📄 configurar_laravel.bat  # Configurar Laravel
│   ├── 📄 configurar_frontend.bat # Configurar Frontend
│   └── 📄 iniciar_servicios.bat  # Iniciar servicios
├── 📁 docs/                       # Documentación
│   ├── 📄 MANUAL_INSTALACION.md   # Manual de instalación
│   ├── 📄 MANUAL_USUARIO.md       # Manual de usuario
│   ├── 📄 TROUBLESHOOTING.md      # Solución de problemas
│   └── 📄 REQUISITOS_SISTEMA.md   # Requisitos del sistema
├── 📄 INSTALAR.bat                # Instalador principal
├── 📄 DESINSTALAR.bat             # Desinstalador
└── 📄 README.md                   # Este archivo
```

## 🚀 Instalación Automática

### Requisitos del Sistema
- **Windows 10/11** (64-bit)
- **SQL Server 2019+** o **SQL Server Express**
- **PHP 8.1+** con extensiones necesarias
- **Node.js 18+** y npm
- **Composer** (gestor de dependencias PHP)
- **Git** (opcional, para actualizaciones)

### Instalación en 3 Pasos

#### Paso 1: Ejecutar Instalador Principal
```batch
# Doble clic en el archivo
INSTALAR.bat
```

#### Paso 2: Configurar Base de Datos
```sql
-- En SQL Server Management Studio
USE master;
:r database/crear_base_datos.sql
```

#### Paso 3: Iniciar Servicios
```batch
# Doble clic en el archivo
iniciar_servicios.bat
```

## 🔧 Configuración Manual

### 1. Configurar Backend Laravel
```bash
cd backend
copy .env.example .env
# Editar .env con datos de la base de datos
composer install
php artisan key:generate
php artisan config:cache
```

### 2. Configurar Frontend React
```bash
cd frontend
npm install
npm run build
```

### 3. Configurar Base de Datos
```sql
-- Crear base de datos
CREATE DATABASE wms_escasan;

-- Ejecutar scripts de instalación
USE wms_escasan;
:r database/crear_tablas_basicas.sql
:r database/instalar_modulos.sql
:r database/datos_iniciales.sql
```

## 📊 Módulos Incluidos

### ✅ **Módulos Básicos**
- **Usuarios y Roles** - Gestión de usuarios y permisos
- **Productos** - Catálogo de productos con unidades de medida
- **Ubicaciones** - Gestión de ubicaciones del almacén
- **Inventario** - Control de stock en tiempo real
- **Tareas** - Gestión de tareas y asignaciones
- **Incidencias** - Sistema de incidencias y seguimiento

### ✅ **Módulos Avanzados**
- **Lotes y Trazabilidad** - Control de lotes con fechas de caducidad
- **Notificaciones** - Sistema multi-canal (email, push, web)
- **Dashboard** - Panel de control con KPIs
- **Reportes** - Generación de reportes avanzados

## 🎯 Características del Sistema

### 🔐 **Seguridad**
- Autenticación con Laravel Sanctum
- Roles y permisos granulares
- Cifrado de datos sensibles
- Logs de auditoría

### 📱 **Interfaz de Usuario**
- Diseño responsive (móvil, tablet, desktop)
- Interfaz intuitiva y moderna
- Notificaciones en tiempo real
- Modales para edición rápida

### 🔄 **Integración**
- API REST completa
- CORS configurado
- Documentación de endpoints
- Validación de datos

### 📊 **Reportes y Analytics**
- Dashboard en tiempo real
- KPIs del sistema
- Reportes exportables (PDF, Excel)
- Estadísticas de uso

## 🚀 Acceso al Sistema

### URLs de Acceso
- **Frontend**: `http://localhost:5174`
- **Backend API**: `http://127.0.0.1:8000`
- **Documentación API**: `http://127.0.0.1:8000/api/documentation`

### Credenciales por Defecto
- **Usuario**: `admin@escasan.com`
- **Contraseña**: `admin123`
- **Rol**: Administrador

## 📋 Checklist de Instalación

### ✅ **Pre-instalación**
- [ ] Verificar requisitos del sistema
- [ ] Instalar SQL Server
- [ ] Instalar PHP 8.1+
- [ ] Instalar Node.js 18+
- [ ] Instalar Composer

### ✅ **Instalación**
- [ ] Ejecutar `INSTALAR.bat`
- [ ] Configurar base de datos
- [ ] Ejecutar scripts SQL
- [ ] Verificar instalación

### ✅ **Post-instalación**
- [ ] Probar login de administrador
- [ ] Verificar módulos funcionando
- [ ] Configurar usuarios adicionales
- [ ] Personalizar configuración

## 🔧 Solución de Problemas

### Error de Conexión a Base de Datos
```bash
# Verificar configuración en .env
DB_CONNECTION=sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=sa
DB_PASSWORD=tu_password
```

### Error de CORS
```bash
# Limpiar caché de configuración
php artisan config:clear
php artisan cache:clear
```

### Error de Dependencias
```bash
# Reinstalar dependencias
composer install --no-dev --optimize-autoloader
npm install --production
```

## 📞 Soporte Técnico

### Documentación Disponible
- **Manual de Instalación**: `docs/MANUAL_INSTALACION.md`
- **Manual de Usuario**: `docs/MANUAL_USUARIO.md`
- **Solución de Problemas**: `docs/TROUBLESHOOTING.md`

### Contacto
- **Email**: soporte@escasan.com
- **Teléfono**: +1 (555) 123-4567
- **Horario**: Lunes a Viernes, 9:00 AM - 6:00 PM

## 🎉 Conclusión

Este paquete de instalación proporciona todo lo necesario para implementar el **Sistema WMS Escasan** en cualquier PC con Windows. El sistema incluye:

- ✅ **Instalación automatizada** en 3 pasos
- ✅ **Todos los módulos** incluidos
- ✅ **Documentación completa**
- ✅ **Soporte técnico** disponible
- ✅ **Configuración lista** para producción

**¡El sistema está listo para usar en cualquier entorno!** 🚀

---

**Versión**: 1.0.0  
**Fecha**: Octubre 2024  
**Desarrollado por**: Equipo de Desarrollo Escasan