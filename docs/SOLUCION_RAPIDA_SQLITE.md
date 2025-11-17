# ⚡ Solución Rápida: Error SQLite

## 🔴 Error

```
Database file at path [...] does not exist. (Connection: sqlite)
```

## ✅ Solución Inmediata

### Paso 1: Verificar que existe `.env`

```bash
cd backend
# Verificar si existe
ls -la .env  # Linux/macOS
dir .env     # Windows
```

**Si NO existe:**
```bash
# Copiar desde ejemplo
copy .env.example .env    # Windows
cp .env.example .env      # Linux/macOS
```

### Paso 2: Configurar `.env` Correctamente

**Abrir `.env` y verificar estas líneas:**

```env
# ❌ INCORRECTO (causa el error)
DB_CONNECTION=sqlite

# ✅ CORRECTO (debe ser así)
DB_CONNECTION=sqlsrv
```

**Configuración completa mínima:**

```env
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# BASE DE DATOS - CRÍTICO
DB_CONNECTION=sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

# SESIONES - CRÍTICO
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

### Paso 3: Generar Clave de Aplicación

```bash
cd backend
php artisan key:generate
```

### Paso 4: Limpiar Cache

```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### Paso 5: Verificar Configuración

```bash
php artisan config:show database.default
```

**Debe mostrar:** `sqlsrv`

Si muestra `sqlite`, el problema persiste. Verifica:

1. Que el archivo `.env` está en `backend/.env` (no en la raíz)
2. Que no hay espacios antes/después del `=`
3. Que no hay comillas innecesarias
4. Que la línea `DB_CONNECTION=sqlsrv` está presente

---

## 🔍 Verificación Detallada

### Verificar que Laravel lee el `.env`

```bash
php artisan tinker
```

Luego ejecuta:
```php
env('DB_CONNECTION')
```

**Debe retornar:** `"sqlsrv"`

Si retorna `null` o `"sqlite"`:
- El archivo `.env` no está en el lugar correcto
- O hay un error de sintaxis en el archivo

### Verificar conexión a SQL Server

```bash
php artisan tinker
```

Luego ejecuta:
```php
DB::connection()->getPdo();
```

Si no hay error, la conexión está correcta.

---

## 🚨 Solución de Problemas

### Problema: `.env` no se está leyendo

**Solución:**
```bash
# Verificar ubicación
pwd  # Debe estar en backend/
ls -la .env  # Verificar que existe

# Verificar permisos (Linux/macOS)
chmod 644 .env
```

### Problema: Sigue mostrando `sqlite`

**Solución:**
```bash
# Limpiar TODOS los caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Regenerar cache de configuración
php artisan config:cache
```

### Problema: Error de conexión a SQL Server

**Verificar:**
1. SQL Server está corriendo
2. Puerto 1433 está abierto
3. Credenciales en `.env` son correctas
4. ODBC Driver 17 está instalado

---

## 📝 Checklist Rápido

- [ ] Archivo `.env` existe en `backend/.env`
- [ ] `DB_CONNECTION=sqlsrv` (NO sqlite)
- [ ] `SESSION_DRIVER=database`
- [ ] `APP_KEY` está generado
- [ ] Cache limpiado (`php artisan config:clear`)
- [ ] Verificado con `php artisan config:show database.default`

---

## ✅ Comando Todo-en-Uno

```bash
cd backend
copy .env.example .env    # Windows
# O: cp .env.example .env  # Linux/macOS

# Editar .env manualmente y cambiar:
# DB_CONNECTION=sqlsrv
# SESSION_DRIVER=database

php artisan key:generate
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

---

**Si el problema persiste, verifica que:**
1. El archivo `.env` está en la ubicación correcta
2. No hay errores de sintaxis en el archivo
3. SQL Server está corriendo y accesible
4. ODBC Driver 17 está instalado

