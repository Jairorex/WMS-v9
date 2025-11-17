# Instalación de SQL Server LocalDB para WMS Laravel

## Problema Actual
No tienes SQL Server ejecutándose ni LocalDB instalado. LocalDB es la opción más simple para desarrollo.

## Opción 1: Instalar SQL Server LocalDB (Recomendado para desarrollo)

### 1. Descargar SQL Server Express LocalDB
- Ir a: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
- Descargar **SQL Server Express LocalDB**
- Ejecutar el instalador

### 2. Verificar instalación
```cmd
sqllocaldb info
```

### 3. Crear una instancia local
```cmd
sqllocaldb create "WMSLocalDB"
sqllocaldb start "WMSLocalDB"
```

### 4. Configurar Laravel para LocalDB
Actualizar `.env`:
```env
DB_CONNECTION=sqlsrv
DB_HOST=(localdb)\WMSLocalDB
DB_PORT=
DB_DATABASE=wms_escasan
DB_USERNAME=
DB_PASSWORD=
```

## Opción 2: Instalar SQL Server Express Completo

### 1. Descargar SQL Server Express
- Ir a: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
- Descargar **SQL Server Express**
- Durante la instalación:
  - Seleccionar **Basic installation**
  - Habilitar **Mixed Mode Authentication**
  - Configurar contraseña para `sa`

### 2. Configurar TCP/IP
1. Abrir **SQL Server Configuration Manager**
2. Expandir **SQL Server Network Configuration**
3. Seleccionar **Protocols for SQLEXPRESS**
4. Habilitar **TCP/IP**
5. Doble clic en **TCP/IP** → Properties
6. En **IP Addresses**:
   - Scroll hasta **IPAll**
   - **TCP Port**: 1433
7. **Reiniciar SQL Server**

### 3. Configurar Laravel
Actualizar `.env`:
```env
DB_CONNECTION=sqlsrv
DB_HOST=127.0.0.1\SQLEXPRESS
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=sa
DB_PASSWORD=tu_password_aqui
```

## Opción 3: Usar Docker (Alternativa)

### 1. Instalar Docker Desktop
- Descargar desde: https://www.docker.com/products/docker-desktop

### 2. Ejecutar SQL Server en Docker
```cmd
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" -p 1433:1433 --name sqlserver -d mcr.microsoft.com/mssql/server:2022-latest
```

### 3. Configurar Laravel
Actualizar `.env`:
```env
DB_CONNECTION=sqlsrv
DB_HOST=127.0.0.1
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=sa
DB_PASSWORD=YourStrong@Passw0rd
```

## Pasos Comunes Después de Instalar

### 1. Crear la base de datos
```sql
-- Conectar con SQL Server Management Studio o sqlcmd
CREATE DATABASE wms_escasan;
GO

USE wms_escasan;
GO

CREATE SCHEMA wms;
GO
```

### 2. Ejecutar el script de datos
```cmd
sqlcmd -S (localdb)\WMSLocalDB -E -i "C:\Users\jairo\Desktop\WMS-v9\DATABASE_COMPLETE_SCRIPT.sql"
```

### 3. Probar conexión desde Laravel
```bash
cd backend
php artisan migrate:status
```

## Comandos de Verificación

### Verificar servicios SQL Server
```cmd
sc query MSSQLSERVER
sc query MSSQL$SQLEXPRESS
```

### Verificar LocalDB
```cmd
sqllocaldb info
sqllocaldb info MSSQLLocalDB
```

### Probar conexión con sqlcmd
```cmd
sqlcmd -S (localdb)\MSSQLLocalDB -E
sqlcmd -S 127.0.0.1\SQLEXPRESS -U sa -P tu_password
```

## Recomendación

Para desarrollo, te recomiendo **SQL Server LocalDB** porque:
- Es más ligero
- No requiere configuración compleja
- Se instala rápidamente
- Funciona perfectamente con Laravel

Una vez instalado LocalDB, el backend Laravel debería conectarse sin problemas.
