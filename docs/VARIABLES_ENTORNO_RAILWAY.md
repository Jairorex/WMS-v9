# 🔧 Variables de Entorno para Railway

## 📋 Lista Completa de Variables

Copia y pega estas variables en Railway Dashboard → Variables:

### 🔑 Variables Obligatorias

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
APP_URL=https://wms-v9-production.up.railway.app
```

### 🗄️ Base de Datos (Azure SQL)

```env
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
```

### 🔐 Sesiones

```env
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

### 🌐 CORS y Sanctum

```env
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app
```

## 📝 Instrucciones para Agregar en Railway

### Paso 1: Ir a Variables

1. Ve a [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu proyecto `WMS-v9`
3. Haz clic en **Variables** en el menú lateral

### Paso 2: Agregar Variables

Para cada variable:

1. Haz clic en **+ New Variable**
2. Copia el **Name** exactamente como aparece
3. Copia el **Value** exactamente como aparece
4. Haz clic en **Save** o **Add Variable**

### Paso 3: Verificar

Después de agregar todas las variables:

1. Verifica que todas estén en la lista
2. Verifica que los valores sean correctos (sin espacios extra)
3. Railway redesplegará automáticamente

## ⚠️ Variables Críticas

Estas variables son **obligatorias** y deben estar correctamente configuradas:

### 1. APP_KEY ⚠️ MÁS IMPORTANTE
```
APP_KEY=base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
```
- **DEBE** comenzar con `base64:`
- **NO** debe tener espacios
- **NO** debe tener comillas

### 2. DB_HOST
```
DB_HOST=wms-escasan-server.database.windows.net
```
- Debe ser el servidor completo de Azure SQL
- **NO** incluir `https://` o `http://`

### 3. DB_DATABASE
```
DB_DATABASE=wms_escasan
```
- Nombre exacto de la base de datos en Azure SQL

### 4. DB_USERNAME y DB_PASSWORD
```
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
```
- Credenciales exactas de Azure SQL
- **NO** deben tener espacios

## 📋 Checklist de Verificación

Después de agregar todas las variables, verifica:

- [ ] `APP_KEY` está configurado y comienza con `base64:`
- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `DB_CONNECTION=sqlsrv`
- [ ] `DB_HOST` es el servidor completo de Azure SQL
- [ ] `DB_DATABASE=wms_escasan`
- [ ] `DB_USERNAME` y `DB_PASSWORD` son correctos
- [ ] `SESSION_DRIVER=database`
- [ ] `CORS_ALLOWED_ORIGINS` incluye tu dominio de Vercel
- [ ] `SANCTUM_STATEFUL_DOMAINS` incluye tu dominio de Vercel

## 🔄 Después de Agregar

1. **Espera 1-2 minutos** para que Railway redesplegue
2. **Verifica los logs** en Railway para ver si hay errores
3. **Prueba el login** en tu aplicación de Vercel

## 🚨 Si Hay Errores

### Error: "No application encryption key"
- Verifica que `APP_KEY` esté configurado correctamente
- Verifica que no tenga espacios o comillas

### Error: "SQLSTATE[08001]"
- Verifica que `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` sean correctos
- Verifica que el firewall de Azure SQL permita conexiones desde Railway

### Error: CORS
- Verifica que `CORS_ALLOWED_ORIGINS` incluya tu dominio de Vercel
- Verifica que `SANCTUM_STATEFUL_DOMAINS` incluya tu dominio de Vercel

## 📝 Notas

- **NO** agregues comillas alrededor de los valores
- **NO** agregues espacios antes o después de los valores
- Los valores son **case-sensitive** (sensibles a mayúsculas/minúsculas)
- Railway redesplegará automáticamente después de agregar/modificar variables

## 🔗 Referencias

- `docs/AGREGAR_APP_KEY_RAILWAY_PASO_A_PASO.md` - Guía para agregar APP_KEY
- `docs/SOLUCION_ERROR_500_RAILWAY.md` - Solución de errores 500
- `docs/COMPROBAR_CONEXION_BASE_DATOS.md` - Verificar conexión a BD

