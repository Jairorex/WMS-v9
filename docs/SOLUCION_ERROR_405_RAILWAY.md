# Solución Error 405 en Railway - API Login

## Problema
Error 405 (Method Not Allowed) al intentar hacer login en Railway:
```
wms-v9-production.up.railway.app/api/auth/login:1  Failed to load resource: the server responded with a status of 405 ()
```

## Posibles Causas

### 1. Prefijo `/api` duplicado
Laravel 11 automáticamente agrega el prefijo `/api` a todas las rutas en `routes/api.php`. Si el frontend está llamando a `/api/auth/login` y el `baseURL` ya incluye el dominio, la URL final sería correcta. Pero si hay alguna configuración incorrecta, podría estar duplicando el prefijo.

### 2. Configuración de Railway
Railway podría estar bloqueando las peticiones POST o redirigiendo incorrectamente.

### 3. Variables de Entorno
Las variables de entorno en Railway podrían no estar configuradas correctamente.

## Soluciones

### Solución 1: Verificar Variables de Entorno en Railway

Asegúrate de que en Railway tengas configuradas las siguientes variables:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... (generar con php artisan key:generate)
APP_URL=https://wms-v9-production.up.railway.app

DB_CONNECTION=sqlsrv
DB_HOST=tu-servidor-azure.database.windows.net
DB_DATABASE=wms
DB_USERNAME=tu-usuario
DB_PASSWORD=tu-password
DB_PORT=1433

CORS_ALLOWED_ORIGINS=https://tu-frontend.vercel.app,https://tu-frontend.vercel.app
SESSION_DRIVER=database
SESSION_LIFETIME=120

SANCTUM_STATEFUL_DOMAINS=tu-frontend.vercel.app
```

### Solución 2: Verificar que el Frontend use la URL Correcta

En Vercel, configura la variable de entorno:
```
VITE_API_URL=https://wms-v9-production.up.railway.app
```

**IMPORTANTE**: No incluyas `/api` al final de `VITE_API_URL` porque el frontend ya lo agrega en las llamadas.

### Solución 3: Verificar Rutas en Laravel

Las rutas están correctamente definidas en `backend/routes/api.php`:
```php
Route::post('/auth/login', [AuthController::class, 'login']);
```

Laravel automáticamente agrega el prefijo `/api`, por lo que la ruta final es `/api/auth/login`.

### Solución 4: Verificar Logs de Railway

1. Ve a tu proyecto en Railway
2. Abre la pestaña "Deployments"
3. Haz clic en el deployment más reciente
4. Revisa los logs para ver si hay errores específicos

### Solución 5: Probar la Ruta Directamente

Prueba hacer una petición POST directamente a la API usando curl o Postman:

```bash
curl -X POST https://wms-v9-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"usuario":"tu-usuario","password":"tu-password"}'
```

### Solución 6: Verificar Middleware CORS

El middleware CORS está configurado en `backend/app/Http/Middleware/CorsMiddleware.php`. Asegúrate de que:

1. El origen del frontend esté en `CORS_ALLOWED_ORIGINS`
2. Los métodos HTTP permitidos incluyan `POST`
3. Los headers permitidos incluyan `Content-Type` y `Authorization`

### Solución 7: Limpiar Caché de Laravel en Railway

Si has hecho cambios recientes, puede ser necesario limpiar el caché. En Railway, puedes ejecutar:

```bash
php artisan route:clear
php artisan config:clear
php artisan cache:clear
```

O agregar estos comandos al script de inicio en Railway.

## Verificación Final

1. **Verificar que la ruta existe**:
   ```bash
   php artisan route:list | grep login
   ```
   Deberías ver: `POST api/auth/login`

2. **Verificar que el servidor responde**:
   ```bash
   curl -I https://wms-v9-production.up.railway.app/up
   ```
   Debería responder con 200 OK.

3. **Verificar CORS**:
   Abre la consola del navegador y verifica que no haya errores de CORS.

## Si el Problema Persiste

1. Verifica los logs de Railway para ver el error exacto
2. Prueba hacer una petición GET a una ruta pública (ej: `/api/roles`) para verificar que la API funciona
3. Verifica que el dominio de Railway esté correctamente configurado
4. Asegúrate de que Railway esté usando PHP 8.2+ y todas las extensiones necesarias

