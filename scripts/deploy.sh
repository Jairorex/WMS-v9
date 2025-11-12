#!/bin/bash
# Script de Despliegue Automático - WMS v9
# Uso: ./deploy.sh [production|staging]

set -e

ENVIRONMENT=${1:-production}
APP_DIR="/var/www/wms"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"

echo "🚀 Iniciando despliegue en modo: $ENVIRONMENT"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -d "$BACKEND_DIR" ] || [ ! -d "$FRONTEND_DIR" ]; then
    log_error "Directorio del proyecto no encontrado: $APP_DIR"
    exit 1
fi

# Backup antes de actualizar
log_info "Creando backup..."
BACKUP_DIR="/backups/wms"
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf "$BACKUP_DIR/wms-backup-$DATE.tar.gz" "$APP_DIR" 2>/dev/null || log_warning "No se pudo crear backup"
log_info "Backup creado: wms-backup-$DATE.tar.gz"

# Actualizar código
log_info "Actualizando código desde Git..."
cd $APP_DIR
git pull origin main || log_warning "No se pudo actualizar desde Git"

# Backend
log_info "Desplegando Backend..."
cd $BACKEND_DIR

log_info "Instalando dependencias PHP..."
composer install --optimize-autoloader --no-dev --no-interaction

log_info "Ejecutando migraciones..."
php artisan migrate --force

log_info "Limpiando y optimizando cache..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

if [ "$ENVIRONMENT" = "production" ]; then
    log_info "Optimizando para producción..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan optimize
fi

log_info "Verificando permisos..."
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Frontend
log_info "Desplegando Frontend..."
cd $FRONTEND_DIR

log_info "Instalando dependencias NPM..."
npm ci --production

log_info "Construyendo aplicación..."
npm run build

# Reiniciar servicios
log_info "Reiniciando servicios..."

if systemctl is-active --quiet php8.2-fpm; then
    systemctl restart php8.2-fpm
    log_info "PHP-FPM reiniciado"
fi

if systemctl is-active --quiet nginx; then
    nginx -t && systemctl reload nginx
    log_info "Nginx recargado"
fi

if command -v supervisorctl &> /dev/null; then
    supervisorctl restart wms-worker:* || log_warning "No se pudo reiniciar workers"
fi

# Verificación
log_info "Verificando despliegue..."
if [ -f "$BACKEND_DIR/artisan" ] && [ -d "$FRONTEND_DIR/dist" ]; then
    log_info "✅ Despliegue completado exitosamente"
else
    log_error "❌ Despliegue falló - verificar logs"
    exit 1
fi

# Limpiar backups antiguos (mantener últimos 7 días)
log_info "Limpiando backups antiguos..."
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true

log_info "🎉 Proceso de despliegue finalizado"
