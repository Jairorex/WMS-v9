#!/bin/sh
# Script de inicio para Railway
# Asegura que el puerto se maneje correctamente

set -e  # Salir si hay algún error

# Obtener el puerto de la variable de entorno o usar 8080 por defecto
PORT=${PORT:-8080}

# Log para debug
echo "🚀 Iniciando servidor Laravel en puerto $PORT"

# Verificar que artisan existe
if [ ! -f "artisan" ]; then
    echo "❌ Error: archivo artisan no encontrado"
    exit 1
fi

# Verificar extensiones PHP
echo "📋 Verificando extensiones PHP..."
php -m | grep -i sqlsrv || echo "⚠️ Advertencia: sqlsrv no encontrado"
php -m | grep -i pdo_sqlsrv || echo "⚠️ Advertencia: pdo_sqlsrv no encontrado"

# Iniciar el servidor Laravel
echo "✅ Iniciando servidor..."
exec php artisan serve --host=0.0.0.0 --port=$PORT

