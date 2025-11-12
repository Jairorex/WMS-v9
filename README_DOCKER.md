# 🐳 WMS Escasan - Despliegue con Docker

Sistema de gestión de almacenes (WMS) desplegado con Docker.

## 📋 Requisitos Previos

- Docker >= 20.10
- Docker Compose >= 2.0
- 4GB RAM mínimo
- 10GB espacio en disco

## 🚀 Inicio Rápido

```bash
# 1. Clonar repositorio
git clone <tu-repositorio>
cd WMS-v9

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus configuraciones

# 3. Construir y levantar servicios
docker-compose build
docker-compose up -d

# 4. Configurar base de datos
docker-compose exec backend php artisan migrate --force

# 5. Acceder a la aplicación
# Frontend: http://localhost
# API: http://localhost/api
```

## 📁 Estructura

```
WMS-v9/
├── docker-compose.yml          # Configuración de servicios
├── docker-compose.dev.yml      # Configuración para desarrollo
├── .env.example                # Variables de entorno de ejemplo
├── backend/
│   ├── Dockerfile              # Imagen del backend Laravel
│   └── docker-entrypoint.sh    # Script de inicio
├── frontend/
│   ├── Dockerfile              # Imagen del frontend (producción)
│   └── Dockerfile.dev          # Imagen del frontend (desarrollo)
└── nginx/
    ├── nginx.conf              # Configuración principal
    └── conf.d/
        └── default.conf        # Configuración del servidor virtual
```

## 🔧 Servicios

- **SQL Server**: Base de datos (puerto 1433)
- **Backend**: API Laravel (puerto 8000)
- **Frontend**: Aplicación React (puerto 80)
- **Nginx**: Reverse proxy (puerto 80)

## 📚 Documentación

- **DOCKER_QUICK_START.md**: Guía rápida de inicio
- **DOCKER_DESPLIEGUE.md**: Documentación completa de despliegue

## 🆘 Soporte

Para problemas, revisa los logs:
```bash
docker-compose logs -f
```

