# 📦 REQUISITOS Y DEPENDENCIAS PARA INSTALACIÓN

## 🖥️ REQUISITOS DEL SISTEMA

### Sistema Operativo
- **Windows 10/11** (actualmente configurado)
- **Linux** (Ubuntu 20.04+ / Debian 11+)
- **macOS** (10.15+)

---

## 🔧 BACKEND (Laravel)

### 1. PHP
- **Versión requerida:** PHP 8.2 o superior
- **Versión recomendada:** PHP 8.2.x o PHP 8.3.x

#### Extensiones PHP Necesarias:
```bash
# Extensiones básicas de Laravel
- php-bcmath          # Operaciones matemáticas
- php-ctype           # Validación de tipos
- php-fileinfo        # Información de archivos
- php-json            # JSON
- php-mbstring        # Cadenas multibyte
- php-openssl         # SSL/TLS
- php-pdo             # PDO (requerido)
- php-pdo_sqlsrv      # Driver SQL Server para PDO
- php-sqlsrv          # Driver SQL Server
- php-tokenizer       # Tokenización
- php-xml             # XML
- php-xmlwriter       # Escritura XML
- php-zip             # Archivos ZIP
- php-curl            # HTTP requests
```

#### Instalación en Windows:
```powershell
# Usar XAMPP, WAMP o instalar PHP directamente
# Descargar PHP desde: https://windows.php.net/download/

# Habilitar extensiones en php.ini:
extension=pdo_sqlsrv
extension=sqlsrv
extension=curl
extension=fileinfo
extension=mbstring
extension=openssl
extension=xml
```

#### Instalación en Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install php8.2 php8.2-cli php8.2-common php8.2-mysql php8.2-zip \
    php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath \
    php8.2-sqlite3 php8.2-pdo php8.2-pdo-sqlsrv php8.2-sqlsrv

# Instalar drivers SQL Server para Linux
sudo apt install curl apt-transport-https
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt update
sudo ACCEPT_EULA=Y apt install msodbcsql17 unixodbc-dev
sudo pecl install sqlsrv pdo_sqlsrv
```

#### Instalación en macOS:
```bash
# Usar Homebrew
brew install php@8.2
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew install msodbcsql17 mssql-tools
pecl install sqlsrv pdo_sqlsrv
```

### 2. Composer
- **Versión requerida:** Composer 2.x
- **Descarga:** https://getcomposer.org/download/

#### Verificar instalación:
```bash
composer --version
```

### 3. SQL Server
- **SQL Server 2019+** o **SQL Server Express**
- **ODBC Driver 17 for SQL Server** (REQUERIDO)

#### Instalación ODBC Driver 17:
- **Windows:**  
- **Linux:** 
```bash
sudo apt install msodbcsql17
```
- **macOS:**
```bash
brew tap microsoft/mssql-release
brew install msodbcsql17
```

#### Verificar conexión:
```bash
# Windows PowerShell
odbcinst -q -d

# Linux
odbcinst -q -d
```

### 4. Dependencias PHP (Composer)
El archivo `backend/composer.json` define las siguientes dependencias:

#### Producción:
```json
{
  "php": "^8.2",
  "laravel/framework": "^12.0",
  "laravel/sanctum": "^4.2",
  "laravel/tinker": "^2.10.1"
}
```

#### Desarrollo (opcional):
```json
{
  "fakerphp/faker": "^1.23",
  "laravel/pail": "^1.2.2",
  "laravel/pint": "^1.24",
  "laravel/sail": "^1.41",
  "mockery/mockery": "^1.6",
  "nunomaduro/collision": "^8.6",
  "phpunit/phpunit": "^11.5.3"
}
```

#### Instalación:
```bash
cd backend
composer install              # Instala dependencias de producción
composer install --dev        # Incluye dependencias de desarrollo
```

---

## 🎨 FRONTEND (React + Vite)

### 1. Node.js
- **Versión requerida:** Node.js 18.x o superior
- **Versión recomendada:** Node.js 20.x LTS
- **Descarga:** https://nodejs.org/

#### Verificar instalación:
```bash
node --version
npm --version
```

### 2. Dependencias NPM
El archivo `frontend/package.json` define las siguientes dependencias:

#### Producción:
```json
{
  "axios": "^1.12.2",
  "react": "^19.1.1",
  "react-dom": "^19.1.1",
  "react-router-dom": "^7.9.3"
}
```

#### Desarrollo:
```json
{
  "@vitejs/plugin-react": "^5.0.4",
  "autoprefixer": "^10.4.21",
  "eslint": "^9.36.0",
  "postcss": "^8.5.6",
  "tailwindcss": "^3.4.18",
  "typescript": "~5.9.3",
  "vite": "^7.1.7"
}
```

#### Instalación:
```bash
cd frontend
npm install              # Instala todas las dependencias
npm install --production # Solo dependencias de producción
```

---

## 🗄️ BASE DE DATOS

### SQL Server
- **Versión:** SQL Server 2019 o superior
- **Puerto:** 1433 (por defecto)
- **Esquema requerido:** `wms` o `dbo`

### Scripts de Base de Datos
- `DATABASE_COMPLETE_SCRIPT.sql` - Script completo de creación
- `backend/database/migrations/create_tareas_log_table.sql` - Tabla de logs

### Configuración de Conexión
```env
DB_CONNECTION=sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password
```

---

## 📋 CHECKLIST DE INSTALACIÓN

### Paso 1: Verificar Requisitos
```bash
# PHP
php -v                    # Debe ser 8.2+
php -m                    # Ver extensiones instaladas

# Composer
composer --version

# Node.js
node --version            # Debe ser 18+
npm --version

# SQL Server
# Verificar que el servicio está corriendo
```

### Paso 2: Clonar/Descargar Proyecto
```bash
git clone <url-repositorio> WMS-v9
cd WMS-v9
```

### Paso 3: Instalar Backend
```bash
cd backend

# Instalar dependencias
composer install

# Copiar archivo de entorno
copy .env.example .env    # Windows
cp .env.example .env      # Linux/macOS

# Configurar .env con datos de SQL Server
# Editar .env y configurar:
# - DB_HOST
# - DB_DATABASE
# - DB_USERNAME
# - DB_PASSWORD
# - APP_KEY (se genera automáticamente)

# Generar clave de aplicación
php artisan key:generate

# Limpiar cache
php artisan config:clear
php artisan cache:clear
```

### Paso 4: Configurar Base de Datos
```sql
-- Ejecutar en SQL Server Management Studio
-- 1. Crear base de datos
CREATE DATABASE wms_escasan;
GO

-- 2. Ejecutar script completo
USE wms_escasan;
GO
-- Ejecutar DATABASE_COMPLETE_SCRIPT.sql

-- 3. Ejecutar migración de logs (si existe)
-- Ejecutar backend/database/migrations/create_tareas_log_table.sql
```

### Paso 5: Instalar Frontend
```bash
cd frontend

# Instalar dependencias
npm install

# Configurar variables de entorno (si es necesario)
# Crear .env.local si se necesita cambiar URL del API
```

### Paso 6: Verificar Instalación
```bash
# Backend
cd backend
php artisan serve --host=127.0.0.1 --port=8000

# Frontend (en otra terminal)
cd frontend
npm run dev
```

### Paso 7: Probar Endpoints
```bash
# Probar login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'

# Probar catálogos (requiere token)
curl http://127.0.0.1:8000/api/tareas-catalogos \
  -H "Authorization: Bearer TU_TOKEN"
```

---

## 🔍 VERIFICACIÓN DE DEPENDENCIAS

### Script de Verificación (Windows PowerShell)
```powershell
# Crear archivo: verificar_dependencias.ps1

Write-Host "Verificando dependencias..." -ForegroundColor Cyan

# PHP
Write-Host "`nPHP:" -ForegroundColor Yellow
php -v
php -m | Select-String -Pattern "sqlsrv|pdo_sqlsrv|curl|mbstring|openssl"

# Composer
Write-Host "`nComposer:" -ForegroundColor Yellow
composer --version

# Node.js
Write-Host "`nNode.js:" -ForegroundColor Yellow
node --version
npm --version

# ODBC Driver
Write-Host "`nODBC Drivers:" -ForegroundColor Yellow
odbcinst -q -d

# Verificar extensiones PHP críticas
$required = @("pdo", "pdo_sqlsrv", "sqlsrv", "curl", "mbstring", "openssl", "xml")
$installed = php -m

Write-Host "`nExtensiones requeridas:" -ForegroundColor Yellow
foreach ($ext in $required) {
    if ($installed -match $ext) {
        Write-Host "  ✅ $ext" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $ext" -ForegroundColor Red
    }
}
```

### Script de Verificación (Linux/macOS)
```bash
#!/bin/bash
# Crear archivo: verificar_dependencias.sh

echo "Verificando dependencias..."

echo -e "\nPHP:"
php -v
php -m | grep -E "sqlsrv|pdo_sqlsrv|curl|mbstring|openssl"

echo -e "\nComposer:"
composer --version

echo -e "\nNode.js:"
node --version
npm --version

echo -e "\nODBC Drivers:"
odbcinst -q -d

# Verificar extensiones
required=("pdo" "pdo_sqlsrv" "sqlsrv" "curl" "mbstring" "openssl" "xml")
installed=$(php -m)

echo -e "\nExtensiones requeridas:"
for ext in "${required[@]}"; do
    if echo "$installed" | grep -q "$ext"; then
        echo "  ✅ $ext"
    else
        echo "  ❌ $ext"
    fi
done
```

---

## 🚨 PROBLEMAS COMUNES

### Error: "Class 'PDO' not found"
**Solución:**
```bash
# Habilitar extensión en php.ini
extension=pdo
extension=pdo_sqlsrv
```

### Error: "SQLSTATE[HY000] [2002] No connection"
**Solución:**
- Verificar que SQL Server está corriendo
- Verificar credenciales en `.env`
- Verificar puerto (1433)
- Verificar firewall

### Error: "ODBC Driver 17 for SQL Server not found"
**Solución:**
- Descargar e instalar: https://aka.ms/downloadmsodbcsql
- Reiniciar servidor PHP

### Error: "npm ERR! code ELIFECYCLE"
**Solución:**
```bash
# Limpiar cache de npm
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Error: "Composer memory limit"
**Solución:**
```bash
# Aumentar límite de memoria
php -d memory_limit=512M composer install
```

### Error: "Database file at path [...] does not exist. (Connection: sqlite)"
**Causa:** Laravel está intentando usar SQLite en lugar de SQL Server porque falta o está mal configurado el archivo `.env`.

**Solución:**
```bash
# 1. Copiar archivo .env.example a .env
cd backend
copy .env.example .env    # Windows
cp .env.example .env       # Linux/macOS

# 2. Editar .env y configurar:
DB_CONNECTION=sqlsrv       # CRÍTICO: debe ser sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

SESSION_DRIVER=database     # CRÍTICO: debe ser database

# 3. Generar clave de aplicación
php artisan key:generate

# 4. Limpiar cache
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

**Verificar que funciona:**
```bash
php artisan config:show database.default
# Debe mostrar: sqlsrv
```

**⚠️ IMPORTANTE:** El archivo `.env` NO debe estar en el repositorio Git. Cada máquina debe tener su propio `.env` con las credenciales locales.

---

## 📦 RESUMEN DE DEPENDENCIAS

### Backend
- ✅ PHP 8.2+
- ✅ Composer 2.x
- ✅ Extensiones PHP (pdo_sqlsrv, sqlsrv, curl, mbstring, openssl, xml)
- ✅ ODBC Driver 17 for SQL Server
- ✅ SQL Server 2019+
- ✅ Laravel 12.0
- ✅ Laravel Sanctum 4.2

### Frontend
- ✅ Node.js 18+
- ✅ npm (incluido con Node.js)
- ✅ React 19.1
- ✅ React Router DOM 7.9
- ✅ Axios 1.12
- ✅ Vite 7.1
- ✅ TypeScript 5.9
- ✅ Tailwind CSS 3.4

### Base de Datos
- ✅ SQL Server 2019+
- ✅ Base de datos: `wms_escasan`
- ✅ Esquema: `wms` o `dbo`
- ✅ Scripts SQL de migración

---

## 📝 NOTAS IMPORTANTES

1. **Permisos:** Asegurar que PHP tiene permisos de lectura/escritura en `backend/storage` y `backend/bootstrap/cache`

2. **Variables de Entorno:** Nunca commitear el archivo `.env` al repositorio

3. **CORS:** Configurar `CORS_ALLOWED_ORIGINS` en `.env` para producción

4. **Seguridad:** Cambiar contraseñas por defecto antes de producción

5. **Puertos:** 
   - Backend: 8000 (por defecto)
   - Frontend: 5173 (Vite dev server)
   - SQL Server: 1433

---

## 🎯 INSTALACIÓN RÁPIDA (Resumen)

```bash
# 1. Instalar dependencias del sistema
# - PHP 8.2+ con extensiones
# - Composer
# - Node.js 18+
# - SQL Server + ODBC Driver 17

# 2. Clonar proyecto
git clone <repo> WMS-v9
cd WMS-v9

# 3. Backend
cd backend
composer install
copy .env.example .env
# Editar .env con datos de BD
php artisan key:generate

# 4. Base de datos
# Ejecutar DATABASE_COMPLETE_SCRIPT.sql en SQL Server

# 5. Frontend
cd ../frontend
npm install

# 6. Iniciar
# Terminal 1: php artisan serve
# Terminal 2: npm run dev
```

---

## 🚀 DESPLIEGUE EN PRODUCCIÓN

Para desplegar el sistema en un servidor de producción, consulta la guía completa:

**📖 [GUIA_DESPLIEGUE_PRODUCCION.md](./GUIA_DESPLIEGUE_PRODUCCION.md)**

Incluye:
- Configuración de servidor VPS
- Instalación de dependencias
- Despliegue de Backend y Frontend
- Configuración de Nginx
- SSL/HTTPS
- Optimizaciones
- Scripts de automatización

---

**✅ Con estas dependencias instaladas, el sistema estará listo para funcionar.**

