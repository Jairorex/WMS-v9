# 🔧 Solución: Error 502 Bad Gateway

## ❌ Error

```
GET https://wms-v9-production.up.railway.app/sanctum/csrf-cookie net::ERR_FAILED 502 (Bad Gateway)
POST https://wms-v9-production.up.railway.app/api/auth/login net::ERR_FAILED
```

## 🔍 Causa

El error **502 Bad Gateway** significa que:
- El servidor backend **NO está respondiendo**
- El servidor podría estar **crasheando al iniciar**
- El servidor podría **no estar iniciando** en absoluto
- Hay un **error antes de que el middleware se ejecute**

## ✅ Soluciones Implementadas

### 1. Middleware CORS Mejorado
- ✅ Permite explícitamente `wms-v9.vercel.app`
- ✅ Permite todos los dominios `*.vercel.app`
- ✅ Manejo de errores con try-catch
- ✅ Headers CORS siempre establecidos para Vercel

### 2. Ruta `/sanctum/csrf-cookie` Mejorada
- ✅ Soporte para peticiones OPTIONS
- ✅ Headers CORS establecidos directamente

## 🚨 Acción Inmediata: Verificar Logs de Railway

**Este es el paso MÁS IMPORTANTE.** Necesitamos ver qué está pasando con el servidor.

### Pasos:

1. **Ve a Railway Dashboard**
   - https://railway.app/dashboard
   - Selecciona tu proyecto `WMS-v9`

2. **Ve a Logs (NO Deployments)**
   - En el menú lateral, haz clic en **Logs**
   - O haz clic en tu servicio → **Logs**

3. **Busca los logs más recientes**
   - Los logs deberían mostrar el inicio del contenedor
   - Busca desde que el contenedor inicia

4. **Copia los logs completos**
   - Últimas 50-100 líneas
   - Desde que el contenedor inicia hasta el error

### ¿Qué buscar en los logs?

#### ✅ Si el servidor está funcionando, deberías ver:

```
🚀 Iniciando servidor Laravel en puerto 8080
📋 Verificando extensiones PHP...
sqlsrv
pdo_sqlsrv
✅ Iniciando servidor...
Server running on [http://0.0.0.0:8080]
```

#### ❌ Si el servidor NO está funcionando, podrías ver:

**Error: No application encryption key**
```
production.ERROR: No application encryption key has been specified.
```
**Solución:** Agregar `APP_KEY` en Railway Variables

**Error: could not find driver**
```
could not find driver (Connection: sqlsrv, SQL: select top 1 * from [usuarios]...
```
**Solución:** Verificar que el Dockerfile se haya usado correctamente

**Error: Unsupported operand types**
```
Unsupported operand types: string + int
```
**Solución:** Ya corregido en `start.sh`

**Error: El servidor inicia pero crashea inmediatamente**
- Revisa los logs completos para encontrar el error específico

**Error: No aparece ningún mensaje del script de inicio**
- El script `start.sh` no se está ejecutando
- Verifica que el Dockerfile esté correcto

## 📋 Checklist de Verificación

- [ ] **Logs de Railway revisados** - ¿Qué error aparece?
- [ ] **Estado del deployment** - ¿Está "Active" o "Failed"?
- [ ] **`APP_KEY` configurado** - ¿Está en Railway Variables?
- [ ] **Todas las variables de entorno configuradas** - Ver lista abajo
- [ ] **Build completado exitosamente** - ¿El último build fue exitoso?
- [ ] **Script de inicio ejecutándose** - ¿Aparecen los mensajes 🚀, 📋, ✅?
- [ ] **Extensiones PHP instaladas** - ¿Aparecen sqlsrv y pdo_sqlsrv en los logs?
- [ ] **Servidor iniciando correctamente** - ¿Aparece "Server running"?

## 🔧 Variables de Entorno Necesarias en Railway

Asegúrate de que estas variables estén configuradas:

```env
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

CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app
PORT=8080
```

## 🚀 Pasos de Solución

### Paso 1: Verificar Logs (CRÍTICO)

1. Ve a Railway → Logs
2. Copia los logs completos (últimas 50-100 líneas)
3. **Comparte los logs** para diagnosticar

### Paso 2: Verificar Variables de Entorno

1. Railway Dashboard → Tu Proyecto → Variables
2. Verifica que `APP_KEY` esté configurado
3. Verifica que todas las variables estén configuradas

### Paso 3: Verificar Estado del Deployment

1. Railway Dashboard → Deployments
2. Verifica el estado del último deployment:
   - ✅ **Active** - El deployment está activo
   - ⏳ **Building** - Todavía está construyendo
   - ❌ **Failed** - El build falló
   - ⚠️ **Stopped** - El servicio está detenido

### Paso 4: Reiniciar el Servicio (Si es necesario)

1. Railway Dashboard → Tu Servicio
2. Haz clic en **Settings**
3. Haz clic en **Restart**

## 📝 Información Necesaria para Diagnosticar

Para diagnosticar mejor, necesito:

1. **Logs completos de Railway** desde que el contenedor inicia (últimas 50-100 líneas)
2. **Estado del deployment** - ¿Está activo o falló?
3. **¿Aparecen los mensajes del script de inicio?** (🚀, 📋, ✅)
4. **¿El servidor inicia?** (busca "Server running")
5. **¿Hay errores de PHP?** (cualquier mensaje de error)

## 💡 Nota Importante

El middleware CORS ahora está configurado para:
- ✅ Permitir `wms-v9.vercel.app` explícitamente
- ✅ Permitir todos los dominios `*.vercel.app`
- ✅ Manejar errores correctamente
- ✅ Establecer headers CORS siempre para Vercel

**PERO** si el servidor está devolviendo 502, significa que el servidor ni siquiera está funcionando, por lo que el middleware no se está ejecutando.

**El problema principal es que el servidor no está respondiendo.** Necesitamos ver los logs de Railway para diagnosticar por qué.

## 🔄 Próximos Pasos

1. **Revisa los logs de Railway** (paso más importante)
2. **Comparte los logs** para diagnosticar
3. **Verifica las variables de entorno** en Railway
4. **Espera a que Railway redesplegue** con los cambios de CORS

Una vez que el servidor esté funcionando, el problema de CORS debería resolverse automáticamente con los cambios que hemos hecho.

