# Instrucciones para Crear la Tabla de Sesiones

## 📋 Problema

El error 500 en `/sanctum/csrf-cookie` puede deberse a que la tabla `[dbo].[sessions]` no existe en la base de datos.

## ✅ Solución: Crear la Tabla Sessions

### Opción 1: Ejecutar el Script SQL (Recomendado)

1. **Abre Azure Portal** o **Azure Data Studio** o **SQL Server Management Studio**

2. **Conéctate a tu base de datos**:
   - Servidor: `wms-escasan-server.database.windows.net`
   - Base de datos: `wms_escasan`
   - Usuario: `wmsadmin`
   - Contraseña: `Escasan123`

3. **Ejecuta el script `CREAR_TABLA_SESSIONS.sql`**:
   - Copia el contenido del archivo
   - Pégalo en el editor de consultas
   - Ejecuta el script (F5 o botón "Execute")

4. **Verifica que la tabla se creó**:
   ```sql
   SELECT * FROM [dbo].[sessions];
   ```
   Debería devolver una tabla vacía (sin errores).

### Opción 2: Usar Laravel Migrations

Si prefieres usar las migraciones de Laravel:

1. **Conéctate a Railway** (SSH o terminal)

2. **Ejecuta**:
   ```bash
   php artisan session:table
   php artisan migrate
   ```

   **Nota**: Esto puede no funcionar si la migración de sesiones no está disponible o si hay problemas de conexión.

### Opción 3: Crear Manualmente en Azure Portal

1. Ve a **Azure Portal** → **SQL databases** → `wms_escasan`
2. Haz clic en **Query editor** (o usa **Azure Data Studio**)
3. Ejecuta el siguiente SQL:

```sql
USE [wms_escasan];
GO

CREATE TABLE [dbo].[sessions] (
    [id] NVARCHAR(255) NOT NULL,
    [user_id] BIGINT NULL,
    [ip_address] NVARCHAR(45) NULL,
    [user_agent] NVARCHAR(MAX) NULL,
    [payload] NVARCHAR(MAX) NOT NULL,
    [last_activity] INT NOT NULL,
    CONSTRAINT [PK_sessions] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [sessions_user_id_index] 
ON [dbo].[sessions] ([user_id] ASC);

CREATE NONCLUSTERED INDEX [sessions_last_activity_index] 
ON [dbo].[sessions] ([last_activity] ASC);
GO
```

## 🔍 Verificación

Después de crear la tabla, verifica:

### 1. Verificar que la tabla existe:
```sql
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'sessions';
```

Debería mostrar:
```
TABLE_SCHEMA | TABLE_NAME
-------------|-----------
dbo          | sessions
```

### 2. Verificar la estructura:
```sql
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME = 'sessions'
ORDER BY ORDINAL_POSITION;
```

Debería mostrar:
- `id` (NVARCHAR, NOT NULL)
- `user_id` (BIGINT, NULLABLE)
- `ip_address` (NVARCHAR, NULLABLE)
- `user_agent` (NVARCHAR, NULLABLE)
- `payload` (NVARCHAR, NOT NULL)
- `last_activity` (INT, NOT NULL)

### 3. Probar la API

Después de crear la tabla:
1. Reinicia el servicio en Railway (Settings → Restart)
2. Prueba hacer login desde el frontend
3. El endpoint `/sanctum/csrf-cookie` debería responder con 200 OK

## 🚨 Troubleshooting

### Error: "Cannot find the object 'sessions'"

**Causa**: La tabla no existe o está en otro esquema.

**Solución**: 
1. Verifica que ejecutaste el script correctamente
2. Verifica que estás en la base de datos correcta: `USE [wms_escasan];`
3. Verifica el esquema: `SELECT * FROM [dbo].[sessions];`

### Error: "Table 'sessions' already exists"

**Causa**: La tabla ya existe.

**Solución**: 
1. Verifica la estructura con el script de verificación
2. Si la estructura es incorrecta, puedes eliminarla y recrearla:
   ```sql
   DROP TABLE [dbo].[sessions];
   -- Luego ejecuta el script de creación
   ```

### Error: "Permission denied"

**Causa**: El usuario no tiene permisos para crear tablas.

**Solución**: 
1. Verifica que el usuario `wmsadmin` tenga permisos de `db_owner` o `db_ddladmin`
2. Si no, contacta al administrador de la base de datos

## 📌 Nota Importante

**El esquema `[dbo]` es importante en SQL Server**. Laravel por defecto busca las tablas en el esquema `dbo`, así que asegúrate de crear la tabla con `[dbo].[sessions]` explícitamente.

Si después de crear la tabla el error persiste, puede ser un problema de configuración de Laravel. Verifica:
- `SESSION_DRIVER=database` en Railway
- Que la conexión a la base de datos funcione correctamente
- Los logs de Railway para ver el error específico

