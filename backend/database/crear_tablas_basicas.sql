-- ========================================
-- CREAR TABLAS BÁSICAS DEL SISTEMA WMS
-- ========================================

USE [wms_escasan];
GO

PRINT '🚀 Creando tablas básicas del sistema WMS...';
PRINT '==========================================';
GO

-- 1. Tabla de roles
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'roles')
BEGIN
    CREATE TABLE roles (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(50) NOT NULL UNIQUE,
        descripcion NVARCHAR(200) NULL,
        permisos NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla roles creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla roles ya existe';
END
GO

-- 2. Tabla de usuarios
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'usuarios')
BEGIN
    CREATE TABLE usuarios (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        rol_id INT NOT NULL,
        activo BIT NOT NULL DEFAULT 1,
        ultimo_login DATETIME2 NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_usuarios_rol FOREIGN KEY (rol_id) 
        REFERENCES roles (id)
    );
    PRINT '✅ Tabla usuarios creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla usuarios ya existe';
END
GO

-- 3. Tabla de productos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'productos')
BEGIN
    CREATE TABLE productos (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(200) NOT NULL,
        descripcion NVARCHAR(500) NULL,
        categoria NVARCHAR(100) NULL,
        precio DECIMAL(10,2) NULL,
        unidad_medida NVARCHAR(20) NOT NULL DEFAULT 'UNIDAD',
        stock_minimo DECIMAL(10,2) DEFAULT 0,
        stock_maximo DECIMAL(10,2) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla productos creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla productos ya existe';
END
GO

-- 4. Tabla de ubicaciones
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ubicaciones')
BEGIN
    CREATE TABLE ubicaciones (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(200) NULL,
        zona NVARCHAR(50) NULL,
        capacidad_maxima DECIMAL(10,2) NULL,
        capacidad_actual DECIMAL(10,2) DEFAULT 0,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla ubicaciones creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla ubicaciones ya existe';
END
GO

-- 5. Tabla de inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    CREATE TABLE inventario (
        id INT IDENTITY(1,1) PRIMARY KEY,
        producto_id INT NOT NULL,
        ubicacion_id INT NOT NULL,
        cantidad DECIMAL(10,2) NOT NULL DEFAULT 0,
        cantidad_reservada DECIMAL(10,2) DEFAULT 0,
        cantidad_disponible AS (cantidad - cantidad_reservada),
        fecha_ultima_actualizacion DATETIME2 DEFAULT GETDATE(),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_inventario_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id),
        CONSTRAINT FK_inventario_ubicacion FOREIGN KEY (ubicacion_id) 
        REFERENCES ubicaciones (id),
        CONSTRAINT UK_inventario_producto_ubicacion UNIQUE (producto_id, ubicacion_id)
    );
    PRINT '✅ Tabla inventario creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla inventario ya existe';
END
GO

-- 6. Tabla de tipos de tarea
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_tarea')
BEGIN
    CREATE TABLE tipos_tarea (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(200) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla tipos_tarea creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tipos_tarea ya existe';
END
GO

-- 7. Tabla de tareas
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tareas')
BEGIN
    CREATE TABLE tareas (
        id INT IDENTITY(1,1) PRIMARY KEY,
        titulo NVARCHAR(200) NOT NULL,
        descripcion NVARCHAR(500) NULL,
        tipo_tarea_id INT NOT NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
        prioridad NVARCHAR(20) NOT NULL DEFAULT 'MEDIA',
        usuario_asignado_id INT NULL,
        fecha_creacion DATETIME2 DEFAULT GETDATE(),
        fecha_vencimiento DATETIME2 NULL,
        fecha_completado DATETIME2 NULL,
        observaciones NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_tareas_tipo FOREIGN KEY (tipo_tarea_id) 
        REFERENCES tipos_tarea (id),
        CONSTRAINT FK_tareas_usuario FOREIGN KEY (usuario_asignado_id) 
        REFERENCES usuarios (id),
        CONSTRAINT CHK_tareas_estado CHECK (estado IN ('PENDIENTE', 'EN_PROGRESO', 'COMPLETADA', 'CANCELADA')),
        CONSTRAINT CHK_tareas_prioridad CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA'))
    );
    PRINT '✅ Tabla tareas creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tareas ya existe';
END
GO

-- 8. Tabla de incidencias
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'incidencias')
BEGIN
    CREATE TABLE incidencias (
        id INT IDENTITY(1,1) PRIMARY KEY,
        titulo NVARCHAR(200) NOT NULL,
        descripcion NVARCHAR(500) NULL,
        tipo NVARCHAR(50) NOT NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT 'ABIERTA',
        prioridad NVARCHAR(20) NOT NULL DEFAULT 'MEDIA',
        usuario_reporta_id INT NOT NULL,
        usuario_asignado_id INT NULL,
        fecha_reporte DATETIME2 DEFAULT GETDATE(),
        fecha_resolucion DATETIME2 NULL,
        solucion NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_incidencias_usuario_reporta FOREIGN KEY (usuario_reporta_id) 
        REFERENCES usuarios (id),
        CONSTRAINT FK_incidencias_usuario_asignado FOREIGN KEY (usuario_asignado_id) 
        REFERENCES usuarios (id),
        CONSTRAINT CHK_incidencias_estado CHECK (estado IN ('ABIERTA', 'EN_PROGRESO', 'RESUELTA', 'CERRADA')),
        CONSTRAINT CHK_incidencias_prioridad CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA', 'CRITICA'))
    );
    PRINT '✅ Tabla incidencias creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla incidencias ya existe';
END
GO

-- 9. Tabla de unidades de medida
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'unidad_de_medida')
BEGIN
    CREATE TABLE unidad_de_medida (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(10) NOT NULL UNIQUE,
        nombre NVARCHAR(50) NOT NULL,
        descripcion NVARCHAR(100) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla unidad_de_medida creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla unidad_de_medida ya existe';
END
GO

-- 10. Tabla de estados de producto
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'estados_producto')
BEGIN
    CREATE TABLE estados_producto (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(50) NOT NULL UNIQUE,
        descripcion NVARCHAR(100) NULL,
        color NVARCHAR(20) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla estados_producto creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla estados_producto ya existe';
END
GO

-- Crear índices para optimizar consultas
PRINT '';
PRINT '🔍 Creando índices...';

-- Índices para usuarios
CREATE NONCLUSTERED INDEX idx_usuarios_email ON usuarios(email);
CREATE NONCLUSTERED INDEX idx_usuarios_rol ON usuarios(rol_id);
CREATE NONCLUSTERED INDEX idx_usuarios_activo ON usuarios(activo);

-- Índices para productos
CREATE NONCLUSTERED INDEX idx_productos_codigo ON productos(codigo);
CREATE NONCLUSTERED INDEX idx_productos_categoria ON productos(categoria);
CREATE NONCLUSTERED INDEX idx_productos_activo ON productos(activo);

-- Índices para ubicaciones
CREATE NONCLUSTERED INDEX idx_ubicaciones_codigo ON ubicaciones(codigo);
CREATE NONCLUSTERED INDEX idx_ubicaciones_zona ON ubicaciones(zona);
CREATE NONCLUSTERED INDEX idx_ubicaciones_activo ON ubicaciones(activo);

-- Índices para inventario
CREATE NONCLUSTERED INDEX idx_inventario_producto ON inventario(producto_id);
CREATE NONCLUSTERED INDEX idx_inventario_ubicacion ON inventario(ubicacion_id);
CREATE NONCLUSTERED INDEX idx_inventario_fecha ON inventario(fecha_ultima_actualizacion);

-- Índices para tareas
CREATE NONCLUSTERED INDEX idx_tareas_estado ON tareas(estado);
CREATE NONCLUSTERED INDEX idx_tareas_prioridad ON tareas(prioridad);
CREATE NONCLUSTERED INDEX idx_tareas_usuario_asignado ON tareas(usuario_asignado_id);
CREATE NONCLUSTERED INDEX idx_tareas_fecha_vencimiento ON tareas(fecha_vencimiento);

-- Índices para incidencias
CREATE NONCLUSTERED INDEX idx_incidencias_estado ON incidencias(estado);
CREATE NONCLUSTERED INDEX idx_incidencias_prioridad ON incidencias(prioridad);
CREATE NONCLUSTERED INDEX idx_incidencias_usuario_reporta ON incidencias(usuario_reporta_id);
CREATE NONCLUSTERED INDEX idx_incidencias_fecha_reporte ON incidencias(fecha_reporte);

PRINT '✅ Índices creados exitosamente';

PRINT '';
PRINT '🎉 Tablas básicas creadas exitosamente!';
PRINT '=====================================';
PRINT '';
PRINT '📊 Tablas creadas:';
PRINT '   ✅ roles - Gestión de roles y permisos';
PRINT '   ✅ usuarios - Usuarios del sistema';
PRINT '   ✅ productos - Catálogo de productos';
PRINT '   ✅ ubicaciones - Ubicaciones del almacén';
PRINT '   ✅ inventario - Control de stock';
PRINT '   ✅ tipos_tarea - Tipos de tareas';
PRINT '   ✅ tareas - Gestión de tareas';
PRINT '   ✅ incidencias - Sistema de incidencias';
PRINT '   ✅ unidad_de_medida - Unidades de medida';
PRINT '   ✅ estados_producto - Estados de productos';
PRINT '';
PRINT '🔍 Índices creados para optimizar consultas';
PRINT '';
PRINT '📋 Próximo paso: Ejecutar script de módulos avanzados';
GO

