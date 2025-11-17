#!/bin/sh
# Script de inicio para Railway
# Asegura que el puerto se maneje correctamente

# Obtener el puerto de la variable de entorno o usar 8080 por defecto
PORT=${PORT:-8080}

# Iniciar el servidor Laravel
php artisan serve --host=0.0.0.0 --port=$PORT

