# Solución: Error "No application encryption key has been specified"

## ⚠️ Problema

Error en Railway:
```
No application encryption key has been specified
```

Esto significa que la variable de entorno `APP_KEY` no está configurada correctamente en Railway.

## ✅ Solución

### Paso 1: Verificar APP_KEY en Railway

1. Ve a **Railway Dashboard** → tu proyecto → tu servicio
2. Pestaña **Variables**
3. Busca `APP_KEY`
4. Verifica que tenga el valor:
   ```
   base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
   ```

### Paso 2: Si APP_KEY no existe o está vacía

#### Opción A: Usar la clave existente (Recomendado)

Agrega esta variable en Railway:
```
APP_KEY=base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
```

**IMPORTANTE**: 
- El valor debe comenzar con `base64:`
- No debe tener espacios al inicio o final
- Debe estar en una sola línea

#### Opción B: Generar una nueva clave

Si necesitas generar una nueva clave:

1. **Localmente** (en tu máquina):
   ```bash
   cd backend
   php artisan key:generate --show
   ```
   
   Esto mostrará algo como:
   ```
   base64:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=
   ```

2. **Copia el valor completo** (incluyendo `base64:`)

3. **Agrega en Railway**:
   - Variable: `APP_KEY`
   - Valor: `base64:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=`

### Paso 3: Verificar el Formato

El formato correcto es:
```
APP_KEY=base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
```

**NO debe ser**:
- ❌ `APP_KEY="base64:..."` (sin comillas)
- ❌ `APP_KEY=AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=` (sin base64:)
- ❌ `APP_KEY= base64:...` (sin espacios)

### Paso 4: Reiniciar el Servicio

Después de agregar/editar `APP_KEY`:

1. **Railway redesplegará automáticamente**, O
2. **Reinicia manualmente**: Settings → Restart Service

### Paso 5: Verificar que Funciona

Después del redespliegue, verifica los logs de Railway. No deberías ver más el error:
```
No application encryption key has been specified
```

## 🔍 Verificación Completa de Variables

Asegúrate de que todas estas variables estén configuradas en Railway:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=
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

## 🚨 Troubleshooting

### Error: "APP_KEY is not set"

**Causa**: La variable no está configurada o tiene un formato incorrecto.

**Solución**: 
1. Verifica que `APP_KEY` esté en la lista de variables
2. Verifica que el valor comience con `base64:`
3. Verifica que no haya espacios extra

### Error: "Invalid APP_KEY format"

**Causa**: El formato de la clave es incorrecto.

**Solución**: 
1. Asegúrate de que comience con `base64:`
2. La clave debe tener 44 caracteres después de `base64:`
3. Debe terminar con `=`

### Error persiste después de agregar APP_KEY

**Solución**:
1. Reinicia el servicio manualmente en Railway
2. Espera a que el deployment termine completamente
3. Verifica los logs para confirmar que no hay más errores

## 📌 Nota Importante

**NUNCA cambies `APP_KEY` en producción** si ya tienes datos encriptados (como contraseñas de usuarios). Si cambias la clave, todos los datos encriptados se volverán ilegibles.

Si ya tienes datos en producción, usa la misma clave que tenías antes. Si es un sistema nuevo, puedes generar una nueva clave.

