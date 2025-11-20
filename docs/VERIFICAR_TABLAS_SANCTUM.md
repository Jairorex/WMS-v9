# 🔍 Verificar Tablas de Sanctum en Azure SQL

## ❌ Problema

El error 500 puede ser causado por tablas faltantes que Laravel Sanctum necesita:
- `personal_access_tokens` (para tokens de autenticación)
- `sessions` (si `SESSION_DRIVER=database`)

## ✅ Solución

### 1. Verificar si las Tablas Existen

Ejecuta en Azure SQL Database:

```sql
-- Verificar personal_access_tokens
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'personal_access_tokens';

-- Verificar sessions
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'sessions';
```

### 2. Crear Tabla personal_access_tokens

Si la tabla no existe, ejecuta el script:
- `sql/CREAR_TABLA_PERSONAL_ACCESS_TOKENS.sql`

O ejecuta directamente:

```sql
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
END
```

### 3. Crear Tabla sessions (si SESSION_DRIVER=database)

Si `SESSION_DRIVER=database`, ejecuta:
- `sql/CREAR_TABLA_SESSIONS.sql`

### 4. Alternativa: Cambiar SESSION_DRIVER

Si prefieres no crear la tabla `sessions`, cambia en Railway:

```
SESSION_DRIVER=file
```

Esto no requiere la tabla `sessions` en la base de datos.

## 🔍 Verificar en Railway

Después de crear las tablas:

1. **Redesplegar el servicio en Railway**
2. **Verificar los logs** para ver si el error 500 persiste
3. **Probar el login** nuevamente

## 📝 Nota

La tabla `personal_access_tokens` es **obligatoria** para Laravel Sanctum. Sin ella, `createToken()` fallará con error 500.

