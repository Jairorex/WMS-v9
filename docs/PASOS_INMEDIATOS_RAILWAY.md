# 🚀 Pasos Inmediatos para Solucionar Railway

## ❌ Problemas Actuales

1. `APP_KEY` no configurado
2. `could not find driver` - Extensiones PHP no instaladas

## ✅ Solución Rápida (5 minutos)

### Paso 1: Agregar APP_KEY (2 minutos)

1. Ve a **Railway Dashboard → Variables**
2. Busca o crea `APP_KEY`
3. Valor:
   ```
   base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
   ```
4. **Guarda**

### Paso 2: Verificar Configuración de Build (1 minuto)

1. Ve a **Railway Dashboard → Settings → Build**
2. **Build Command:** Debe estar **VACÍO** (borra todo si hay algo)
3. **Start Command:** Debe ser:
   ```
   php artisan serve --host=0.0.0.0 --port=$PORT
   ```
4. **Guarda**

### Paso 3: Redesplegar (2 minutos)

1. Ve a **Railway Dashboard → Deployments**
2. Haz clic en **"Redeploy"** en el deployment más reciente
3. Espera 10-15 minutos

### Paso 4: Verificar Logs

Durante el build, en los logs deberías ver:
- Instalación de `msodbcsql18`
- Instalación de `sqlsrv` y `pdo_sqlsrv`

Si **NO** ves esto, Railway no está usando el Dockerfile.

## 🔍 Verificar que Railway Use el Dockerfile

### Opción A: Verificar Automáticamente

Railway debería detectar `backend/Dockerfile` automáticamente.

### Opción B: Si No Lo Detecta

1. Ve a **Settings → Build**
2. En "Dockerfile Path", especifica: `backend/Dockerfile`
3. O verifica que el Build Command esté vacío

## 📋 Variables de Entorno Completas

Asegúrate de que todas estas estén configuradas:

```
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
APP_URL=https://wms-v9-production.up.railway.app
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
SESSION_DRIVER=database
SESSION_LIFETIME=120
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app
```

## ✅ Después del Redespliegue

1. **Espera 10-15 minutos** para que termine el build
2. **Verifica los logs** - No debe aparecer "could not find driver"
3. **Prueba el login** - Debería funcionar

## 🚨 Si Sigue Sin Funcionar

1. **Comparte los logs del build** de Railway
2. **Verifica que el Dockerfile esté en `backend/Dockerfile`**
3. **Verifica que el Build Command esté vacío**

