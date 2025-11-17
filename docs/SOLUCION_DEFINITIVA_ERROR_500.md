# 🔧 Solución Definitiva: Error 500 en Railway

## ❌ Problema

Después de agregar `APP_KEY` y todas las variables, el error 500 persiste en:
- `GET /sanctum/csrf-cookie` → 500
- `POST /api/auth/login` → 500

## 🔍 Diagnóstico Completo

### Paso 1: Ver Logs de Railway (CRÍTICO)

**Este es el paso más importante.** Necesitamos ver el error exacto.

1. Ve a [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu proyecto
3. Haz clic en **Logs** o **Deployments**
4. Busca los errores más recientes (últimos 50-100 líneas)
5. **Copia el mensaje de error completo**

**Busca específicamente:**
- `SQLSTATE` - Error de base de datos
- `Table 'personal_access_tokens' doesn't exist` - Tabla faltante
- `Class 'PDO' not found` - Extensión PHP faltante
- `No application encryption key` - APP_KEY no se está leyendo
- `SQLSTATE[08001]` - Error de conexión

### Paso 2: Verificar Tabla personal_access_tokens

**Esta es la causa más común después de APP_KEY.**

Laravel Sanctum **requiere** la tabla `personal_access_tokens` para crear tokens.

**Verificar:**
1. Conecta a Azure SQL Database
2. Ejecuta: `sql/VERIFICAR_TABLA_PERSONAL_ACCESS_TOKENS.sql`

**Si no existe:**
1. Ejecuta: `sql/CREAR_TABLA_PERSONAL_ACCESS_TOKENS.sql`
2. O ejecuta este comando directamente:

```sql
USE [wms_escasan];
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[personal_access_tokens]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[personal_access_tokens] (
        [id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [tokenable_type] NVARCHAR(255) NOT NULL,
        [tokenable_id] BIGINT NOT NULL,
        [name] NVARCHAR(255) NOT NULL,
        [token] NVARCHAR(64) NOT NULL,
        [abilities] NVARCHAR(MAX) NULL,
        [last_used_at] DATETIME2 NULL,
        [expires_at] DATETIME2 NULL,
        [created_at] DATETIME2 NULL,
        [updated_at] DATETIME2 NULL,
        CONSTRAINT [UQ_personal_access_tokens_token] UNIQUE ([token])
    );

    CREATE INDEX [IX_personal_access_tokens_tokenable] 
    ON [dbo].[personal_access_tokens] ([tokenable_type], [tokenable_id]);

    CREATE INDEX [IX_personal_access_tokens_expires_at] 
    ON [dbo].[personal_access_tokens] ([expires_at]);

    PRINT 'Tabla personal_access_tokens creada exitosamente';
END
GO
```

### Paso 3: Verificar Variables en Railway

Verifica que todas estas variables estén configuradas correctamente:

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

**Verificaciones importantes:**
- ✅ `APP_KEY` comienza con `base64:`
- ✅ `APP_KEY` NO tiene espacios antes o después
- ✅ `DB_HOST` es el servidor completo (sin `https://`)
- ✅ `DB_USERNAME` y `DB_PASSWORD` son correctos
- ✅ NO hay comillas alrededor de ningún valor

### Paso 4: Verificar Firewall de Azure SQL

Railway necesita poder conectar a Azure SQL.

1. Ve a [Azure Portal](https://portal.azure.com)
2. Abre tu SQL Database
3. Ve a **Networking** o **Firewall rules**
4. Verifica que haya una regla que permita conexiones desde Railway
5. **O agrega una regla temporal:**
   - **Rule name:** `AllowAll`
   - **Start IP:** `0.0.0.0`
   - **End IP:** `255.255.255.255`
   - **Haz clic en Save**

**⚠️ IMPORTANTE:** La regla "AllowAll" es solo para pruebas. En producción, deberías restringir las IPs.

### Paso 5: Redesplegar Manualmente

Después de hacer cambios:

1. Ve a Railway Dashboard → **Deployments**
2. Haz clic en **Redeploy** en el deployment más reciente
3. Espera 2-3 minutos
4. Prueba nuevamente

## 🚨 Errores Específicos y Soluciones

### Error: "Table 'personal_access_tokens' doesn't exist"
**Causa:** La tabla no existe en Azure SQL
**Solución:**
1. Ejecuta `sql/CREAR_TABLA_PERSONAL_ACCESS_TOKENS.sql` en Azure SQL
2. Redesplega en Railway

### Error: "SQLSTATE[08001]"
**Causa:** No se puede conectar a Azure SQL
**Solución:**
1. Verifica credenciales en Railway Variables
2. Verifica firewall de Azure SQL
3. Verifica que el servidor esté accesible

### Error: "Class 'PDO' not found"
**Causa:** Extensiones PHP faltantes en Railway
**Solución:**
1. Verifica que Railway tenga `pdo_sqlsrv` y `sqlsrv` instaladas
2. Revisa el Dockerfile de Railway

### Error: "No application encryption key"
**Causa:** APP_KEY no se está leyendo
**Solución:**
1. Verifica que `APP_KEY` esté en Railway Variables
2. Verifica que no tenga espacios o comillas
3. Redesplega manualmente

## 📋 Checklist Final

Antes de probar nuevamente, verifica:

- [ ] Logs de Railway revisados - Error identificado
- [ ] `APP_KEY` configurado correctamente en Railway
- [ ] Tabla `personal_access_tokens` existe en Azure SQL
- [ ] Variables de base de datos correctas en Railway
- [ ] Firewall de Azure SQL permite conexiones
- [ ] Servicio redesplegado manualmente
- [ ] Esperado 2-3 minutos después del redespliegue

## 🚀 Orden de Acción Recomendado

1. **PRIMERO:** Revisa los logs de Railway y comparte el error exacto
2. **SEGUNDO:** Verifica que la tabla `personal_access_tokens` existe
3. **TERCERO:** Verifica el firewall de Azure SQL
4. **CUARTO:** Redesplega manualmente en Railway
5. **QUINTO:** Prueba el login nuevamente

## 📝 Información Necesaria

Para ayudarte mejor, comparte:

1. **El error exacto de los logs de Railway** (últimas 50-100 líneas)
2. **Resultado de verificar la tabla** `personal_access_tokens`
3. **Configuración del firewall de Azure SQL** (¿permite conexiones?)

## 💡 Nota

El error 500 después de agregar `APP_KEY` generalmente es causado por:
1. Tabla `personal_access_tokens` faltante (más común)
2. Problemas de conexión a Azure SQL
3. Extensiones PHP faltantes en Railway

