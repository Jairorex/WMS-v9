-- Script para agregar usuario de Windows a SQL Server
-- Ejecutar este script en SQL Server Management Studio como administrador

-- 1. Crear login para el usuario de Windows
CREATE LOGIN [JAIRO\jairo] FROM WINDOWS;
GO

-- 2. Dar permisos de sysadmin (para desarrollo)
ALTER SERVER ROLE sysadmin ADD MEMBER [JAIRO\jairo];
GO

-- 3. Crear la base de datos si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'wms_escasan')
BEGIN
    CREATE DATABASE wms_escasan;
END
GO

-- 4. Usar la base de datos
USE wms_escasan;
GO

-- 5. Crear el esquema wms
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'wms')
BEGIN
    EXEC('CREATE SCHEMA wms');
END
GO

-- 6. Dar permisos en la base de datos
CREATE USER [JAIRO\jairo] FOR LOGIN [JAIRO\jairo];
GO

-- 7. Dar permisos de db_owner
ALTER ROLE db_owner ADD MEMBER [JAIRO\jairo];
GO

PRINT 'Usuario de Windows agregado exitosamente a SQL Server';
PRINT 'Usuario: JAIRO\jairo';
PRINT 'Base de datos: wms_escasan';
PRINT 'Esquema: wms';
