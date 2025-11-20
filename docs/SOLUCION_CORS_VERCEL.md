# 🔧 Solución: Error CORS con Vercel

## ❌ Error

```
Access to XMLHttpRequest at 'https://wms-v9-production.up.railway.app/sanctum/csrf-cookie' 
from origin 'https://wms-v9-1g9f3et3d-jairo-narvaezs-projects-d7125f82.vercel.app' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## 🔍 Causa

El middleware CORS no estaba detectando correctamente los dominios de preview de Vercel (que incluyen hashes en el subdominio). Además, la verificación de Vercel estaba después de otras verificaciones, lo que podía causar que no se aplicara correctamente.

## ✅ Solución Implementada

### 1. Reordenar la Lógica del Middleware CORS

He actualizado `backend/app/Http/Middleware/CorsMiddleware.php` para:

1. **Verificar dominios de Vercel PRIMERO** - Antes de cualquier otra verificación
2. **Siempre establecer headers CORS** - Incluso si no hay origen permitido
3. **Manejar mejor los casos sin origen** - Para evitar headers faltantes

### 2. Mejorar la Ruta `/sanctum/csrf-cookie`

He actualizado `backend/routes/web.php` para asegurar que la ruta `/sanctum/csrf-cookie` siempre establezca headers CORS, incluso si el middleware no los aplica correctamente.

### Cambios Clave:

```php
// ANTES: Verificación de Vercel después de otras verificaciones
// AHORA: Verificación de Vercel PRIMERO
if (preg_match('/^https:\/\/.*\.vercel\.app$/', $origin)) {
    return $origin; // Devolver el origen específico de Vercel
}
```

## 🚀 Próximos Pasos

### 1. Railway Debería Redesplegar Automáticamente

Railway debería:
- Detectar el cambio en el middleware
- Redesplegar automáticamente
- El servidor debería iniciar correctamente

### 2. Verificar el Build

1. Ve a Railway Dashboard → Deployments
2. Deberías ver un nuevo deployment en progreso
3. Haz clic para ver los logs

### 3. Probar el Login

Después del deployment:

1. Ve a tu aplicación en Vercel
2. Intenta hacer login
3. **NO** debe aparecer el error de CORS
4. El login debe funcionar correctamente

## 📋 Verificación

### En el Navegador (DevTools → Network):

1. **Request a `/sanctum/csrf-cookie`:**
   - Status: `200 OK`
   - Headers de respuesta deben incluir:
     - `Access-Control-Allow-Origin: https://wms-v9-1g9f3et3d-jairo-narvaezs-projects-d7125f82.vercel.app`
     - `Access-Control-Allow-Credentials: true`
     - `Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS`

2. **Request a `/api/auth/login`:**
   - Status: `200 OK` (si las credenciales son correctas)
   - Headers de respuesta deben incluir los mismos headers CORS

### En Railway Logs:

- No debe aparecer ningún error relacionado con CORS
- El servidor debe estar funcionando normalmente

## 🚨 Si el Error Persiste

1. **Verifica los headers en DevTools:**
   - Abre DevTools → Network
   - Haz clic en la petición a `/sanctum/csrf-cookie`
   - Verifica que los headers CORS estén presentes

2. **Verifica que el middleware esté registrado:**
   - El middleware está en `bootstrap/app.php`
   - Debe estar registrado para los grupos `web` y `api`

3. **Verifica las variables de entorno en Railway:**
   - `CORS_ALLOWED_ORIGINS` puede estar vacío (está bien, el middleware detecta Vercel automáticamente)
   - `APP_ENV=production` debe estar configurado

## 📝 Notas

- El middleware ahora **siempre** verifica dominios de Vercel primero
- Esto asegura que todos los dominios de preview y producción de Vercel funcionen
- La ruta `/sanctum/csrf-cookie` también establece headers CORS directamente como respaldo

## 🔄 Dominios de Vercel Soportados

El middleware ahora soporta automáticamente:
- ✅ `https://wms-v9.vercel.app` (producción)
- ✅ `https://wms-v9-*.vercel.app` (preview deployments)
- ✅ `https://*.vercel.app` (cualquier subdominio de Vercel)

No necesitas configurar cada dominio de preview manualmente.
