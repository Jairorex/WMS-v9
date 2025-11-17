# 📝 Cómo Agregar Variables de Entorno en Railway

## 🚀 Guía Paso a Paso

### Paso 1: Acceder a Railway

1. Ve a [https://railway.app/dashboard](https://railway.app/dashboard)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto `WMS-v9`

### Paso 2: Ir a Variables

1. En el menú lateral izquierdo, busca **Variables**
2. O haz clic en la pestaña **Variables** en la parte superior
3. Verás una lista de todas las variables de entorno actuales

### Paso 3: Agregar una Variable

Para cada variable que necesites agregar:

1. **Haz clic en "+ New Variable"** (botón en la parte superior derecha)
2. **Name:** Escribe el nombre exacto de la variable (ej: `APP_KEY`)
3. **Value:** Pega el valor exacto (ej: `base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=`)
4. **Haz clic en "Add Variable"** o presiona Enter

### Paso 4: Editar una Variable Existente

Si la variable ya existe pero tiene un valor incorrecto:

1. **Busca la variable** en la lista
2. **Haz clic en el ícono de lápiz (✏️)** al lado de la variable
3. **Edita el valor**
4. **Haz clic en "Save"**

### Paso 5: Eliminar una Variable

Si necesitas eliminar una variable:

1. **Busca la variable** en la lista
2. **Haz clic en el ícono de basura (🗑️)** al lado de la variable
3. **Confirma la eliminación**

## 📋 Variables a Agregar

Usa el archivo `railway.env` como referencia, o copia estas variables:

### Variables Obligatorias

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

## ⚠️ Errores Comunes

### Error: "Variable already exists"
**Solución:** Edita la variable existente en lugar de crear una nueva

### Error: "Invalid value"
**Solución:** 
- Verifica que no haya espacios antes o después del valor
- Verifica que no haya comillas alrededor del valor
- Verifica que el formato sea correcto

### Error: "Variable not found"
**Solución:** 
- Verifica que escribiste el nombre exactamente (case-sensitive)
- Verifica que guardaste la variable correctamente

## ✅ Verificación

Después de agregar todas las variables:

1. **Revisa la lista** - Todas las variables deben aparecer
2. **Verifica los valores** - Deben ser exactos, sin espacios extra
3. **Espera el redespliegue** - Railway redesplegará automáticamente (1-2 minutos)
4. **Verifica los logs** - Ve a "Logs" para ver si hay errores

## 🔄 Después de Agregar Variables

1. **Espera 1-2 minutos** para que Railway redesplegue
2. **Verifica los logs** en Railway para errores
3. **Prueba el login** en tu aplicación de Vercel
4. **Si hay errores**, revisa los logs y corrige las variables

## 📝 Notas Importantes

- **NO** agregues comillas alrededor de los valores
- **NO** agregues espacios antes o después de los valores
- Los nombres de las variables son **case-sensitive** (sensibles a mayúsculas/minúsculas)
- Railway **redesplegará automáticamente** después de agregar/modificar variables
- Si no se redesplega automáticamente, ve a "Deployments" y haz clic en "Redeploy"

## 🔗 Archivos de Referencia

- `railway.env` - Archivo con todas las variables listas para copiar
- `docs/VARIABLES_ENTORNO_RAILWAY.md` - Documentación completa de variables
- `docs/AGREGAR_APP_KEY_RAILWAY_PASO_A_PASO.md` - Guía específica para APP_KEY

