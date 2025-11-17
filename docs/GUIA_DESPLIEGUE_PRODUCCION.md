# 🚀 Guía de Despliegue en Producción - WMS v9

## 📋 Tabla de Contenidos

1. [Opciones de Hosting](#opciones-de-hosting)
2. [Configuración del Servidor](#configuración-del-servidor)
3. [Despliegue del Backend (Laravel)](#despliegue-del-backend-laravel)
4. [Despliegue del Frontend (React)](#despliegue-del-frontend-react)
5. [Configuración de Base de Datos](#configuración-de-base-de-datos)
6. [Configuración de Web Server](#configuración-de-web-server)
7. [SSL/HTTPS](#sslhttps)
8. [Optimizaciones](#optimizaciones)
9. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)

---

## 🌐 Opciones de Hosting

### 1. VPS (Virtual Private Server)

**Recomendados:**
- **DigitalOcean** (desde $6/mes)
- **Linode** (desde $5/mes)
- **Vultr** (desde $2.50/mes)
- **AWS EC2** (t2.micro gratuito 1 año)
- **Azure VM** (gratuito 1 año)
- **Google Cloud Platform** (gratuito con créditos)

**Ventajas:**
- Control total
- Acceso SSH
- Configuración personalizada
- Escalable

### 2. Cloud Platforms (PaaS)

**Recomendados:**
- **Laravel Forge** (gestión automática de Laravel)
- **Heroku** (fácil despliegue)
- **Railway** (moderno y simple)
- **Render** (gratuito para empezar)

**Ventajas:**
- Gestión automática
- Despliegue simplificado
- Escalado automático

### 3. Servidor Dedicado

**Para:**
- Alto tráfico
- Requisitos específicos
- Control total

---

## 🖥️ Configuración del Servidor

### Requisitos Mínimos

- **CPU:** 2 cores
- **RAM:** 4GB (mínimo 2GB)
- **Disco:** 20GB SSD
- **SO:** Ubuntu 22.04 LTS (recomendado)

### Paso 1: Crear Servidor VPS

**Ejemplo con DigitalOcean:**

1. Crear cuenta en [DigitalOcean](https://www.digitalocean.com)
2. Crear Droplet:
   - **Ubuntu 22.04 LTS**
   - **2GB RAM / 1 vCPU** (mínimo)
   - **Región:** Más cercana a tus usuarios
   - **Authentication:** SSH Key (recomendado)

### Paso 2: Conectar al Servidor

```bash
ssh root@TU_IP_SERVIDOR
```

### Paso 3: Configuración Inicial del Servidor

```bash
# Actualizar sistema
apt update && apt upgrade -y

# Instalar herramientas básicas
apt install -y curl wget git unzip software-properties-common

# Crear usuario no-root
adduser wmsuser
usermod -aG sudo wmsuser

# Configurar SSH (opcional pero recomendado)
nano /etc/ssh/sshd_config
# Cambiar: PermitRootLogin no
# Cambiar: PasswordAuthentication no
systemctl restart sshd
```

---

## 🔧 Instalación de Dependencias

### 1. PHP 8.2+

```bash
# Agregar repositorio PHP
add-apt-repository ppa:ondrej/php -y
apt update

# Instalar PHP y extensiones
apt install -y php8.2 php8.2-cli php8.2-fpm php8.2-common \
    php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring \
    php8.2-curl php8.2-xml php8.2-bcmath php8.2-pdo \
    php8.2-sqlite3

# Instalar drivers SQL Server para Linux
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
apt update
ACCEPT_EULA=Y apt install -y msodbcsql17 unixodbc-dev
pecl install sqlsrv pdo_sqlsrv

# Habilitar extensiones
echo "extension=sqlsrv.so" >> /etc/php/8.2/fpm/php.ini
echo "extension=pdo_sqlsrv.so" >> /etc/php/8.2/fpm/php.ini
echo "extension=sqlsrv.so" >> /etc/php/8.2/cli/php.ini
echo "extension=pdo_sqlsrv.so" >> /etc/php/8.2/cli/php.ini

# Reiniciar PHP-FPM
systemctl restart php8.2-fpm
```

### 2. Composer

```bash
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
```

### 3. Node.js 18+

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
```

### 4. Nginx

```bash
apt install -y nginx
systemctl start nginx
systemctl enable nginx
```

### 5. SQL Server (si es necesario)

**Opción 1: SQL Server en Azure**
- Usar Azure SQL Database (recomendado para producción)

**Opción 2: SQL Server en el mismo servidor**
```bash
# Instalar SQL Server Express (si es necesario)
# Seguir guía oficial de Microsoft
```

**Opción 3: SQL Server en servidor separado**
- Configurar conexión remota

---

## 📦 Despliegue del Backend (Laravel)

### Paso 1: Crear Directorio

```bash
mkdir -p /var/www/wms
cd /var/www/wms
chown -R wmsuser:wmsuser /var/www/wms
```

### Paso 2: Clonar Repositorio

```bash
su - wmsuser
cd /var/www/wms
git clone https://github.com/TU_USUARIO/TU_REPO.git .
# O subir archivos vía SCP/SFTP
```

### Paso 3: Instalar Dependencias

```bash
cd /var/www/wms/backend
composer install --optimize-autoloader --no-dev
```

### Paso 4: Configurar Variables de Entorno

```bash
cp .env.example .env
nano .env
```

**Configuración de `.env` para producción:**

```env
APP_NAME="WMS ESCASAN"
APP_ENV=production
APP_KEY=base64:... # Generar con: php artisan key:generate
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=https://api.tudominio.com
APP_LOCALE=es

# Base de Datos
DB_CONNECTION=sqlsrv
DB_HOST=tu-servidor-sql.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password_seguro

# Sesiones
SESSION_DRIVER=database
SESSION_LIFETIME=120

# Cache
CACHE_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Queue
QUEUE_CONNECTION=redis

# CORS
CORS_ALLOWED_ORIGINS=https://tudominio.com,https://www.tudominio.com

# Sanctum
SANCTUM_STATEFUL_DOMAINS=tudominio.com,www.tudominio.com

# Logging
LOG_CHANNEL=stack
LOG_LEVEL=error
```

### Paso 5: Generar Clave y Optimizar

```bash
php artisan key:generate
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

### Paso 6: Configurar Permisos

```bash
cd /var/www/wms/backend
chmod -R 775 storage bootstrap/cache
chown -R www-data:wmsuser storage bootstrap/cache
```

### Paso 7: Configurar Supervisor (para Queue Workers)

```bash
apt install -y supervisor
nano /etc/supervisor/conf.d/wms-worker.conf
```

**Contenido:**

```ini
[program:wms-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/wms/backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=wmsuser
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/wms/backend/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
supervisorctl reread
supervisorctl update
supervisorctl start wms-worker:*
```

---

## 🎨 Despliegue del Frontend (React)

### Opción 1: Build Estático (Nginx)

```bash
cd /var/www/wms/frontend
npm install
npm run build

# El build se crea en frontend/dist
```

### Opción 2: Servidor Node.js (PM2)

```bash
# Instalar PM2
npm install -g pm2

# Crear archivo ecosystem.config.js
nano /var/www/wms/frontend/ecosystem.config.js
```

**Contenido:**

```javascript
module.exports = {
  apps: [{
    name: 'wms-frontend',
    script: 'node_modules/vite/bin/vite.js',
    args: 'preview --host 0.0.0.0 --port 5173',
    env: {
      NODE_ENV: 'production',
      VITE_API_URL: 'https://api.tudominio.com'
    }
  }]
};
```

```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

---

## 🔌 Configuración de Nginx

### Backend (API)

```bash
nano /etc/nginx/sites-available/wms-api
```

**Configuración:**

```nginx
server {
    listen 80;
    server_name api.tudominio.com;
    
    # Redirigir a HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.tudominio.com;
    root /var/www/wms/backend/public;

    # SSL Configuration (ver sección SSL)
    ssl_certificate /etc/letsencrypt/live/api.tudominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.tudominio.com/privkey.pem;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Logs
    access_log /var/log/nginx/wms-api-access.log;
    error_log /var/log/nginx/wms-api-error.log;
}
```

### Frontend (React)

```bash
nano /etc/nginx/sites-available/wms-frontend
```

**Configuración:**

```nginx
server {
    listen 80;
    server_name tudominio.com www.tudominio.com;
    
    # Redirigir a HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tudominio.com www.tudominio.com;
    root /var/www/wms/frontend/dist;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/tudominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tudominio.com/privkey.pem;

    index index.html;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache estático
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API Proxy (opcional)
    location /api {
        proxy_pass https://api.tudominio.com;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/wms-frontend-access.log;
    error_log /var/log/nginx/wms-frontend-error.log;
}
```

### Activar Sitios

```bash
ln -s /etc/nginx/sites-available/wms-api /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/wms-frontend /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

---

## 🔒 SSL/HTTPS

### Opción 1: Let's Encrypt (Gratuito)

```bash
apt install -y certbot python3-certbot-nginx

# Para API
certbot --nginx -d api.tudominio.com

# Para Frontend
certbot --nginx -d tudominio.com -d www.tudominio.com

# Renovación automática
certbot renew --dry-run
```

### Opción 2: Cloudflare (Gratuito)

1. Crear cuenta en [Cloudflare](https://cloudflare.com)
2. Agregar dominio
3. Cambiar DNS nameservers
4. Activar SSL/TLS automático

---

## 🗄️ Configuración de Base de Datos

### Opción 1: Azure SQL Database (Recomendado)

1. Crear Azure SQL Database en [Azure Portal](https://portal.azure.com)
2. Configurar firewall rules
3. Obtener connection string
4. Actualizar `.env`:

```env
DB_HOST=tu-servidor.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario@tu-servidor
DB_PASSWORD=tu_password
```

### Opción 2: SQL Server en Servidor Dedicado

```bash
# Instalar SQL Server (si es necesario)
# Configurar firewall para permitir conexiones remotas
```

### Paso 3: Ejecutar Migraciones

```bash
cd /var/www/wms/backend
php artisan migrate --force
```

---

## ⚡ Optimizaciones

### Laravel

```bash
# Cache de configuración
php artisan config:cache

# Cache de rutas
php artisan route:cache

# Cache de vistas
php artisan view:cache

# Optimizar autoloader
composer install --optimize-autoloader --no-dev
```

### Nginx

```nginx
# En /etc/nginx/nginx.conf
worker_processes auto;
worker_connections 1024;

# Gzip
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

### PHP-FPM

```bash
nano /etc/php/8.2/fpm/pool.d/www.conf
```

```
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500
```

```bash
systemctl restart php8.2-fpm
```

---

## 📊 Monitoreo y Mantenimiento

### Logs

```bash
# Laravel logs
tail -f /var/www/wms/backend/storage/logs/laravel.log

# Nginx logs
tail -f /var/log/nginx/wms-api-error.log

# PHP-FPM logs
tail -f /var/log/php8.2-fpm.log
```

### Backup Automático

```bash
# Crear script de backup
nano /usr/local/bin/backup-wms.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/wms"
mkdir -p $BACKUP_DIR

# Backup de base de datos (si es local)
# sqlcmd -S localhost -d wms_escasan -i backup.sql

# Backup de archivos
tar -czf $BACKUP_DIR/wms-backup-$DATE.tar.gz /var/www/wms

# Limpiar backups antiguos (mantener últimos 7 días)
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

```bash
chmod +x /usr/local/bin/backup-wms.sh

# Agregar a crontab (backup diario a las 2 AM)
crontab -e
# Agregar: 0 2 * * * /usr/local/bin/backup-wms.sh
```

### Monitoreo de Uptime

- **UptimeRobot** (gratuito)
- **Pingdom**
- **StatusCake**

---

## 🔄 Actualización del Sistema

### Script de Actualización

```bash
nano /usr/local/bin/update-wms.sh
```

```bash
#!/bin/bash
cd /var/www/wms

# Backup antes de actualizar
/usr/local/bin/backup-wms.sh

# Pull cambios
git pull origin main

# Backend
cd backend
composer install --optimize-autoloader --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Frontend
cd ../frontend
npm install
npm run build

# Reiniciar servicios
systemctl restart php8.2-fpm
systemctl reload nginx
supervisorctl restart wms-worker:*

echo "Actualización completada"
```

```bash
chmod +x /usr/local/bin/update-wms.sh
```

---

## ✅ Checklist de Despliegue

- [ ] Servidor VPS creado y configurado
- [ ] PHP 8.2+ instalado con extensiones
- [ ] Composer instalado
- [ ] Node.js 18+ instalado
- [ ] Nginx instalado y configurado
- [ ] Repositorio clonado
- [ ] Dependencias instaladas (composer install, npm install)
- [ ] Archivo `.env` configurado para producción
- [ ] `APP_KEY` generado
- [ ] Permisos de storage/configurados
- [ ] Migraciones ejecutadas
- [ ] Cache optimizado (config, route, view)
- [ ] SSL/HTTPS configurado
- [ ] Nginx configurado para API y Frontend
- [ ] Supervisor configurado para Queue Workers
- [ ] Backup automático configurado
- [ ] Monitoreo configurado
- [ ] DNS configurado
- [ ] Firewall configurado
- [ ] Tests de endpoints realizados

---

## 🚨 Troubleshooting

### Error 500 en Laravel

```bash
# Ver logs
tail -f /var/www/wms/backend/storage/logs/laravel.log

# Verificar permisos
chmod -R 775 storage bootstrap/cache
chown -R www-data:wmsuser storage bootstrap/cache

# Limpiar cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### Error de conexión a base de datos

```bash
# Verificar conexión
php artisan tinker
DB::connection()->getPdo();

# Verificar firewall de SQL Server
# Verificar credenciales en .env
```

### Frontend no carga

```bash
# Verificar build
ls -la /var/www/wms/frontend/dist

# Verificar Nginx
nginx -t
systemctl status nginx

# Ver logs
tail -f /var/log/nginx/wms-frontend-error.log
```

---

## 📝 Notas Finales

1. **Seguridad:**
   - Cambiar contraseñas por defecto
   - Usar SSH keys en lugar de passwords
   - Mantener sistema actualizado
   - Configurar firewall (ufw)

2. **Rendimiento:**
   - Usar Redis para cache
   - Configurar CDN para assets estáticos
   - Optimizar imágenes

3. **Escalabilidad:**
   - Considerar load balancer
   - Usar base de datos separada
   - Implementar cache distribuido

---

**✅ Con esta guía, tu sistema WMS estará funcionando en producción.**
