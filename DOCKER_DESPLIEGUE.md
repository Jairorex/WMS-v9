# 🐳 Guía de Despliegue con Docker - WMS Escasan

## 📋 Tabla de Contenidos

1. [Requisitos](#requisitos)
2. [Instalación Rápida](#instalación-rápida)
3. [Configuración](#configuración)
4. [Despliegue](#despliegue)
5. [Uso](#uso)
6. [Troubleshooting](#troubleshooting)
7. [Producción](#producción)

---

## 📦 Requisitos

### Software Necesario

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Git** (para clonar el repositorio)

### Verificar Instalación

```bash
docker --version
docker-compose --version
```

---

## 🚀 Instalación Rápida

### 1. Clonar Repositorio

```bash
git clone <tu-repositorio>
cd WMS-v9
```

### 2. Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env con tus configuraciones
nano .env  # o usar tu editor preferido
```

### 3. Configurar Variables Importantes

**Editar `.env`:**

```env
# Base de Datos
DB_PASSWORD=TuPasswordSeguro123!
DB_DATABASE=wms

# Aplicación
APP_KEY=  # Se generará automáticamente
APP_URL=http://localhost

# Frontend API URL (importante para CORS)
VITE_API_URL=http://localhost/api
```

### 4. Construir y Levantar Servicios

```bash
# Construir imágenes
docker-compose build

# Levantar servicios
docker-compose up -d
```

### 5. Configurar Base de Datos

```bash
# Entrar al contenedor del backend
docker-compose exec backend bash

# Dentro del contenedor:
php artisan key:generate
php artisan migrate --force
php artisan db:seed  # Si tienes seeders
```

### 6. Verificar Estado

```bash
# Ver logs
docker-compose logs -f

# Ver estado de servicios
docker-compose ps
```

---

## ⚙️ Configuración

### Servicios Incluidos

1. **SQL Server** (puerto 1433)
   - Base de datos principal
   - Datos persistentes en volumen `sqlserver_data`

2. **Backend Laravel** (puerto 8000)
   - API REST
   - PHP-FPM con drivers SQL Server
   - Volúmenes: código fuente y storage

3. **Frontend React** (puerto 80 a través de Nginx)
   - Aplicación React construida con Vite
   - Servido por Nginx

4. **Nginx** (puerto 80)
   - Reverse proxy
   - Enruta `/api` al backend
   - Enruta `/` al frontend
   - Maneja CORS

### Variables de Entorno

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `APP_NAME` | Nombre de la aplicación | `WMS` |
| `APP_ENV` | Entorno (production/development) | `production` |
| `APP_KEY` | Clave de Laravel | (generado automáticamente) |
| `APP_DEBUG` | Modo debug | `false` |
| `APP_URL` | URL de la aplicación | `http://localhost` |
| `DB_HOST` | Host de SQL Server | `sqlserver` |
| `DB_PORT` | Puerto de SQL Server | `1433` |
| `DB_DATABASE` | Nombre de la base de datos | `wms` |
| `DB_USERNAME` | Usuario de SQL Server | `sa` |
| `DB_PASSWORD` | Contraseña de SQL Server | `WMS_StrongP@ssw0rd!` |
| `CORS_ALLOWED_ORIGINS` | Orígenes permitidos para CORS | `http://localhost,http://localhost:3000,http://localhost:5173` |
| `VITE_API_URL` | URL de la API para el frontend | `http://localhost/api` |
| `BACKEND_PORT` | Puerto del backend (host) | `8000` |
| `NGINX_PORT` | Puerto de Nginx (host) | `80` |

---

## 🚀 Despliegue

### Desarrollo

```bash
# Levantar servicios
docker-compose up

# Ver logs en tiempo real
docker-compose logs -f

# Reconstruir después de cambios
docker-compose up --build
```

### Producción

```bash
# 1. Configurar .env para producción
APP_ENV=production
APP_DEBUG=false
APP_URL=https://tu-dominio.com
VITE_API_URL=https://tu-dominio.com/api

# 2. Construir imágenes optimizadas
docker-compose -f docker-compose.yml build --no-cache

# 3. Levantar servicios
docker-compose up -d

# 4. Configurar base de datos
docker-compose exec backend php artisan migrate --force
```

---

## 📱 Uso

### Acceder a la Aplicación

- **Frontend:** http://localhost
- **API Backend:** http://localhost/api
- **API Directa:** http://localhost:8000/api

### Comandos Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f sqlserver

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ elimina datos)
docker-compose down -v

# Reiniciar un servicio
docker-compose restart backend

# Ejecutar comandos en el backend
docker-compose exec backend php artisan migrate
docker-compose exec backend php artisan tinker
docker-compose exec backend composer install

# Ejecutar comandos en SQL Server
docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "TuPassword" -Q "SELECT @@VERSION"

# Acceder a shell del backend
docker-compose exec backend bash

# Ver estado de servicios
docker-compose ps

# Reconstruir un servicio específico
docker-compose build backend
docker-compose up -d backend
```

---

## 🔧 Troubleshooting

### Error: Puerto ya en uso

```bash
# Cambiar puertos en .env
NGINX_PORT=8080
BACKEND_PORT=8001
```

### Error: No se puede conectar a SQL Server

```bash
# Verificar que SQL Server esté corriendo
docker-compose ps sqlserver

# Ver logs de SQL Server
docker-compose logs sqlserver

# Verificar conexión desde el backend
docker-compose exec backend php -r "
  try {
    \$pdo = new PDO('sqlsrv:Server=sqlserver,1433;Database=wms', 'sa', 'TuPassword');
    echo '✅ Conexión exitosa';
  } catch (Exception \$e) {
    echo '❌ Error: ' . \$e->getMessage();
  }
"
```

### Error: CORS en el frontend

1. Verificar `VITE_API_URL` en `.env`
2. Verificar `CORS_ALLOWED_ORIGINS` en `.env`
3. Reiniciar servicios:
   ```bash
   docker-compose restart backend nginx
   ```

### Error: Permisos en storage

```bash
docker-compose exec backend chown -R www-data:www-data storage bootstrap/cache
docker-compose exec backend chmod -R 755 storage bootstrap/cache
```

### Limpiar Todo y Empezar de Nuevo

```bash
# Detener y eliminar contenedores
docker-compose down

# Eliminar volúmenes (⚠️ elimina datos)
docker-compose down -v

# Eliminar imágenes
docker-compose down --rmi all

# Reconstruir desde cero
docker-compose build --no-cache
docker-compose up -d
```

### Ver Logs de Errores

```bash
# Logs del backend
docker-compose exec backend tail -f storage/logs/laravel.log

# Logs de Nginx
docker-compose exec nginx tail -f /var/log/nginx/error.log
```

---

## 🏭 Producción

### Configuración Recomendada

1. **Variables de Entorno:**
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://tu-dominio.com
   VITE_API_URL=https://tu-dominio.com/api
   ```

2. **SSL/HTTPS:**
   - Usar un proxy inverso (Nginx/Traefik) con certificados SSL
   - O configurar Let's Encrypt con Certbot

3. **Backups:**
   ```bash
   # Backup de base de datos
   docker-compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
     -S localhost -U sa -P "TuPassword" \
     -Q "BACKUP DATABASE wms TO DISK='/var/opt/mssql/backup/wms.bak'"
   ```

4. **Monitoreo:**
   - Usar `docker stats` para monitorear recursos
   - Configurar logs rotativos
   - Implementar health checks

### Optimizaciones

```bash
# Optimizar Laravel para producción
docker-compose exec backend php artisan config:cache
docker-compose exec backend php artisan route:cache
docker-compose exec backend php artisan view:cache
```

### Escalabilidad

Para escalar horizontalmente:

```bash
# Escalar backend (ejemplo: 3 instancias)
docker-compose up -d --scale backend=3
```

**Nota:** Asegúrate de usar un servicio de sesión compartido (Redis/Database) cuando escales.

---

## 📚 Estructura de Archivos Docker

```
WMS-v9/
├── docker-compose.yml          # Orquestación de servicios
├── .env.example                # Variables de entorno de ejemplo
├── backend/
│   ├── Dockerfile             # Imagen del backend
│   ├── docker-entrypoint.sh   # Script de inicio
│   └── .dockerignore          # Archivos a ignorar
├── frontend/
│   ├── Dockerfile             # Imagen del frontend
│   ├── nginx.conf             # Configuración Nginx del frontend
│   └── .dockerignore          # Archivos a ignorar
└── nginx/
    ├── nginx.conf             # Configuración principal
    └── conf.d/
        └── default.conf      # Configuración del servidor virtual
```

---

## 🔐 Seguridad

### Recomendaciones

1. **Cambiar contraseñas por defecto:**
   ```env
   DB_PASSWORD=TuPasswordSeguro123!
   ```

2. **No exponer SQL Server externamente:**
   - SQL Server solo debe ser accesible desde la red Docker
   - No mapear el puerto 1433 al host en producción

3. **Usar secrets en producción:**
   ```bash
   # Crear archivo de secrets
   echo "TuPasswordSeguro" | docker secret create db_password -
   ```

4. **Configurar firewall:**
   - Solo exponer puertos necesarios (80, 443)
   - Bloquear acceso directo a puertos internos

---

## ✅ Checklist de Despliegue

- [ ] Docker y Docker Compose instalados
- [ ] Archivo `.env` configurado
- [ ] Contraseñas cambiadas
- [ ] Imágenes construidas (`docker-compose build`)
- [ ] Servicios levantados (`docker-compose up -d`)
- [ ] Base de datos migrada (`docker-compose exec backend php artisan migrate`)
- [ ] Verificar que todos los servicios estén corriendo (`docker-compose ps`)
- [ ] Probar acceso al frontend (http://localhost)
- [ ] Probar API (http://localhost/api)
- [ ] Verificar logs sin errores (`docker-compose logs`)

---

## 🆘 Soporte

Si encuentras problemas:

1. Revisar logs: `docker-compose logs -f`
2. Verificar estado: `docker-compose ps`
3. Verificar configuración: `cat .env`
4. Revisar documentación de troubleshooting arriba

---

**✅ ¡Despliegue completado! Tu aplicación WMS está corriendo en Docker.**

