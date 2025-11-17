-- Script para crear nueva base de datos wms_escasan_v2
-- Ejecutar en SQL Server Management Studio

-- 1. Crear nueva base de datos
CREATE DATABASE wms_escasan_v2;
GO

USE wms_escasan_v2;
GO

-- 2. Crear tablas en esquema dbo (por defecto)
CREATE TABLE dbo.roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(255),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE dbo.usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(255) NOT NULL,
    usuario NVARCHAR(50) UNIQUE NOT NULL,
    email NVARCHAR(255) UNIQUE NOT NULL,
    contrasena NVARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    activo BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (rol_id) REFERENCES dbo.roles(id_rol)
);

CREATE TABLE dbo.estados_producto (
    id_estado_producto INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(20) UNIQUE NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(255),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE dbo.productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(50) UNIQUE NOT NULL,
    nombre NVARCHAR(255) NOT NULL,
    descripcion NVARCHAR(500),
    unidad_medida NVARCHAR(20) NOT NULL,
    stock_minimo INT DEFAULT 0,
    estado_producto_id INT NOT NULL,
    activo BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (estado_producto_id) REFERENCES dbo.estados_producto(id_estado_producto)
);

-- Continuar con el resto de tablas...
-- (Este es un ejemplo, necesitarías crear todas las tablas)

PRINT 'Nueva base de datos wms_escasan_v2 creada con esquema dbo';
