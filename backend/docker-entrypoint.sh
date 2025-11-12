#!/bin/bash
set -e

echo "🚀 Iniciando Laravel Backend..."

# Esperar a que la base de datos esté lista
if [ -n "$DB_HOST" ]; then
    echo "⏳ Esperando conexión a la base de datos..."
    MAX_ATTEMPTS=30
    ATTEMPT=0
    until php -r "try { \$pdo = new PDO('sqlsrv:Server=${DB_HOST},${DB_PORT};Database=master', '${DB_USERNAME}', '${DB_PASSWORD}', [PDO::ATTR_TIMEOUT => 5]); echo '✅ Base de datos conectada'; exit(0); } catch (Exception \$e) { exit(1); }" 2>/dev/null; do
        ATTEMPT=$((ATTEMPT + 1))
        if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
            echo "❌ No se pudo conectar a la base de datos después de $MAX_ATTEMPTS intentos"
            exit 1
        fi
        echo "⏳ Esperando base de datos... (intento $ATTEMPT/$MAX_ATTEMPTS)"
        sleep 2
    done
fi

# Verificar que el archivo .env existe (debe ser montado o creado)
if [ ! -f .env ]; then
    echo "⚠️  Archivo .env no encontrado. Asegúrate de configurarlo."
    echo "📝 Creando archivo .env desde ejemplo..."
    cp .env.example .env 2>/dev/null || echo "⚠️  No se encontró .env.example"
fi

# Generar clave de aplicación si no existe
if grep -q "APP_KEY=$" .env 2>/dev/null || ! grep -q "APP_KEY=" .env 2>/dev/null; then
    echo "🔑 Generando clave de aplicación..."
    php artisan key:generate --force || true
fi

# Configurar permisos
echo "📁 Configurando permisos..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

# Limpiar caché
echo "🧹 Limpiando caché..."
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Optimizar para producción
if [ "$APP_ENV" = "production" ]; then
    echo "⚡ Optimizando para producción..."
    php artisan config:cache || true
    php artisan route:cache || true
    php artisan view:cache || true
    php artisan optimize || true
else
    echo "🔧 Modo desarrollo - caché deshabilitado"
fi

echo "✅ Laravel Backend listo!"
exec "$@"

