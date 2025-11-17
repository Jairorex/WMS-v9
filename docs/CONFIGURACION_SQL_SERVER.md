# Configuración de SQL Server para WMS Laravel

## Problema Actual
El error `TCP Provider: No se puede establecer una conexión ya que el equipo de destino denegó expresamente dicha conexión` indica que SQL Server no está ejecutándose o no está configurado para aceptar conexiones TCP.

## Pasos para Configurar SQL Server

### 1. Verificar que SQL Server esté ejecutándose
```cmd
# Verificar servicios de SQL Server
sc query MSSQLSERVER
# o
services.msc
```

### 2. Configurar SQL Server para aceptar conexiones TCP
1. Abrir **SQL Server Configuration Manager**
2. Expandir **SQL Server Network Configuration**
3. Seleccionar **Protocols for MSSQLSERVER**
4. Habilitar **TCP/IP** (clic derecho → Enable)
5. Doble clic en **TCP/IP** → Properties
6. En la pestaña **IP Addresses**:
   - Scroll hasta **IPAll**
   - **TCP Port**: 1433
   - **TCP Dynamic Ports**: (vacío)
7. **Reiniciar el servicio SQL Server**

### 3. Configurar Windows Firewall
```cmd
# Permitir SQL Server a través del firewall
netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=TCP localport=1433
```

### 4. Verificar configuración de autenticación
1. Abrir **SQL Server Management Studio**
2. Conectar al servidor
3. Clic derecho en el servidor → **Properties**
4. Pestaña **Security**:
   - **Server authentication**: **SQL Server and Windows Authentication mode**

### 5. Crear la base de datos
```sql
-- Ejecutar en SQL Server Management Studio
CREATE DATABASE wms_escasan;
GO

USE wms_escasan;
GO

-- Crear el esquema wms
CREATE SCHEMA wms;
GO
```

### 6. Ejecutar el script de base de datos
```cmd
# Usando sqlcmd
sqlcmd -S localhost -E -i "C:\Users\jairo\Desktop\WMS-v9\DATABASE_COMPLETE_SCRIPT.sql"
```

### 7. Configurar Laravel para autenticación de Windows
El archivo `.env` debe tener:
```env
DB_CONNECTION=sqlsrv
DB_HOST=127.0.0.1
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=
DB_PASSWORD=
```

Y el archivo `config/database.php` debe tener:
```php
'sqlsrv' => [
    'driver' => 'sqlsrv',
    'host' => env('DB_HOST', 'localhost'),
    'port' => env('DB_PORT', '1433'),
    'database' => env('DB_DATABASE', 'laravel'),
    'username' => env('DB_USERNAME', ''),
    'password' => env('DB_PASSWORD', ''),
    'charset' => env('DB_CHARSET', 'utf8'),
    'prefix' => '',
    'prefix_indexes' => true,
    'options' => [
        'TrustServerCertificate' => true,
    ],
],
```

## Comandos de Verificación

### Verificar que SQL Server esté ejecutándose
```cmd
netstat -an | findstr :1433
```

### Probar conexión con sqlcmd
```cmd
sqlcmd -S localhost -E
```

### Probar conexión desde Laravel
```bash
cd backend
php artisan migrate:status
```

## Solución Alternativa: Usar SQL Server Express LocalDB

Si tienes problemas con SQL Server completo, puedes usar LocalDB:

1. Instalar **SQL Server Express LocalDB**
2. Cambiar la configuración en `.env`:
```env
DB_CONNECTION=sqlsrv
DB_HOST=(localdb)\MSSQLLocalDB
DB_PORT=
DB_DATABASE=wms_escasan
DB_USERNAME=
DB_PASSWORD=
```

## Notas Importantes

1. **Autenticación de Windows**: Laravel usará las credenciales del usuario actual de Windows
2. **Puerto 1433**: Debe estar abierto y disponible
3. **Servicio SQL Server**: Debe estar ejecutándose
4. **Protocolo TCP/IP**: Debe estar habilitado
5. **Firewall**: Debe permitir conexiones en el puerto 1433

Una vez configurado SQL Server correctamente, el backend Laravel debería poder conectarse y ejecutar las migraciones sin problemas.
