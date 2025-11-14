# ✅ Checklist: Verificar APP_KEY en Railway

## 🔴 PASO CRÍTICO: Agregar APP_KEY en Railway

**El error persiste porque `APP_KEY` NO está configurada en Railway.**

### ⚠️ ACCIÓN REQUERIDA AHORA:

1. **Abre Railway Dashboard**: https://railway.app/dashboard
2. **Selecciona tu proyecto** → **Servicio del Backend**
3. **Ve a Variables** (menú lateral o pestaña superior)
4. **Busca `APP_KEY` en la lista**:
   - Si **NO está**: Haz clic en **+ New Variable**
   - Si **SÍ está**: Haz clic en el lápiz (✏️) para editarla

5. **Agrega/Edita la variable**:
   ```
   Variable Name: APP_KEY
   Value: base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
   ```

6. **GUARDA** (haz clic en Save/Add)

7. **REINICIA el servicio**:
   - Ve a **Settings**
   - Haz clic en **Restart Service**
   - Espera 1-2 minutos a que termine

## ✅ Verificación

Después de agregar `APP_KEY` y reiniciar, verifica:

1. **En Railway → Variables**: Deberías ver `APP_KEY` en la lista
2. **En Railway → Deployments → Logs**: NO deberías ver más:
   ```
   No application encryption key has been specified
   ```
3. **Prueba el endpoint**: `https://wms-v9-production.up.railway.app/sanctum/csrf-cookie`
   - Debería responder con 200 OK

## 🚨 Si el Error Persiste Después de Agregar APP_KEY

### Verificación 1: Formato Correcto

Abre `APP_KEY` en Railway y verifica que el valor sea EXACTAMENTE:
```
base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
```

**NO debe tener**:
- ❌ Comillas: `"base64:..."`
- ❌ Espacios: ` base64:...` o `base64:... `
- ❌ Saltos de línea

### Verificación 2: Reinicio Manual

Railway a veces no detecta cambios en variables. **Reinicia manualmente**:
1. Settings → Restart Service
2. Espera a que termine completamente

### Verificación 3: Ver Todas las Variables

Asegúrate de tener estas variables configuradas:

```
✅ APP_ENV=production
✅ APP_DEBUG=false
✅ APP_KEY=base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
✅ APP_URL=https://wms-v9-production.up.railway.app
✅ DB_CONNECTION=sqlsrv
✅ DB_HOST=wms-escasan-server.database.windows.net
✅ DB_PORT=1433
✅ DB_DATABASE=wms_escasan
✅ DB_USERNAME=wmsadmin
✅ DB_PASSWORD=Escasan123
✅ SESSION_DRIVER=database
✅ SESSION_LIFETIME=120
✅ CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
✅ SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app,*.vercel.app
```

## 📸 Cómo Debería Verse en Railway

En la sección de Variables, deberías ver algo como:

```
Variables
+ New Variable

APP_ENV                    production
APP_DEBUG                  false
APP_KEY                    base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
APP_URL                    https://wms-v9-production.up.railway.app
...
```

## ⚠️ IMPORTANTE

**El sistema NO funcionará hasta que agregues `APP_KEY` en Railway.**

Este es un paso **OBLIGATORIO** - sin `APP_KEY`, Laravel no puede funcionar.

