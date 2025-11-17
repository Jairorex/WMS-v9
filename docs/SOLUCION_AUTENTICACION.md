# Solución: Agregar Usuario de Windows a SQL Server

## Problema Identificado
El usuario `JAIRO\jairo` no tiene permisos en SQL Server, por eso falla la autenticación de Windows.

## Solución

### Paso 1: Ejecutar Script SQL
1. Abrir **SQL Server Management Studio**
2. Conectar como administrador (usuario `sa` o administrador de Windows)
3. Abrir el archivo `backend/agregar_usuario_windows.sql`
4. Ejecutar el script completo

### Paso 2: Verificar Conexión
Después de ejecutar el script, probar la conexión:

```bash
cd backend
php artisan migrate:status
```

## Alternativa: Crear Usuario SQL Server

Si prefieres usar autenticación SQL Server en lugar de Windows:

### 1. Crear usuario SQL Server
```sql
-- Ejecutar en SQL Server Management Studio
CREATE LOGIN wms_user WITH PASSWORD = 'WmsPassword123!';
GO

USE wms_escasan;
GO

CREATE USER wms_user FOR LOGIN wms_user;
GO

ALTER ROLE db_owner ADD MEMBER wms_user;
GO
```

### 2. Configurar Laravel
Actualizar `.env`:
```env
DB_CONNECTION=sqlsrv
DB_HOST=127.0.0.1
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wms_user
DB_PASSWORD=WmsPassword123!
```

## Verificación

### Probar conexión con sqlcmd
```cmd
-- Con autenticación Windows
sqlcmd -S 127.0.0.1 -E

-- Con autenticación SQL Server
sqlcmd -S 127.0.0.1 -U wms_user -P WmsPassword123!
```

### Probar desde Laravel
```bash
cd backend
php artisan migrate:status
```

## Notas Importantes

1. **Autenticación Windows**: Requiere que el usuario de Windows tenga permisos en SQL Server
2. **Autenticación SQL Server**: Más simple, solo requiere usuario/contraseña
3. **Permisos**: El usuario necesita permisos de `db_owner` o `sysadmin` para crear tablas
4. **Base de datos**: Debe existir la base de datos `wms_escasan` antes de ejecutar migraciones

Una vez configurado el usuario, el backend Laravel debería conectarse sin problemas.
