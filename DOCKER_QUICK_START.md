# 🚀 Inicio Rápido con Docker

## Instalación en 5 Pasos

### 1. Copiar configuración
```bash
cp .env.example .env
```

### 2. Editar .env (opcional)
```env
DB_PASSWORD=TuPasswordSeguro123!
VITE_API_URL=http://localhost/api
```

### 3. Construir imágenes
```bash
docker-compose build
```

### 4. Levantar servicios
```bash
docker-compose up -d
```

### 5. Configurar base de datos
```bash
docker-compose exec backend php artisan migrate --force
```

## Acceso

- **Frontend:** http://localhost
- **API:** http://localhost/api

## Comandos Útiles

```bash
# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Reiniciar
docker-compose restart

# Ver estado
docker-compose ps
```

## Desarrollo

```bash
# Usar docker-compose.dev.yml para hot reload
docker-compose -f docker-compose.dev.yml up
```

## Más Información

Ver `DOCKER_DESPLIEGUE.md` para documentación completa.

