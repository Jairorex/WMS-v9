# Solución Definitiva: Error APP_KEY en Railway

## 🚨 El Problema

Railway sigue mostrando:
```
No application encryption key has been specified
```

Esto significa que `APP_KEY` **NO está configurada** o **NO se está leyendo correctamente** en Railway.

## ✅ Solución Paso a Paso (CONFIRMADA)

### Paso 1: Ir a Railway

1. Abre: https://railway.app/dashboard
2. Selecciona tu proyecto
3. Selecciona el servicio del **backend** (Laravel)

### Paso 2: Ir a Variables

1. En el menú lateral, haz clic en **Variables**
2. O busca la pestaña **Variables** en la parte superior

### Paso 3: Verificar si APP_KEY Existe

**Busca en la lista** si ya existe `APP_KEY`:
- Si **NO existe**: Ve al Paso 4
- Si **SÍ existe**: Ve al Paso 5

### Paso 4: Agregar APP_KEY (Si NO Existe)

1. Haz clic en **+ New Variable** o **+ Add Variable**
2. En **Variable Name**, escribe exactamente:
   ```
   APP_KEY
   ```
3. En **Value**, pega exactamente:
   ```
   base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
   ```
4. Haz clic en **Add** o **Save**

### Paso 5: Editar APP_KEY (Si Ya Existe)

1. Haz clic en el lápiz (✏️) o en **Edit** junto a `APP_KEY`
2. **Borra todo** el valor actual
3. Pega este valor exacto:
   ```
   base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
   ```
4. Haz clic en **Save**

### Paso 6: Verificar el Formato

Después de agregar/editar, verifica que:

✅ **Correcto**:
```
APP_KEY = base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
```

❌ **Incorrecto** (NO debe tener):
- Comillas: `"base64:..."`
- Espacios al inicio: ` base64:...`
- Espacios al final: `base64:... `
- Sin `base64:`: `Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=`

### Paso 7: Reiniciar el Servicio

**IMPORTANTE**: Después de agregar/editar `APP_KEY`:

1. Ve a **Settings** (en el menú del servicio)
2. Busca **Restart** o **Restart Service**
3. Haz clic en **Restart**
4. Espera a que termine el redespliegue (puede tardar 1-2 minutos)

### Paso 8: Verificar los Logs

1. Ve a **Deployments**
2. Haz clic en el deployment más reciente
3. Haz clic en **View Logs**
4. **NO deberías ver más** el error:
   ```
   No application encryption key has been specified
   ```

## 🔍 Verificación Adicional

### Verificar Todas las Variables Necesarias

Asegúrate de que tengas **TODAS** estas variables:

```
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
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
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app,*.vercel.app
```

## 🆘 Si el Error Persiste

### Opción 1: Eliminar y Recrear APP_KEY

1. En Railway → Variables
2. **Elimina** `APP_KEY` (haz clic en el ícono de basura 🗑️)
3. Espera 10 segundos
4. **Agrega** `APP_KEY` nuevamente con el valor:
   ```
   base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
   ```
5. **Reinicia** el servicio

### Opción 2: Verificar que Estás en el Servicio Correcto

Asegúrate de estar en el servicio del **backend** (Laravel), NO en el frontend.

### Opción 3: Verificar el Formato en Railway

En Railway, cuando edites `APP_KEY`, el campo debería verse así:

```
Variable Name: APP_KEY
Value: base64:Y9WumkNCC1FWM+z5QR7C3Rb+m4GuS3exk9PJuIjHzks=
```

**NO debe tener**:
- Comillas alrededor del valor
- Espacios al inicio o final
- Saltos de línea

## 📝 Nota Importante

Si ya tienes usuarios en producción con contraseñas encriptadas, **NO cambies** `APP_KEY` o perderás acceso a esas cuentas. En ese caso, usa la clave original que tenías.

## ✅ Checklist Final

Antes de considerar que está resuelto, verifica:

- [ ] `APP_KEY` está en la lista de variables en Railway
- [ ] El valor comienza con `base64:`
- [ ] No tiene comillas ni espacios
- [ ] El servicio se reinició después de agregar/editar
- [ ] Los logs ya NO muestran el error de APP_KEY
- [ ] El endpoint `/sanctum/csrf-cookie` responde con 200 OK

