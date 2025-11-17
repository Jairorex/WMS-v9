# Configurar CORS en Railway

## ⚠️ Problema: Error de CORS

Si ves errores como:
```
Access to XMLHttpRequest at 'https://wms-v9-production.up.railway.app/sanctum/csrf-cookie' 
from origin 'https://wms-v9-xxx.vercel.app' has been blocked by CORS policy: 
The 'Access-Control-Allow-Origin' header has a value 'http://localhost:5173' 
that is not equal to the supplied origin.
```

Esto significa que la variable `CORS_ALLOWED_ORIGINS` no está configurada correctamente en Railway.

## ✅ Solución

### Opción 1: Configurar Orígenes Específicos (Recomendado)

1. Ve a tu proyecto en [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu servicio del backend
3. Ve a **Variables**
4. Agrega o edita la variable `CORS_ALLOWED_ORIGINS`

#### Para Vercel con dominio personalizado:
```
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app
```

#### Para Vercel con múltiples deployments (preview + producción):
```
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
```

**Nota**: El middleware ahora detecta automáticamente dominios `*.vercel.app`, pero es mejor especificarlos explícitamente.

### Opción 2: Usar Patrón Wildcard (Solo si es necesario)

Si tienes múltiples deployments de preview en Vercel, puedes usar:

```
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
```

**⚠️ Advertencia**: Usar wildcards puede ser menos seguro. Es mejor especificar los dominios exactos.

## 📝 Configuración Completa en Railway

Asegúrate de tener estas variables configuradas:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... (generar con php artisan key:generate)
APP_URL=https://wms-v9-production.up.railway.app

# CORS - IMPORTANTE: Incluir todos los dominios del frontend
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app

# Base de datos
DB_CONNECTION=sqlsrv
DB_HOST=tu-servidor-azure.database.windows.net
DB_DATABASE=wms
DB_USERNAME=tu-usuario
DB_PASSWORD=tu-password
DB_PORT=1433

# Sesiones
SESSION_DRIVER=database
SESSION_LIFETIME=120

# Sanctum (para autenticación)
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app,*.vercel.app
```

## 🔍 Verificar la Configuración

### 1. Verificar que las Variables Estén Configuradas

En Railway:
- Ve a tu servicio
- Pestaña **Variables**
- Verifica que `CORS_ALLOWED_ORIGINS` tenga el valor correcto

### 2. Probar la API

Abre la consola del navegador (F12) y ejecuta:

```javascript
fetch('https://wms-v9-production.up.railway.app/api/roles', {
  method: 'GET',
  headers: {
    'Accept': 'application/json',
  },
  credentials: 'include'
})
.then(r => r.json())
.then(console.log)
.catch(console.error);
```

Si funciona, deberías ver la respuesta JSON. Si hay error de CORS, verás el error en la consola.

### 3. Verificar Headers CORS

Abre la pestaña **Network** en las herramientas de desarrollo:
1. Haz una petición a la API
2. Selecciona la petición
3. Ve a la pestaña **Headers**
4. Busca `Access-Control-Allow-Origin`
5. Debe tener el valor de tu dominio de Vercel

## 🚨 Troubleshooting

### Error: "Access-Control-Allow-Origin header has a value 'http://localhost:5173'"

**Causa**: `CORS_ALLOWED_ORIGINS` no está configurado o está vacío.

**Solución**:
1. Agrega `CORS_ALLOWED_ORIGINS` en Railway con el dominio de Vercel
2. Reinicia el servicio en Railway (Settings → Restart)

### Error: "No 'Access-Control-Allow-Origin' header is present"

**Causa**: El middleware CORS no se está ejecutando o hay un error en el servidor.

**Solución**:
1. Verifica los logs de Railway para ver si hay errores
2. Verifica que el middleware esté registrado en `bootstrap/app.php`
3. Limpia el caché: `php artisan config:clear`

### Error: "Credentials flag is true, but Access-Control-Allow-Credentials is not 'true'"

**Causa**: El middleware está devolviendo `*` como origen cuando hay credenciales.

**Solución**: El middleware ya está configurado para evitar esto. Verifica que `CORS_ALLOWED_ORIGINS` tenga al menos un dominio específico (no solo `*`).

## 📌 Notas Importantes

1. **Dominios de Vercel**: Vercel genera URLs únicas para cada preview deployment (ej: `https://wms-v9-abc123.vercel.app`). El middleware ahora detecta automáticamente estos dominios, pero es mejor especificar tu dominio de producción.

2. **Dominio Personalizado**: Si usas un dominio personalizado en Vercel, agrégalo explícitamente a `CORS_ALLOWED_ORIGINS`.

3. **Múltiples Entornos**: Si tienes staging, producción, etc., sepáralos con comas:
   ```
   CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://staging.wms-v9.vercel.app
   ```

4. **Reiniciar Servicio**: Después de cambiar variables de entorno, reinicia el servicio en Railway para que los cambios surtan efecto.

