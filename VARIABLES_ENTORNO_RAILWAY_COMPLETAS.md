# Variables de Entorno Completas para Railway

## ✅ Configuración Recomendada

Basándote en tu configuración actual, aquí está la versión mejorada con todas las variables necesarias:

```env
# ============================================
# APLICACIÓN
# ============================================
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
APP_URL=https://wms-v9-production.up.railway.app

# ============================================
# BASE DE DATOS
# ============================================
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123

# ============================================
# SESIONES
# ============================================
SESSION_DRIVER=database
SESSION_LIFETIME=120

# ============================================
# CORS - IMPORTANTE: Incluir todos los dominios
# ============================================
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app

# ============================================
# SANCTUM (Autenticación)
# ============================================
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app,*.vercel.app

# ============================================
# OPCIONAL: Cache y Optimización
# ============================================
CACHE_DRIVER=database
QUEUE_CONNECTION=database
LOG_CHANNEL=stderr
```

## 🔧 Cambios Recomendados

### 1. Agregar `APP_URL` (IMPORTANTE)

**Falta en tu configuración actual**. Agrega:
```
APP_URL=https://wms-v9-production.up.railway.app
```

**Por qué es importante:**
- Laravel necesita saber su URL base para generar URLs correctas
- Afecta a CORS y Sanctum
- Necesario para que las rutas funcionen correctamente

### 2. Mejorar `CORS_ALLOWED_ORIGINS`

**Actual:**
```
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app
```

**Recomendado:**
```
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
```

**Por qué:**
- Vercel genera URLs únicas para cada preview deployment (ej: `https://wms-v9-abc123.vercel.app`)
- El middleware CORS ya detecta automáticamente `*.vercel.app`, pero es mejor especificarlo explícitamente
- Permite que funcionen tanto producción como preview deployments

### 3. Mejorar `SANCTUM_STATEFUL_DOMAINS`

**Actual:**
```
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app
```

**Recomendado:**
```
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app,*.vercel.app
```

**Por qué:**
- Permite que Sanctum funcione con todos los deployments de Vercel
- Necesario si usas preview deployments

## 📝 Instrucciones para Actualizar en Railway

1. **Ve a Railway Dashboard**
   - https://railway.app/dashboard
   - Selecciona tu proyecto
   - Selecciona el servicio del backend

2. **Ve a Variables**
   - Pestaña **Variables** en el menú lateral

3. **Agrega/Edita las siguientes variables:**

   | Variable | Valor |
   |----------|-------|
   | `APP_URL` | `https://wms-v9-production.up.railway.app` |
   | `CORS_ALLOWED_ORIGINS` | `https://wms-v9.vercel.app,https://*.vercel.app` |
   | `SANCTUM_STATEFUL_DOMAINS` | `wms-v9.vercel.app,*.vercel.app` |

4. **Guarda los cambios**
   - Railway redesplegará automáticamente

5. **Verifica el despliegue**
   - Ve a la pestaña **Deployments**
   - Espera a que el nuevo deployment termine
   - Verifica los logs para asegurarte de que no hay errores

## ✅ Verificación Post-Configuración

### 1. Verificar que APP_URL esté configurada

En los logs de Railway, deberías ver que Laravel reconoce la URL correcta.

### 2. Probar CORS

Abre la consola del navegador y verifica que no haya errores de CORS al hacer peticiones a la API.

### 3. Probar Login

Intenta hacer login desde el frontend. Debería funcionar correctamente.

## 🚨 Troubleshooting

### Error: "APP_URL not set"

**Solución**: Agrega `APP_URL=https://wms-v9-production.up.railway.app` en Railway.

### Error: CORS sigue fallando

**Solución**: 
1. Verifica que `CORS_ALLOWED_ORIGINS` incluya tu dominio exacto
2. Reinicia el servicio en Railway (Settings → Restart)
3. Verifica que el middleware CORS esté funcionando (revisa los logs)

### Error: Sanctum no funciona

**Solución**:
1. Verifica que `SANCTUM_STATEFUL_DOMAINS` incluya tu dominio
2. Asegúrate de que `APP_URL` esté configurada
3. Verifica que las rutas de Sanctum estén registradas

## 📌 Notas Adicionales

- **Seguridad**: Nunca compartas tus variables de entorno, especialmente `APP_KEY` y `DB_PASSWORD`
- **Backup**: Guarda una copia de tus variables de entorno en un lugar seguro
- **Producción**: Asegúrate de que `APP_DEBUG=false` en producción (ya lo tienes correcto)
- **Base de Datos**: Verifica que la conexión a Azure SQL esté funcionando correctamente

