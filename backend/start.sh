#!/bin/sh
# Script de inicio para Railway
# Asegura que el puerto se maneje correctamente

# NO usar set -e aquí porque queremos ver todos los errores
# set -e  # Comentado para debugging

# Obtener el puerto de la variable de entorno o usar 8080 por defecto
# Convertir a entero para evitar errores de tipo en Laravel
PORT=${PORT:-8080}
PORT=$((PORT + 0))  # Forzar conversión a entero

# Log para debug
echo "=========================================="
echo "🚀 Iniciando servidor Laravel"
echo "=========================================="
echo "📌 Puerto configurado: $PORT"
echo "📌 Directorio actual: $(pwd)"
echo "📌 Usuario: $(whoami)"
echo "=========================================="

# Verificar que artisan existe
if [ ! -f "artisan" ]; then
    echo "❌ Error: archivo artisan no encontrado en $(pwd)"
    echo "📋 Archivos en el directorio:"
    ls -la
    exit 1
fi

echo "✅ Archivo artisan encontrado"

# Verificar que estamos en el directorio correcto
if [ ! -d "app" ] || [ ! -d "config" ]; then
    echo "❌ Error: No parece ser un proyecto Laravel válido"
    echo "📋 Directorios encontrados:"
    ls -la
    exit 1
fi

echo "✅ Estructura de Laravel verificada"

# Verificar extensiones PHP
echo "📋 Verificando extensiones PHP..."
php -m | grep -i sqlsrv && echo "✅ sqlsrv encontrado" || echo "⚠️ Advertencia: sqlsrv no encontrado"
php -m | grep -i pdo_sqlsrv && echo "✅ pdo_sqlsrv encontrado" || echo "⚠️ Advertencia: pdo_sqlsrv no encontrado"

# Verificar versión de PHP
echo "📋 Versión de PHP: $(php -v | head -n 1)"

# Verificar que el puerto sea válido
if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "❌ Error: Puerto inválido: $PORT"
    exit 1
fi

# Iniciar el servidor Laravel
# Usar printf para asegurar que PORT sea un número
echo "=========================================="
echo "✅ Iniciando servidor Laravel..."
echo "✅ Comando: php artisan serve --host=0.0.0.0 --port=$PORT"
echo "=========================================="

# Ejecutar el servidor (sin exec para ver errores si falla)
php artisan serve --host=0.0.0.0 --port=$(printf "%d" "$PORT")

