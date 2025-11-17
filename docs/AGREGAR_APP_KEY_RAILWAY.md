# Cómo Agregar APP_KEY en Railway - Paso a Paso

## 🚨 Problema Actual

El error indica que `APP_KEY` no está configurada en Railway:
```
No application encryption key has been specified
```

## ✅ Solución: Agregar APP_KEY en Railway

### Paso 1: Ir a Railway Dashboard

1. Abre tu navegador y ve a: https://railway.app/dashboard
2. Inicia sesión si es necesario
3. Selecciona tu proyecto **WMS-v9** (o el nombre que le hayas dado)

### Paso 2: Seleccionar el Servicio del Backend

1. En la lista de servicios, haz clic en el servicio del **backend** (Laravel)
2. Deberías ver el dashboard del servicio

### Paso 3: Ir a Variables

1. En el menú lateral izquierdo, busca y haz clic en **Variables**
2. O busca la pestaña **Variables** en la parte superior

### Paso 4: Agregar APP_KEY

1. Haz clic en el botón **+ New Variable** o **Add Variable**
2. En el campo **Variable Name**, escribe exactamente:
   ```
   APP_KEY
   ```
   (Sin espacios, todo en mayúsculas)

3. En el campo **Value**, pega exactamente este valor:
   ```
   base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
   ```
   (Sin comillas, sin espacios al inicio o final)

4. Haz clic en **Add** o **Save**

### Paso 5: Verificar que se Agregó

1. Deberías ver `APP_KEY` en la lista de variables
2. Verifica que el valor sea exactamente:
   ```
   base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
   ```

### Paso 6: Esperar el Redespliegue

Railway debería detectar el cambio y redesplegar automáticamente. Verás:
- Un nuevo deployment iniciándose
- El estado cambiando a "Building" y luego "Deploying"

### Paso 7: Verificar los Logs

1. Ve a la pestaña **Deployments**
2. Haz clic en el deployment más reciente
3. Haz clic en **View Logs** o **Logs**
4. Busca el error. **NO deberías ver más**:
   ```
   No application encryption key has been specified
   ```

## 🔍 Si el Error Persiste

### Verificación 1: Formato Correcto

Asegúrate de que `APP_KEY` tenga exactamente este formato:
```
APP_KEY=base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
```

**NO debe tener**:
- ❌ Comillas: `"base64:..."`
- ❌ Espacios: ` base64:...` o `base64:... `
- ❌ Sin `base64:`: `AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=`

### Verificación 2: Reiniciar Manualmente

Si Railway no redesplegó automáticamente:

1. Ve a **Settings** (en el menú del servicio)
2. Busca la opción **Restart** o **Restart Service**
3. Haz clic en **Restart**
4. Espera a que termine el redespliegue

### Verificación 3: Ver Todas las Variables

Asegúrate de que tengas estas variables configuradas:

| Variable | Valor |
|----------|-------|
| `APP_ENV` | `production` |
| `APP_DEBUG` | `false` |
| `APP_KEY` | `base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=` |
| `APP_URL` | `https://wms-v9-production.up.railway.app` |
| `DB_CONNECTION` | `sqlsrv` |
| `DB_HOST` | `wms-escasan-server.database.windows.net` |
| `DB_PORT` | `1433` |
| `DB_DATABASE` | `wms_escasan` |
| `DB_USERNAME` | `wmsadmin` |
| `DB_PASSWORD` | `Escasan123` |
| `SESSION_DRIVER` | `database` |
| `SESSION_LIFETIME` | `120` |
| `CORS_ALLOWED_ORIGINS` | `https://wms-v9.vercel.app,https://*.vercel.app` |
| `SANCTUM_STATEFUL_DOMAINS` | `wms-v9.vercel.app,*.vercel.app` |

## 📸 Captura de Pantalla de Referencia

En Railway, la sección de Variables debería verse así:

```
Variables
+ New Variable

APP_ENV                    production
APP_DEBUG                  false
APP_KEY                    base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
APP_URL                    https://wms-v9-production.up.railway.app
DB_CONNECTION              sqlsrv
...
```

## ⚠️ Importante

- **NO cambies `APP_KEY`** si ya tienes datos encriptados en producción
- **NO compartas** tu `APP_KEY` públicamente
- **Guarda una copia** de todas tus variables de entorno en un lugar seguro

## 🆘 Si Nada Funciona

1. **Elimina y vuelve a agregar** `APP_KEY`:
   - Elimina la variable `APP_KEY`
   - Espera unos segundos
   - Agrega `APP_KEY` nuevamente con el valor correcto

2. **Verifica que estés en el servicio correcto**:
   - Asegúrate de estar en el servicio del backend, no del frontend

3. **Contacta soporte de Railway** si el problema persiste

