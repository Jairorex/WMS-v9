# 🔧 Solución: Error de Base de Datos SQLite

## ❌ Error Común

```
Database file at path [C:\Users\...\database.sqlite] does not exist.
Ensure this is an absolute path to the database.
(Connection: sqlite, SQL: select * from "sessions" where...)
```

## 🔍 Causa del Problema

Este error ocurre cuando Laravel intenta usar **SQLite** en lugar de **SQL Server** porque:

1. **Falta el archivo `.env`** en la nueva máquina
2. **El archivo `.env` no tiene `DB_CONNECTION=sqlsrv` configurado**
3. **La configuración de sesiones está usando la base de datos por defecto**

## ✅ Solución Paso a Paso

### Paso 1: Crear/Copiar archivo `.env`

En la nueva máquina, copia el archivo `.env.example`:

```bash
cd backend
copy .env.example .env
```

O en Linux/macOS:
```bash
cd backend
cp .env.example .env
```

### Paso 2: Configurar Variables de Base de Datos

Edita el archivo `.env` y asegúrate de tener estas líneas:

```env
# CONEXIÓN DE BASE DE DATOS - CRÍTICO
DB_CONNECTION=sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

# CONFIGURACIÓN DE SESIONES - CRÍTICO
SESSION_DRIVER=database
```

**⚠️ IMPORTANTE:** 
- `DB_CONNECTION` DEBE ser `sqlsrv` (no `sqlite` ni `mysql`)
- `SESSION_DRIVER` debe ser `database` para usar SQL Server

### Paso 3: Generar Clave de Aplicación

```bash
php artisan key:generate
```

### Paso 4: Limpiar Cache de Configuración

```bash
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

### Paso 5: Verificar Configuración

```bash
php artisan config:show database.default
```

Debe mostrar: `sqlsrv`

## 🔍 Verificación de Configuración

### Verificar que el `.env` está siendo leído:

```bash
php artisan tinker
```

Luego ejecuta:
```php
env('DB_CONNECTION')
```

Debe retornar: `"sqlsrv"`

### Verificar conexión a SQL Server:

```bash
php artisan tinker
```

Luego ejecuta:
```php
DB::connection()->getPdo();
```

Si no hay error, la conexión está correcta.

## 📋 Checklist de Instalación en Nueva Máquina

- [ ] Copiar `.env.example` a `.env`
- [ ] Configurar `DB_CONNECTION=sqlsrv` en `.env`
- [ ] Configurar `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
- [ ] Configurar `SESSION_DRIVER=database` en `.env`
- [ ] Ejecutar `php artisan key:generate`
- [ ] Ejecutar `php artisan config:clear`
- [ ] Ejecutar `php artisan config:cache`
- [ ] Verificar que SQL Server esté corriendo
- [ ] Verificar que ODBC Driver 17 esté instalado

## 🚨 Problemas Comunes

### Error: "SQLSTATE[HY000] [2002] No connection"
**Solución:**
- Verificar que SQL Server esté corriendo
- Verificar credenciales en `.env`
- Verificar puerto (1433)
- Verificar firewall

### Error: "ODBC Driver 17 for SQL Server not found"
**Solución:**
- Instalar ODBC Driver 17: https://aka.ms/downloadmsodbcsql
- Reiniciar servidor PHP

### Laravel sigue usando SQLite
**Solución:**
```bash
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

### El archivo `.env` no se está leyendo
**Solución:**
- Verificar que el archivo esté en `backend/.env` (no en la raíz)
- Verificar permisos del archivo
- Verificar que no haya espacios en las líneas del `.env`

## 📝 Estructura Correcta del `.env`

```env
# Aplicación
APP_NAME="WMS ESCASAN"
APP_ENV=local
APP_KEY=base64:... (generado con artisan key:generate)
APP_DEBUG=true
APP_URL=http://localhost:8000

# Base de Datos - CRÍTICO
DB_CONNECTION=sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

# Sesiones - CRÍTICO
SESSION_DRIVER=database
SESSION_LIFETIME=120

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

## 🎯 Resumen

El error ocurre porque **Laravel no encuentra el archivo `.env` o este tiene valores incorrectos**. 

**Solución rápida:**
1. Copiar `.env.example` a `.env`
2. Configurar `DB_CONNECTION=sqlsrv`
3. Configurar `SESSION_DRIVER=database`
4. Ejecutar `php artisan config:clear`

---

**Nota:** El archivo `.env` NO debe ser commitado al repositorio Git. Cada máquina debe tener su propio `.env` con las credenciales locales.

