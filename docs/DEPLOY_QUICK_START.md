# ⚡ Despliegue Rápido - WMS v9

## 🎯 Resumen Ejecutivo

Guía rápida para desplegar WMS v9 en producción.

---

## 📋 Opciones de Hosting

### Opción 1: VPS (Recomendado para Control Total)

**Proveedores:**
- **DigitalOcean** - Desde $6/mes
- **Vultr** - Desde $2.50/mes
- **Linode** - Desde $5/mes
- **AWS EC2** - t2.micro gratuito 1 año

**Pasos:**
1. Crear cuenta y Droplet/VPS
2. Elegir Ubuntu 22.04 LTS
3. Configurar SSH Key
4. Seguir guía completa

### Opción 2: Platform as a Service (PaaS)

**Laravel Forge** (Más fácil):
1. Crear cuenta en [forge.laravel.com](https://forge.laravel.com)
2. Conectar servidor o crear nuevo
3. Forge configura todo automáticamente
4. Conectar repositorio Git
5. Configurar variables de entorno
6. ¡Listo!

**Railway** (Moderno):
1. Crear cuenta en [railway.app](https://railway.app)
2. Conectar repositorio Git
3. Railway detecta Laravel automáticamente
4. Configurar variables de entorno
5. ¡Listo!

---

## 🚀 Despliegue Manual (VPS)

### Paso 1: Configurar Servidor

```bash
# Conectar al servidor
ssh root@TU_IP_SERVIDOR

# Ejecutar script de configuración
wget https://raw.githubusercontent.com/TU_REPO/WMS-v9/main/scripts/setup-server.sh
bash setup-server.sh
```

### Paso 2: Subir Código

**Opción A: Git (Recomendado)**
```bash
cd /var/www
git clone https://github.com/TU_USUARIO/TU_REPO.git wms
cd wms
```

**Opción B: SCP/SFTP**
```bash
# Desde tu máquina local
scp -r . root@TU_IP_SERVIDOR:/var/www/wms
```

### Paso 3: Configurar Backend

```bash
cd /var/www/wms/backend

# Instalar dependencias
composer install --optimize-autoloader --no-dev

# Configurar .env
cp .env.example .env
nano .env
# Configurar: DB_*, APP_URL, etc.

# Generar clave
php artisan key:generate

# Ejecutar migraciones
php artisan migrate --force

# Optimizar
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Permisos
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

### Paso 4: Configurar Frontend

```bash
cd /var/www/wms/frontend

# Instalar dependencias
npm install

# Build para producción
npm run build
```

### Paso 5: Configurar Nginx

```bash
# Copiar configuraciones de GUIA_DESPLIEGUE_PRODUCCION.md
nano /etc/nginx/sites-available/wms-api
nano /etc/nginx/sites-available/wms-frontend

# Activar sitios
ln -s /etc/nginx/sites-available/wms-api /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/wms-frontend /etc/nginx/sites-enabled/

# Verificar y recargar
nginx -t
systemctl reload nginx
```

### Paso 6: Configurar SSL

```bash
# Instalar Certbot
apt install -y certbot python3-certbot-nginx

# Obtener certificados
certbot --nginx -d api.tudominio.com
certbot --nginx -d tudominio.com
```

---

## 🔄 Actualización Automática

```bash
# Usar script de despliegue
cd /var/www/wms
bash scripts/deploy.sh production
```

---

## 📝 Checklist Rápido

- [ ] Servidor VPS creado (Ubuntu 22.04)
- [ ] Script de configuración ejecutado
- [ ] Código subido al servidor
- [ ] `.env` configurado con datos reales
- [ ] `APP_KEY` generado
- [ ] Migraciones ejecutadas
- [ ] Frontend build ejecutado (`npm run build`)
- [ ] Nginx configurado
- [ ] SSL configurado
- [ ] DNS apuntando al servidor
- [ ] Firewall configurado
- [ ] Backup automático configurado

---

## 🔗 URLs de Referencia

- **Guía Completa:** [GUIA_DESPLIEGUE_PRODUCCION.md](./GUIA_DESPLIEGUE_PRODUCCION.md)
- **Requisitos:** [REQUISITOS_INSTALACION.md](./REQUISITOS_INSTALACION.md)
- **Config API Móvil:** [API_MOBILE_CONFIG.md](./API_MOBILE_CONFIG.md)

---

## 🆘 Ayuda Rápida

### Error 500
```bash
tail -f /var/www/wms/backend/storage/logs/laravel.log
php artisan config:clear
```

### Frontend no carga
```bash
ls -la /var/www/wms/frontend/dist
nginx -t
```

### Base de datos no conecta
```bash
php artisan tinker
DB::connection()->getPdo();
```

---

**✅ Ver guía completa para más detalles: [GUIA_DESPLIEGUE_PRODUCCION.md](./GUIA_DESPLIEGUE_PRODUCCION.md)**

