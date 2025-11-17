-- Script para ejecutar todas las migraciones del WMS avanzado
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

PRINT '🚀 Iniciando migraciones del WMS avanzado...';
PRINT '==============================================';
GO

-- 1. Gestión avanzada de ubicaciones
PRINT '';
PRINT '📍 PASO 1: Creando gestión avanzada de ubicaciones...';
PRINT '---------------------------------------------------';
GO

-- Crear tabla tipos_ubicacion
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_ubicacion')
BEGIN
    CREATE TABLE tipos_ubicacion (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(20) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla tipos_ubicacion creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tipos_ubicacion ya existe';
END
GO

-- Crear tabla zonas_almacen
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'zonas_almacen')
BEGIN
    CREATE TABLE zonas_almacen (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(20) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        capacidad_total INT,
        tipo_almacenamiento_preferido NVARCHAR(50),
        temperatura_min DECIMAL(5,2),
        temperatura_max DECIMAL(5,2),
        humedad_min DECIMAL(5,2),
        humedad_max DECIMAL(5,2),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla zonas_almacen creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla zonas_almacen ya existe';
END
GO

-- Agregar columnas a ubicaciones
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'tipo_ubicacion_id')
BEGIN
    ALTER TABLE ubicaciones ADD tipo_ubicacion_id INT;
    PRINT '✅ Columna tipo_ubicacion_id agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna tipo_ubicacion_id ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'zona_id')
BEGIN
    ALTER TABLE ubicaciones ADD zona_id INT;
    PRINT '✅ Columna zona_id agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna zona_id ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'coordenada_x')
BEGIN
    ALTER TABLE ubicaciones ADD coordenada_x DECIMAL(10,2);
    PRINT '✅ Columna coordenada_x agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna coordenada_x ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'coordenada_y')
BEGIN
    ALTER TABLE ubicaciones ADD coordenada_y DECIMAL(10,2);
    PRINT '✅ Columna coordenada_y agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna coordenada_y ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'coordenada_z')
BEGIN
    ALTER TABLE ubicaciones ADD coordenada_z DECIMAL(10,2);
    PRINT '✅ Columna coordenada_z agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna coordenada_z ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'temperatura_min')
BEGIN
    ALTER TABLE ubicaciones ADD temperatura_min DECIMAL(5,2);
    PRINT '✅ Columna temperatura_min agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna temperatura_min ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'temperatura_max')
BEGIN
    ALTER TABLE ubicaciones ADD temperatura_max DECIMAL(5,2);
    PRINT '✅ Columna temperatura_max agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna temperatura_max ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'humedad_min')
BEGIN
    ALTER TABLE ubicaciones ADD humedad_min DECIMAL(5,2);
    PRINT '✅ Columna humedad_min agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna humedad_min ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'humedad_max')
BEGIN
    ALTER TABLE ubicaciones ADD humedad_max DECIMAL(5,2);
    PRINT '✅ Columna humedad_max agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna humedad_max ya existe en ubicaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ubicaciones' AND COLUMN_NAME = 'activo')
BEGIN
    ALTER TABLE ubicaciones ADD activo BIT NOT NULL DEFAULT 1;
    PRINT '✅ Columna activo agregada a ubicaciones';
END
ELSE
BEGIN
    PRINT '⚠️ Columna activo ya existe en ubicaciones';
END
GO

-- Crear claves foráneas para ubicaciones
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_ubicaciones_tipo_ubicacion')
BEGIN
    ALTER TABLE ubicaciones ADD CONSTRAINT FK_ubicaciones_tipo_ubicacion 
    FOREIGN KEY (tipo_ubicacion_id) REFERENCES tipos_ubicacion(id);
    PRINT '✅ Clave foránea FK_ubicaciones_tipo_ubicacion creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_ubicaciones_tipo_ubicacion ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_ubicaciones_zona')
BEGIN
    ALTER TABLE ubicaciones ADD CONSTRAINT FK_ubicaciones_zona 
    FOREIGN KEY (zona_id) REFERENCES zonas_almacen(id);
    PRINT '✅ Clave foránea FK_ubicaciones_zona creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_ubicaciones_zona ya existe';
END
GO

-- Insertar datos iniciales para tipos de ubicación
IF NOT EXISTS (SELECT * FROM tipos_ubicacion WHERE codigo = 'ESTANTERIA')
BEGIN
    INSERT INTO tipos_ubicacion (codigo, nombre, descripcion) VALUES
    ('ESTANTERIA', 'Estantería', 'Ubicación en estantería'),
    ('SUELO', 'Suelo', 'Ubicación en el suelo'),
    ('REFRIGERADO', 'Refrigerado', 'Ubicación refrigerada'),
    ('CONGELADO', 'Congelado', 'Ubicación congelada'),
    ('PELIGROSO', 'Peligroso', 'Ubicación para productos peligrosos'),
    ('FRAGIL', 'Frágil', 'Ubicación para productos frágiles');
    PRINT '✅ Datos iniciales de tipos_ubicacion insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Datos iniciales de tipos_ubicacion ya existen';
END
GO

-- Insertar datos iniciales para zonas de almacén
IF NOT EXISTS (SELECT * FROM zonas_almacen WHERE codigo = 'ZONA_A')
BEGIN
    INSERT INTO zonas_almacen (codigo, nombre, descripcion, capacidad_total, tipo_almacenamiento_preferido, temperatura_min, temperatura_max, humedad_min, humedad_max) VALUES
    ('ZONA_A', 'Zona A - Ambiente', 'Zona de almacenamiento a temperatura ambiente', 1000, 'ESTANTERIA', 15.00, 25.00, 40.00, 60.00),
    ('ZONA_B', 'Zona B - Refrigerado', 'Zona de almacenamiento refrigerado', 500, 'REFRIGERADO', 2.00, 8.00, 30.00, 50.00),
    ('ZONA_C', 'Zona C - Congelado', 'Zona de almacenamiento congelado', 300, 'CONGELADO', -25.00, -15.00, 20.00, 40.00),
    ('ZONA_D', 'Zona D - Peligroso', 'Zona de almacenamiento para productos peligrosos', 200, 'PELIGROSO', 10.00, 30.00, 30.00, 70.00),
    ('ZONA_E', 'Zona E - Frágil', 'Zona de almacenamiento para productos frágiles', 150, 'FRAGIL', 15.00, 25.00, 40.00, 60.00);
    PRINT '✅ Datos iniciales de zonas_almacen insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Datos iniciales de zonas_almacen ya existen';
END
GO

-- 2. Sistema de lotes y trazabilidad
PRINT '';
PRINT '📋 PASO 2: Creando sistema de lotes y trazabilidad...';
PRINT '---------------------------------------------------';
GO

-- Crear tabla lotes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    CREATE TABLE lotes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo_lote NVARCHAR(50) NOT NULL UNIQUE,
        producto_id INT NOT NULL,
        cantidad_inicial DECIMAL(10,2) NOT NULL,
        cantidad_disponible DECIMAL(10,2) NOT NULL,
        cantidad_reservada DECIMAL(10,2) DEFAULT 0,
        fecha_fabricacion DATE,
        fecha_vencimiento DATE,
        fecha_caducidad DATE,
        estado NVARCHAR(20) NOT NULL DEFAULT 'disponible',
        ubicacion_id INT,
        precio_unitario DECIMAL(10,2),
        proveedor NVARCHAR(100),
        numero_factura NVARCHAR(50),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_lotes_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
        CONSTRAINT FK_lotes_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id),
        CONSTRAINT CHK_lotes_estado CHECK (estado IN ('disponible', 'reservado', 'agotado', 'vencido', 'defectuoso'))
    );
    PRINT '✅ Tabla lotes creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla lotes ya existe';
END
GO

-- Crear tabla movimientos_inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
    CREATE TABLE movimientos_inventario (
        id INT IDENTITY(1,1) PRIMARY KEY,
        producto_id INT NOT NULL,
        ubicacion_id INT NOT NULL,
        lote_id INT,
        numero_serie_id INT,
        tipo_movimiento NVARCHAR(20) NOT NULL,
        cantidad DECIMAL(10,2) NOT NULL,
        precio_unitario DECIMAL(10,2),
        fecha_movimiento DATETIME2 NOT NULL DEFAULT GETDATE(),
        usuario_id INT NOT NULL,
        referencia NVARCHAR(100),
        observaciones NVARCHAR(500),
        motivo NVARCHAR(200),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_movimientos_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
        CONSTRAINT FK_movimientos_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id),
        CONSTRAINT FK_movimientos_lote FOREIGN KEY (lote_id) REFERENCES lotes(id),
        CONSTRAINT FK_movimientos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_movimientos_tipo CHECK (tipo_movimiento IN ('entrada', 'salida', 'transferencia', 'ajuste', 'reserva', 'liberacion'))
    );
    PRINT '✅ Tabla movimientos_inventario creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla movimientos_inventario ya existe';
END
GO

-- Crear tabla numeros_serie
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
BEGIN
    CREATE TABLE numeros_serie (
        id INT IDENTITY(1,1) PRIMARY KEY,
        producto_id INT NOT NULL,
        ubicacion_id INT NOT NULL,
        numero_serie NVARCHAR(100) NOT NULL UNIQUE,
        estado NVARCHAR(20) NOT NULL DEFAULT 'disponible',
        fecha_fabricacion DATE,
        fecha_garantia DATE,
        usuario_id INT NOT NULL,
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_numeros_serie_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
        CONSTRAINT FK_numeros_serie_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id),
        CONSTRAINT FK_numeros_serie_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_numeros_serie_estado CHECK (estado IN ('disponible', 'reservado', 'en_uso', 'defectuoso', 'perdido'))
    );
    PRINT '✅ Tabla numeros_serie creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla numeros_serie ya existe';
END
GO

-- Crear tabla trazabilidad_productos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
BEGIN
    CREATE TABLE trazabilidad_productos (
        id INT IDENTITY(1,1) PRIMARY KEY,
        producto_id INT NOT NULL,
        lote_id INT,
        numero_serie_id INT,
        ubicacion_id INT,
        tipo_evento NVARCHAR(30) NOT NULL,
        fecha_evento DATETIME2 NOT NULL DEFAULT GETDATE(),
        cantidad DECIMAL(10,2),
        precio_unitario DECIMAL(10,2),
        usuario_id INT NOT NULL,
        referencia NVARCHAR(100),
        observaciones NVARCHAR(500),
        datos_adicionales NVARCHAR(MAX),
        temperatura DECIMAL(5,2),
        humedad DECIMAL(5,2),
        presion DECIMAL(8,2),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_trazabilidad_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
        CONSTRAINT FK_trazabilidad_lote FOREIGN KEY (lote_id) REFERENCES lotes(id),
        CONSTRAINT FK_trazabilidad_numero_serie FOREIGN KEY (numero_serie_id) REFERENCES numeros_serie(id),
        CONSTRAINT FK_trazabilidad_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id),
        CONSTRAINT FK_trazabilidad_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_trazabilidad_tipo_evento CHECK (tipo_evento IN ('entrada', 'salida', 'transferencia', 'ajuste', 'reserva', 'liberacion', 'inspeccion', 'calibracion', 'mantenimiento'))
    );
    PRINT '✅ Tabla trazabilidad_productos creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla trazabilidad_productos ya existe';
END
GO

-- Agregar columnas a inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'lote_id')
BEGIN
    ALTER TABLE inventario ADD lote_id INT;
    PRINT '✅ Columna lote_id agregada a inventario';
END
ELSE
BEGIN
    PRINT '⚠️ Columna lote_id ya existe en inventario';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'numero_serie_id')
BEGIN
    ALTER TABLE inventario ADD numero_serie_id INT;
    PRINT '✅ Columna numero_serie_id agregada a inventario';
END
ELSE
BEGIN
    PRINT '⚠️ Columna numero_serie_id ya existe en inventario';
END
GO

-- Crear claves foráneas para inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_inventario_lote')
BEGIN
    ALTER TABLE inventario ADD CONSTRAINT FK_inventario_lote 
    FOREIGN KEY (lote_id) REFERENCES lotes(id);
    PRINT '✅ Clave foránea FK_inventario_lote creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_inventario_lote ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_inventario_numero_serie')
BEGIN
    ALTER TABLE inventario ADD CONSTRAINT FK_inventario_numero_serie 
    FOREIGN KEY (numero_serie_id) REFERENCES numeros_serie(id);
    PRINT '✅ Clave foránea FK_inventario_numero_serie creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_inventario_numero_serie ya existe';
END
GO

-- Crear índices para optimizar consultas
CREATE NONCLUSTERED INDEX idx_lotes_producto ON lotes(producto_id);
CREATE NONCLUSTERED INDEX idx_lotes_ubicacion ON lotes(ubicacion_id);
CREATE NONCLUSTERED INDEX idx_lotes_fecha_caducidad ON lotes(fecha_caducidad);
CREATE NONCLUSTERED INDEX idx_lotes_estado ON lotes(estado);

CREATE NONCLUSTERED INDEX idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE NONCLUSTERED INDEX idx_movimientos_ubicacion ON movimientos_inventario(ubicacion_id);
CREATE NONCLUSTERED INDEX idx_movimientos_lote ON movimientos_inventario(lote_id);
CREATE NONCLUSTERED INDEX idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento);
CREATE NONCLUSTERED INDEX idx_movimientos_tipo ON movimientos_inventario(tipo_movimiento);

CREATE NONCLUSTERED INDEX idx_numeros_serie_producto ON numeros_serie(producto_id);
CREATE NONCLUSTERED INDEX idx_numeros_serie_ubicacion ON numeros_serie(ubicacion_id);
CREATE NONCLUSTERED INDEX idx_numeros_serie_estado ON numeros_serie(estado);

CREATE NONCLUSTERED INDEX idx_trazabilidad_producto ON trazabilidad_productos(producto_id);
CREATE NONCLUSTERED INDEX idx_trazabilidad_lote ON trazabilidad_productos(lote_id);
CREATE NONCLUSTERED INDEX idx_trazabilidad_fecha ON trazabilidad_productos(fecha_evento);
CREATE NONCLUSTERED INDEX idx_trazabilidad_tipo ON trazabilidad_productos(tipo_evento);

PRINT '✅ Índices creados para optimizar consultas';
GO

-- 3. Sistema de picking inteligente
PRINT '';
PRINT '🎯 PASO 3: Creando sistema de picking inteligente...';
PRINT '---------------------------------------------------';
GO

-- Crear tabla oleadas_picking
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'oleadas_picking')
BEGIN
    CREATE TABLE oleadas_picking (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo_oleada NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        estado NVARCHAR(20) NOT NULL DEFAULT 'creada',
        fecha_creacion DATETIME2 DEFAULT GETDATE(),
        fecha_inicio DATETIME2,
        fecha_fin DATETIME2,
        operario_asignado INT,
        prioridad INT DEFAULT 1,
        zona_id INT,
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_oleadas_operario FOREIGN KEY (operario_asignado) REFERENCES usuarios(id),
        CONSTRAINT FK_oleadas_zona FOREIGN KEY (zona_id) REFERENCES zonas_almacen(id),
        CONSTRAINT CHK_oleadas_estado CHECK (estado IN ('creada', 'en_proceso', 'completada', 'cancelada'))
    );
    PRINT '✅ Tabla oleadas_picking creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla oleadas_picking ya existe';
END
GO

-- Crear tabla pedidos_picking
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'pedidos_picking')
BEGIN
    CREATE TABLE pedidos_picking (
        id INT IDENTITY(1,1) PRIMARY KEY,
        oleada_id INT NOT NULL,
        codigo_pedido NVARCHAR(50) NOT NULL,
        cliente NVARCHAR(100),
        estado NVARCHAR(20) NOT NULL DEFAULT 'pendiente',
        fecha_creacion DATETIME2 DEFAULT GETDATE(),
        fecha_inicio DATETIME2,
        fecha_fin DATETIME2,
        operario_asignado INT,
        prioridad INT DEFAULT 1,
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_pedidos_oleada FOREIGN KEY (oleada_id) REFERENCES oleadas_picking(id),
        CONSTRAINT FK_pedidos_operario FOREIGN KEY (operario_asignado) REFERENCES usuarios(id),
        CONSTRAINT CHK_pedidos_estado CHECK (estado IN ('pendiente', 'en_proceso', 'completado', 'cancelado'))
    );
    PRINT '✅ Tabla pedidos_picking creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla pedidos_picking ya existe';
END
GO

-- Crear tabla pedidos_picking_detalle
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'pedidos_picking_detalle')
BEGIN
    CREATE TABLE pedidos_picking_detalle (
        id INT IDENTITY(1,1) PRIMARY KEY,
        pedido_id INT NOT NULL,
        producto_id INT NOT NULL,
        cantidad_solicitada DECIMAL(10,2) NOT NULL,
        cantidad_pickeada DECIMAL(10,2) DEFAULT 0,
        ubicacion_id INT NOT NULL,
        lote_id INT,
        estado NVARCHAR(20) NOT NULL DEFAULT 'pendiente',
        fecha_inicio DATETIME2,
        fecha_fin DATETIME2,
        operario_asignado INT,
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_detalles_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos_picking(id),
        CONSTRAINT FK_detalles_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
        CONSTRAINT FK_detalles_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id),
        CONSTRAINT FK_detalles_lote FOREIGN KEY (lote_id) REFERENCES lotes(id),
        CONSTRAINT FK_detalles_operario FOREIGN KEY (operario_asignado) REFERENCES usuarios(id),
        CONSTRAINT CHK_detalles_estado CHECK (estado IN ('pendiente', 'en_proceso', 'completado', 'cancelado'))
    );
    PRINT '✅ Tabla pedidos_picking_detalle creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla pedidos_picking_detalle ya existe';
END
GO

-- Crear tabla rutas_picking
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'rutas_picking')
BEGIN
    CREATE TABLE rutas_picking (
        id INT IDENTITY(1,1) PRIMARY KEY,
        oleada_id INT NOT NULL,
        operario_id INT NOT NULL,
        nombre_ruta NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        estado NVARCHAR(20) NOT NULL DEFAULT 'creada',
        fecha_creacion DATETIME2 DEFAULT GETDATE(),
        fecha_inicio DATETIME2,
        fecha_fin DATETIME2,
        tiempo_estimado INT,
        tiempo_real INT,
        distancia_total DECIMAL(10,2),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_rutas_oleada FOREIGN KEY (oleada_id) REFERENCES oleadas_picking(id),
        CONSTRAINT FK_rutas_operario FOREIGN KEY (operario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_rutas_estado CHECK (estado IN ('creada', 'en_proceso', 'completada', 'cancelada'))
    );
    PRINT '✅ Tabla rutas_picking creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla rutas_picking ya existe';
END
GO

-- Crear tabla estadisticas_picking
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'estadisticas_picking')
BEGIN
    CREATE TABLE estadisticas_picking (
        id INT IDENTITY(1,1) PRIMARY KEY,
        operario_id INT NOT NULL,
        oleada_id INT,
        pedido_id INT,
        fecha DATE NOT NULL,
        tiempo_total INT,
        tiempo_picking INT,
        tiempo_transporte INT,
        cantidad_items INT,
        cantidad_pedidos INT,
        eficiencia DECIMAL(5,2),
        precision_picking DECIMAL(5,2),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_estadisticas_operario FOREIGN KEY (operario_id) REFERENCES usuarios(id),
        CONSTRAINT FK_estadisticas_oleada FOREIGN KEY (oleada_id) REFERENCES oleadas_picking(id),
        CONSTRAINT FK_estadisticas_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos_picking(id)
    );
    PRINT '✅ Tabla estadisticas_picking creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla estadisticas_picking ya existe';
END
GO

-- Crear índices para picking inteligente
CREATE NONCLUSTERED INDEX idx_oleadas_operario ON oleadas_picking(operario_asignado);
CREATE NONCLUSTERED INDEX idx_oleadas_estado ON oleadas_picking(estado);
CREATE NONCLUSTERED INDEX idx_oleadas_fecha ON oleadas_picking(fecha_creacion);

CREATE NONCLUSTERED INDEX idx_pedidos_oleada ON pedidos_picking(oleada_id);
CREATE NONCLUSTERED INDEX idx_pedidos_operario ON pedidos_picking(operario_asignado);
CREATE NONCLUSTERED INDEX idx_pedidos_estado ON pedidos_picking(estado);

CREATE NONCLUSTERED INDEX idx_detalles_pedido ON pedidos_picking_detalle(pedido_id);
CREATE NONCLUSTERED INDEX idx_detalles_producto ON pedidos_picking_detalle(producto_id);
CREATE NONCLUSTERED INDEX idx_detalles_ubicacion ON pedidos_picking_detalle(ubicacion_id);
CREATE NONCLUSTERED INDEX idx_detalles_estado ON pedidos_picking_detalle(estado);

CREATE NONCLUSTERED INDEX idx_rutas_oleada ON rutas_picking(oleada_id);
CREATE NONCLUSTERED INDEX idx_rutas_operario ON rutas_picking(operario_id);
CREATE NONCLUSTERED INDEX idx_rutas_estado ON rutas_picking(estado);

CREATE NONCLUSTERED INDEX idx_estadisticas_operario ON estadisticas_picking(operario_id);
CREATE NONCLUSTERED INDEX idx_estadisticas_fecha ON estadisticas_picking(fecha);

PRINT '✅ Índices creados para picking inteligente';
GO

-- 4. Sistema de incidencias avanzado
PRINT '';
PRINT '⚠️ PASO 4: Creando sistema de incidencias avanzado...';
PRINT '---------------------------------------------------';
GO

-- Crear tabla tipos_incidencia
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_incidencia')
BEGIN
    CREATE TABLE tipos_incidencia (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(20) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        categoria NVARCHAR(50),
        tiempo_resolucion_estimado INT,
        prioridad_default NVARCHAR(20),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla tipos_incidencia creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tipos_incidencia ya existe';
END
GO

-- Crear tabla seguimiento_incidencias
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'seguimiento_incidencias')
BEGIN
    CREATE TABLE seguimiento_incidencias (
        id INT IDENTITY(1,1) PRIMARY KEY,
        incidencia_id INT NOT NULL,
        usuario_id INT NOT NULL,
        accion NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        fecha_accion DATETIME2 DEFAULT GETDATE(),
        estado_anterior NVARCHAR(20),
        estado_nuevo NVARCHAR(20),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_seguimiento_incidencia FOREIGN KEY (incidencia_id) REFERENCES incidencias(id),
        CONSTRAINT FK_seguimiento_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
    PRINT '✅ Tabla seguimiento_incidencias creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla seguimiento_incidencias ya existe';
END
GO

-- Crear tabla plantillas_resolucion
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_resolucion')
BEGIN
    CREATE TABLE plantillas_resolucion (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tipo_incidencia_id INT NOT NULL,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        pasos_resolucion NVARCHAR(MAX),
        tiempo_estimado INT,
        recursos_necesarios NVARCHAR(500),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_plantillas_tipo FOREIGN KEY (tipo_incidencia_id) REFERENCES tipos_incidencia(id)
    );
    PRINT '✅ Tabla plantillas_resolucion creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla plantillas_resolucion ya existe';
END
GO

-- Crear tabla metricas_incidencias
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'metricas_incidencias')
BEGIN
    CREATE TABLE metricas_incidencias (
        id INT IDENTITY(1,1) PRIMARY KEY,
        incidencia_id INT NOT NULL,
        tipo_metrica NVARCHAR(50) NOT NULL,
        valor DECIMAL(10,2),
        unidad NVARCHAR(20),
        fecha_medicion DATETIME2 DEFAULT GETDATE(),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_metricas_incidencia FOREIGN KEY (incidencia_id) REFERENCES incidencias(id)
    );
    PRINT '✅ Tabla metricas_incidencias creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla metricas_incidencias ya existe';
END
GO

-- Agregar columnas a incidencias
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'tipo_incidencia_id')
BEGIN
    ALTER TABLE incidencias ADD tipo_incidencia_id INT;
    PRINT '✅ Columna tipo_incidencia_id agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna tipo_incidencia_id ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'prioridad')
BEGIN
    ALTER TABLE incidencias ADD prioridad NVARCHAR(20) DEFAULT 'media';
    PRINT '✅ Columna prioridad agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna prioridad ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'categoria')
BEGIN
    ALTER TABLE incidencias ADD categoria NVARCHAR(50);
    PRINT '✅ Columna categoria agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna categoria ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'fecha_estimada_resolucion')
BEGIN
    ALTER TABLE incidencias ADD fecha_estimada_resolucion DATETIME2;
    PRINT '✅ Columna fecha_estimada_resolucion agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna fecha_estimada_resolucion ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'fecha_resolucion_real')
BEGIN
    ALTER TABLE incidencias ADD fecha_resolucion_real DATETIME2;
    PRINT '✅ Columna fecha_resolucion_real agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna fecha_resolucion_real ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'tiempo_resolucion_estimado')
BEGIN
    ALTER TABLE incidencias ADD tiempo_resolucion_estimado INT;
    PRINT '✅ Columna tiempo_resolucion_estimado agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna tiempo_resolucion_estimado ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'tiempo_resolucion_real')
BEGIN
    ALTER TABLE incidencias ADD tiempo_resolucion_real INT;
    PRINT '✅ Columna tiempo_resolucion_real agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna tiempo_resolucion_real ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'operario_resolucion')
BEGIN
    ALTER TABLE incidencias ADD operario_resolucion INT;
    PRINT '✅ Columna operario_resolucion agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna operario_resolucion ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'supervisor_aprobacion')
BEGIN
    ALTER TABLE incidencias ADD supervisor_aprobacion INT;
    PRINT '✅ Columna supervisor_aprobacion agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna supervisor_aprobacion ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'fecha_aprobacion')
BEGIN
    ALTER TABLE incidencias ADD fecha_aprobacion DATETIME2;
    PRINT '✅ Columna fecha_aprobacion agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna fecha_aprobacion ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'evidencia_fotos')
BEGIN
    ALTER TABLE incidencias ADD evidencia_fotos NVARCHAR(MAX);
    PRINT '✅ Columna evidencia_fotos agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna evidencia_fotos ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'acciones_correctivas')
BEGIN
    ALTER TABLE incidencias ADD acciones_correctivas NVARCHAR(MAX);
    PRINT '✅ Columna acciones_correctivas agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna acciones_correctivas ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'acciones_preventivas')
BEGIN
    ALTER TABLE incidencias ADD acciones_preventivas NVARCHAR(MAX);
    PRINT '✅ Columna acciones_preventivas agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna acciones_preventivas ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'costo_estimado')
BEGIN
    ALTER TABLE incidencias ADD costo_estimado DECIMAL(10,2);
    PRINT '✅ Columna costo_estimado agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna costo_estimado ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'costo_real')
BEGIN
    ALTER TABLE incidencias ADD costo_real DECIMAL(10,2);
    PRINT '✅ Columna costo_real agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna costo_real ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'impacto_operaciones')
BEGIN
    ALTER TABLE incidencias ADD impacto_operaciones NVARCHAR(200);
    PRINT '✅ Columna impacto_operaciones agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna impacto_operaciones ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'recurrencia')
BEGIN
    ALTER TABLE incidencias ADD recurrencia BIT DEFAULT 0;
    PRINT '✅ Columna recurrencia agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna recurrencia ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'incidencia_padre_id')
BEGIN
    ALTER TABLE incidencias ADD incidencia_padre_id INT;
    PRINT '✅ Columna incidencia_padre_id agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna incidencia_padre_id ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'escalado')
BEGIN
    ALTER TABLE incidencias ADD escalado BIT DEFAULT 0;
    PRINT '✅ Columna escalado agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna escalado ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'fecha_escalado')
BEGIN
    ALTER TABLE incidencias ADD fecha_escalado DATETIME2;
    PRINT '✅ Columna fecha_escalado agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna fecha_escalado ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'nivel_escalado')
BEGIN
    ALTER TABLE incidencias ADD nivel_escalado INT;
    PRINT '✅ Columna nivel_escalado agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna nivel_escalado ya existe en incidencias';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'incidencias' AND COLUMN_NAME = 'activo')
BEGIN
    ALTER TABLE incidencias ADD activo BIT NOT NULL DEFAULT 1;
    PRINT '✅ Columna activo agregada a incidencias';
END
ELSE
BEGIN
    PRINT '⚠️ Columna activo ya existe en incidencias';
END
GO

-- Crear claves foráneas para incidencias
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_incidencias_tipo')
BEGIN
    ALTER TABLE incidencias ADD CONSTRAINT FK_incidencias_tipo 
    FOREIGN KEY (tipo_incidencia_id) REFERENCES tipos_incidencia(id);
    PRINT '✅ Clave foránea FK_incidencias_tipo creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_incidencias_tipo ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_incidencias_operario_resolucion')
BEGIN
    ALTER TABLE incidencias ADD CONSTRAINT FK_incidencias_operario_resolucion 
    FOREIGN KEY (operario_resolucion) REFERENCES usuarios(id);
    PRINT '✅ Clave foránea FK_incidencias_operario_resolucion creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_incidencias_operario_resolucion ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_incidencias_supervisor_aprobacion')
BEGIN
    ALTER TABLE incidencias ADD CONSTRAINT FK_incidencias_supervisor_aprobacion 
    FOREIGN KEY (supervisor_aprobacion) REFERENCES usuarios(id);
    PRINT '✅ Clave foránea FK_incidencias_supervisor_aprobacion creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_incidencias_supervisor_aprobacion ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_incidencias_padre')
BEGIN
    ALTER TABLE incidencias ADD CONSTRAINT FK_incidencias_padre 
    FOREIGN KEY (incidencia_padre_id) REFERENCES incidencias(id);
    PRINT '✅ Clave foránea FK_incidencias_padre creada';
END
ELSE
BEGIN
    PRINT '⚠️ Clave foránea FK_incidencias_padre ya existe';
END
GO

-- Insertar datos iniciales para tipos de incidencia
IF NOT EXISTS (SELECT * FROM tipos_incidencia WHERE codigo = 'DANIO_PRODUCTO')
BEGIN
    INSERT INTO tipos_incidencia (codigo, nombre, descripcion, categoria, tiempo_resolucion_estimado, prioridad_default) VALUES
    ('DANIO_PRODUCTO', 'Daño de producto', 'Producto dañado durante el manejo', 'CALIDAD', 30, 'alta'),
    ('UBICACION_INCORRECTA', 'Ubicación incorrecta', 'Producto en ubicación incorrecta', 'UBICACION', 15, 'media'),
    ('FALTA_STOCK', 'Falta de stock', 'Producto agotado en ubicación', 'INVENTARIO', 60, 'alta'),
    ('EQUIPO_DEFECTUOSO', 'Equipo defectuoso', 'Equipo de almacén defectuoso', 'EQUIPO', 120, 'alta'),
    ('ERROR_PICKING', 'Error de picking', 'Error en el proceso de picking', 'PICKING', 45, 'media'),
    ('PROBLEMA_TEMPERATURA', 'Problema de temperatura', 'Temperatura fuera de rango', 'AMBIENTE', 90, 'alta'),
    ('ACCIDENTE_TRABAJO', 'Accidente de trabajo', 'Accidente laboral en almacén', 'SEGURIDAD', 180, 'critica'),
    ('ROBO_PERDIDA', 'Robo o pérdida', 'Producto robado o perdido', 'SEGURIDAD', 240, 'critica');
    PRINT '✅ Datos iniciales de tipos_incidencia insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Datos iniciales de tipos_incidencia ya existen';
END
GO

-- Insertar datos iniciales para plantillas de resolución
IF NOT EXISTS (SELECT * FROM plantillas_resolucion WHERE nombre = 'Daño de producto')
BEGIN
    INSERT INTO plantillas_resolucion (tipo_incidencia_id, nombre, descripcion, pasos_resolucion, tiempo_estimado, recursos_necesarios) VALUES
    (1, 'Daño de producto', 'Plantilla para resolver daños de producto', '1. Identificar el daño\n2. Evaluar la gravedad\n3. Separar producto dañado\n4. Registrar en sistema\n5. Notificar a supervisor', 30, 'Operario, Supervisor'),
    (2, 'Ubicación incorrecta', 'Plantilla para corregir ubicaciones incorrectas', '1. Localizar producto\n2. Verificar ubicación correcta\n3. Mover producto\n4. Actualizar inventario\n5. Registrar movimiento', 15, 'Operario'),
    (3, 'Falta de stock', 'Plantilla para resolver faltas de stock', '1. Verificar inventario\n2. Buscar en otras ubicaciones\n3. Solicitar reposición\n4. Actualizar sistema\n5. Notificar a compras', 60, 'Operario, Supervisor'),
    (4, 'Equipo defectuoso', 'Plantilla para resolver problemas de equipo', '1. Identificar problema\n2. Evaluar gravedad\n3. Solicitar mantenimiento\n4. Usar equipo alternativo\n5. Registrar incidencia', 120, 'Operario, Mantenimiento'),
    (5, 'Error de picking', 'Plantilla para corregir errores de picking', '1. Identificar error\n2. Verificar pedido original\n3. Corregir picking\n4. Actualizar inventario\n5. Notificar a cliente', 45, 'Operario, Supervisor'),
    (6, 'Problema de temperatura', 'Plantilla para resolver problemas de temperatura', '1. Medir temperatura actual\n2. Verificar equipos\n3. Ajustar temperatura\n4. Monitorear continuamente\n5. Registrar mediciones', 90, 'Operario, Mantenimiento'),
    (7, 'Accidente de trabajo', 'Plantilla para manejar accidentes laborales', '1. Atender al herido\n2. Asegurar área\n3. Notificar a emergencias\n4. Documentar incidente\n5. Investigar causas', 180, 'Supervisor, Seguridad'),
    (8, 'Robo o pérdida', 'Plantilla para manejar robos y pérdidas', '1. Verificar pérdida\n2. Revisar cámaras\n3. Notificar a seguridad\n4. Documentar incidente\n5. Implementar medidas preventivas', 240, 'Supervisor, Seguridad');
    PRINT '✅ Datos iniciales de plantillas_resolucion insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Datos iniciales de plantillas_resolucion ya existen';
END
GO

-- Crear índices para incidencias avanzadas
CREATE NONCLUSTERED INDEX idx_incidencias_tipo ON incidencias(tipo_incidencia_id);
CREATE NONCLUSTERED INDEX idx_incidencias_prioridad ON incidencias(prioridad);
CREATE NONCLUSTERED INDEX idx_incidencias_categoria ON incidencias(categoria);
CREATE NONCLUSTERED INDEX idx_incidencias_fecha_estimada ON incidencias(fecha_estimada_resolucion);
CREATE NONCLUSTERED INDEX idx_incidencias_operario_resolucion ON incidencias(operario_resolucion);
CREATE NONCLUSTERED INDEX idx_incidencias_escalado ON incidencias(escalado);
CREATE NONCLUSTERED INDEX idx_incidencias_activo ON incidencias(activo);

CREATE NONCLUSTERED INDEX idx_seguimiento_incidencia ON seguimiento_incidencias(incidencia_id);
CREATE NONCLUSTERED INDEX idx_seguimiento_usuario ON seguimiento_incidencias(usuario_id);
CREATE NONCLUSTERED INDEX idx_seguimiento_fecha ON seguimiento_incidencias(fecha_accion);

CREATE NONCLUSTERED INDEX idx_plantillas_tipo ON plantillas_resolucion(tipo_incidencia_id);
CREATE NONCLUSTERED INDEX idx_plantillas_activo ON plantillas_resolucion(activo);

CREATE NONCLUSTERED INDEX idx_metricas_incidencia ON metricas_incidencias(incidencia_id);
CREATE NONCLUSTERED INDEX idx_metricas_tipo ON metricas_incidencias(tipo_metrica);
CREATE NONCLUSTERED INDEX idx_metricas_fecha ON metricas_incidencias(fecha_medicion);

PRINT '✅ Índices creados para incidencias avanzadas';
GO

-- 5. Verificación final
PRINT '';
PRINT '✅ VERIFICACIÓN FINAL';
PRINT '====================';
GO

-- Verificar que todas las tablas se crearon correctamente
DECLARE @tablas_creadas INT = 0;
DECLARE @total_tablas INT = 15;

-- Contar tablas del sistema avanzado
SELECT @tablas_creadas = COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN (
    'tipos_ubicacion',
    'zonas_almacen',
    'lotes',
    'movimientos_inventario',
    'numeros_serie',
    'trazabilidad_productos',
    'oleadas_picking',
    'pedidos_picking',
    'pedidos_picking_detalle',
    'rutas_picking',
    'estadisticas_picking',
    'tipos_incidencia',
    'seguimiento_incidencias',
    'plantillas_resolucion',
    'metricas_incidencias'
);

PRINT '📊 Tablas del sistema avanzado creadas: ' + CAST(@tablas_creadas AS NVARCHAR(10)) + '/' + CAST(@total_tablas AS NVARCHAR(10));

-- Verificar datos iniciales
DECLARE @tipos_ubicacion INT;
SELECT @tipos_ubicacion = COUNT(*) FROM tipos_ubicacion;
PRINT '📋 Tipos de ubicación: ' + CAST(@tipos_ubicacion AS NVARCHAR(10)) + ' registros';

DECLARE @zonas_almacen INT;
SELECT @zonas_almacen = COUNT(*) FROM zonas_almacen;
PRINT '🏢 Zonas de almacén: ' + CAST(@zonas_almacen AS NVARCHAR(10)) + ' registros';

DECLARE @tipos_incidencia INT;
SELECT @tipos_incidencia = COUNT(*) FROM tipos_incidencia;
PRINT '⚠️ Tipos de incidencia: ' + CAST(@tipos_incidencia AS NVARCHAR(10)) + ' registros';

DECLARE @plantillas_resolucion INT;
SELECT @plantillas_resolucion = COUNT(*) FROM plantillas_resolucion;
PRINT '📝 Plantillas de resolución: ' + CAST(@plantillas_resolucion AS NVARCHAR(10)) + ' registros';

IF @tablas_creadas = @total_tablas
BEGIN
    PRINT '';
    PRINT '🎉 ¡MIGRACIONES COMPLETADAS EXITOSAMENTE!';
    PRINT '=========================================';
    PRINT '';
    PRINT '✅ Funcionalidades implementadas:';
    PRINT '   📍 Gestión avanzada de ubicaciones con coordenadas y tipos';
    PRINT '   📋 Sistema de lotes y trazabilidad completa';
    PRINT '   🎯 Sistema de picking inteligente con oleadas';
    PRINT '   ⚠️ Sistema de incidencias avanzado';
    PRINT '';
    PRINT '🚀 El sistema WMS avanzado está listo para usar!';
END
ELSE
BEGIN
    PRINT '';
    PRINT '❌ ERROR: Migraciones incompletas';
    PRINT 'Faltan ' + CAST((@total_tablas - @tablas_creadas) AS NVARCHAR(10)) + ' tablas';
END
GO
