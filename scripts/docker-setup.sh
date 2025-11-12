#!/bin/bash

# Script de configuración inicial para Docker
# Uso: ./scripts/docker-setup.sh

set -e

echo "🐳 Configurando WMS Escasan para Docker..."
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

echo "✅ Docker y Docker Compose encontrados"
echo ""

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env desde .env.example..."
    cp .env.example .env
    echo "✅ Archivo .env creado. Por favor, edítalo con tus configuraciones."
    echo ""
else
    echo "✅ Archivo .env ya existe"
    echo ""
fi

# Generar APP_KEY si no existe
if ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    echo "🔑 Generando APP_KEY..."
    # Esto se generará cuando se levante el backend
    echo "⚠️  APP_KEY se generará automáticamente al iniciar el backend"
    echo ""
fi

# Verificar permisos
echo "📁 Verificando permisos..."
if [ -d "backend/storage" ]; then
    chmod -R 755 backend/storage 2>/dev/null || true
    chmod -R 755 backend/bootstrap/cache 2>/dev/null || true
    echo "✅ Permisos configurados"
    echo ""
fi

echo "🚀 Configuración completada!"
echo ""
echo "Próximos pasos:"
echo "1. Edita el archivo .env con tus configuraciones"
echo "2. Ejecuta: docker-compose build"
echo "3. Ejecuta: docker-compose up -d"
echo "4. Ejecuta: docker-compose exec backend php artisan migrate"
echo ""

