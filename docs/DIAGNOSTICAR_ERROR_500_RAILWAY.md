# 🔍 Diagnosticar Error 500 en Railway

## ❌ Problema

El backend en Railway está devolviendo error 500 en:
- `GET /sanctum/csrf-cookie` → 500
- `POST /api/auth/login` → 500

## 🔍 Pasos para Diagnosticar

### 1. Ver Logs de Railway

1. Ve a [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu proyecto `WMS-v9`
3. Ve a la pestaña **Deployments** o **Logs**
4. Busca errores recientes, especialmente:
   - `ERROR`
   - `Exception`
   - `SQLSTATE`
   - `APP_KEY`
   - `Database connection`

### 2. Verificar Variables de Entorno en Railway

Asegúrate de que estas variables estén configuradas:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... (debe estar configurado)
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

### 3. Verificar que APP_KEY Esté Configurado

El error 500 puede ser causado por `APP_KEY` faltante o incorrecto.

**Verificar en Railway:**
1. Ve a **Variables**
2. Busca `APP_KEY`
3. Debe tener un valor como: `base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=`

**Si falta, generar uno nuevo:**
```bash
cd backend
php artisan key:generate --show
```

### 4. Verificar Conexión a Base de Datos

El error 500 puede ser causado por problemas de conexión a Azure SQL.

**Verificar en Railway:**
- `DB_HOST` debe ser: `wms-escasan-server.database.windows.net`
- `DB_DATABASE` debe ser: `wms_escasan`
- `DB_USERNAME` y `DB_PASSWORD` deben ser correctos

### 5. Probar el Endpoint Directamente

```bash
# Probar CSRF cookie
curl https://wms-v9-production.up.railway.app/sanctum/csrf-cookie

# Probar login
curl -X POST https://wms-v9-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'
```

### 6. Verificar Tabla de Sesiones

Si `SESSION_DRIVER=database`, necesitas la tabla `sessions`:

```sql
-- Verificar que la tabla existe
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'sessions';
```

## 🚨 Errores Comunes y Soluciones

### Error: "No application encryption key"
**Solución:** Agregar `APP_KEY` en Railway

### Error: "SQLSTATE[08001]"
**Solución:** Verificar credenciales de Azure SQL Database

### Error: "Table 'sessions' doesn't exist"
**Solución:** Crear la tabla sessions o cambiar `SESSION_DRIVER=file`

### Error: "Class 'PDO' not found"
**Solución:** Verificar que las extensiones PHP estén instaladas en Railway

## 📋 Checklist de Verificación

- [ ] `APP_KEY` configurado en Railway
- [ ] Variables de base de datos correctas
- [ ] Tabla `sessions` existe (si `SESSION_DRIVER=database`)
- [ ] Azure SQL Database accesible desde Railway
- [ ] Logs de Railway revisados
- [ ] Backend redesplegado después de cambios

## 🔧 Solución Rápida: Cambiar SESSION_DRIVER

Si el problema es la tabla `sessions`, puedes cambiar temporalmente:

En Railway, cambia:
```
SESSION_DRIVER=file
```

Esto no requiere la tabla `sessions` en la base de datos.

## 📝 Información Necesaria

Para diagnosticar mejor, comparte:
1. **Logs de Railway** (últimas 50 líneas)
2. **Variables de entorno** (sin valores sensibles)
3. **Respuesta del curl** (si lo probaste)
4. **Mensaje de error exacto** de los logs

