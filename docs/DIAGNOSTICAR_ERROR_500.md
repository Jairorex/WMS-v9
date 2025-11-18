# 🔍 Diagnosticar Error 500 Internal Server Error

## ❌ Error

```
GET https://wms-v9-production.up.railway.app/sanctum/csrf-cookie 500 (Internal Server Error)
POST https://wms-v9-production.up.railway.app/api/auth/login 500 (Internal Server Error)
```

## 🔍 Causas Comunes

El error 500 puede ser causado por:

1. **Vista faltante** - Laravel intenta renderizar una vista que no existe
2. **Error en la base de datos** - Problema de conexión o driver
3. **Variable de entorno faltante** - `APP_KEY`, `DB_*`, etc.
4. **Error en el código PHP** - Excepción no capturada
5. **Problema con middleware** - Error en el procesamiento de la petición

## ✅ Soluciones Implementadas

### 1. Ruta Raíz Simplificada
- ✅ Cambiada de `view('welcome')` a respuesta JSON
- ✅ Evita errores por vista faltante

### 2. Manejo de Errores Mejorado
- ✅ Try-catch en `/sanctum/csrf-cookie`
- ✅ Headers CORS siempre establecidos, incluso en errores
- ✅ Respuesta JSON en lugar de vista

## 🚨 Acción Inmediata: Verificar Logs de Railway

**Este es el paso MÁS IMPORTANTE.** Necesitamos ver el error específico.

### Pasos:

1. **Ve a Railway Dashboard → Tu Proyecto**
2. **Haz clic en Logs** (no Deployments)
3. **Busca los logs más recientes** cuando ocurre el error 500
4. **Copia los logs completos** del error

### ¿Qué buscar en los logs?

#### Errores Comunes:

**Error: "View [welcome] not found"**
```
View [welcome] not found.
```
**Solución:** Ya corregido - ruta raíz ahora devuelve JSON

**Error: "No application encryption key"**
```
No application encryption key has been specified.
```
**Solución:** Agregar `APP_KEY` en Railway Variables

**Error: "could not find driver"**
```
could not find driver (Connection: sqlsrv, SQL: ...)
```
**Solución:** Verificar que el Dockerfile se haya usado correctamente

**Error: "Class not found"**
```
Class 'App\...' not found
```
**Solución:** Ejecutar `composer dump-autoload` o verificar namespace

**Error: "Call to undefined function"**
```
Call to undefined function ...
```
**Solución:** Verificar que las extensiones PHP estén instaladas

**Error: "SQLSTATE"**
```
SQLSTATE[08001]: [Microsoft][ODBC Driver 18 for SQL Server]SSL Provider: No se pudo encontrar un certificado válido
```
**Solución:** Agregar `TrustServerCertificate=yes` en la conexión

## 📋 Checklist de Verificación

- [ ] **Logs de Railway revisados** - ¿Qué error específico aparece?
- [ ] **`APP_KEY` configurado** - ¿Está en Railway Variables?
- [ ] **Variables de base de datos configuradas** - ¿Todas están presentes?
- [ ] **Extensiones PHP instaladas** - ¿Aparecen en los logs del build?
- [ ] **Servidor iniciando correctamente** - ¿Aparece "Server running"?

## 🔧 Variables de Entorno Necesarias

Asegúrate de que estas variables estén configuradas en Railway:

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
2. Busca el error específico cuando ocurre el 500
3. **Copia el error completo** (stack trace, mensaje, etc.)

### Paso 2: Verificar Variables de Entorno

1. Railway Dashboard → Variables
2. Verifica que `APP_KEY` esté configurado
3. Verifica que todas las variables de base de datos estén presentes

### Paso 3: Verificar Build Logs

1. Railway Dashboard → Deployments → Último deployment
2. Haz clic en "Build Logs"
3. Verifica que las extensiones PHP se instalaron:
   - `Installing sqlsrv...`
   - `Installing pdo_sqlsrv...`

### Paso 4: Probar Endpoint Directamente

Puedes probar el endpoint directamente:

```bash
curl https://wms-v9-production.up.railway.app/sanctum/csrf-cookie
```

O desde el navegador:
```
https://wms-v9-production.up.railway.app/sanctum/csrf-cookie
```

## 📝 Información Necesaria para Diagnosticar

Para diagnosticar mejor, necesito:

1. **Logs completos de Railway** cuando ocurre el error 500
2. **Stack trace completo** del error
3. **Mensaje de error específico** (primera línea del error)
4. **¿En qué endpoint ocurre?** (`/sanctum/csrf-cookie` o `/api/auth/login`)

## 💡 Nota Importante

Los cambios implementados deberían:
- ✅ Evitar errores por vista faltante
- ✅ Manejar errores mejor con try-catch
- ✅ Establecer headers CORS incluso en errores

**PERO** si el error 500 persiste, necesitamos ver los logs de Railway para identificar el problema específico.

## 🔄 Próximos Pasos

1. **Revisa los logs de Railway** (paso más importante)
2. **Comparte el error específico** que aparece en los logs
3. **Verifica las variables de entorno** en Railway
4. **Espera a que Railway redesplegue** con los cambios

Una vez que tengamos el error específico de los logs, podremos solucionarlo rápidamente.

