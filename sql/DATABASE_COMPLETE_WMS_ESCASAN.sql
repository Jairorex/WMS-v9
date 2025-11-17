-- ============================================================================
-- SCRIPT SQL COMPLETO - BASE DE DATOS WMS ESCASAN
-- ============================================================================
-- Este script contiene TODAS las tablas del sistema WMS Escasan
-- Incluye: Tablas básicas, Lotes, Movimientos, Unidades de Medida, etc.
-- ============================================================================
-- Fecha: 2024
-- Sistema: WMS Escasan v9
-- ============================================================================

-- ============================================================================
-- CREAR BASE DE DATOS
-- ============================================================================
IF DB_ID(N'wms_escasan') IS NOT NULL
BEGIN
    ALTER DATABASE wms_escasan SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE wms_escasan;
END
GO

CREATE DATABASE wms_escasan;
GO

USE wms_escasan;
GO

-- Crear esquema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'wms')
    EXEC('CREATE SCHEMA wms');
GO

-- ============================================================================
-- TABLAS BÁSICAS
-- ============================================================================

-- Roles
CREATE TABLE wms.roles(
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50) NOT NULL,
    descripcion NVARCHAR(255) NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT uk_roles_nombre UNIQUE (nombre),
    CONSTRAINT chk_roles_nombre CHECK (nombre IN (N'Admin',N'Supervisor',N'Operario'))
);
GO

-- Usuarios
CREATE TABLE wms.usuarios(
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    usuario NVARCHAR(50) NOT NULL,
    contrasena NVARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    email NVARCHAR(100) NULL,
    ultimo_login DATETIME2(7) NULL,
    activo BIT NOT NULL DEFAULT (1),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT uk_usuarios_usuario UNIQUE (usuario),
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id) REFERENCES wms.roles(id_rol) ON UPDATE CASCADE
);
GO

-- Estados de Producto
CREATE TABLE wms.estados_producto(
    id_estado_producto INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(20) NOT NULL UNIQUE,
    nombre NVARCHAR(50) NOT NULL
);
GO

-- Unidad de Medida
CREATE TABLE wms.unidad_de_medida(
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(10) NOT NULL UNIQUE,
    nombre NVARCHAR(50) NOT NULL,
    activo BIT NOT NULL DEFAULT (1),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime())
);
GO

-- Productos
CREATE TABLE wms.productos(
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX) NULL,
    codigo_barra NVARCHAR(50) NULL,
    lote NVARCHAR(50) NOT NULL,
    estado_producto_id INT NOT NULL,
    fecha_caducidad DATE NULL,
    unidad_medida NVARCHAR(20) NOT NULL,
    unidad_medida_id INT NULL,
    stock_minimo INT NOT NULL DEFAULT (0),
    precio DECIMAL(10,2) NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_productos_uom CHECK (unidad_medida IN (N'Unidad',N'Caja',N'Kg',N'Litro',N'Otro')),
    CONSTRAINT fk_productos_estado FOREIGN KEY (estado_producto_id) REFERENCES wms.estados_producto(id_estado_producto),
    CONSTRAINT fk_productos_unidad_medida FOREIGN KEY (unidad_medida_id) REFERENCES wms.unidad_de_medida(id)
);
GO

-- Índice único filtrado para permitir múltiples NULL en SQL Server
CREATE UNIQUE INDEX ux_productos_codigo_barra ON wms.productos(codigo_barra) WHERE codigo_barra IS NOT NULL;
GO

-- Ubicaciones
CREATE TABLE wms.ubicaciones(
    id_ubicacion INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(50) NOT NULL,
    pasillo NVARCHAR(10) NOT NULL,
    estanteria NVARCHAR(10) NOT NULL,
    nivel NVARCHAR(10) NOT NULL,
    capacidad INT NOT NULL DEFAULT (0),
    tipo NVARCHAR(20) NOT NULL DEFAULT (N'Almacen'),
    ocupada BIT NOT NULL DEFAULT (0),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT uk_ubicaciones_codigo UNIQUE (codigo),
    CONSTRAINT chk_ubicaciones_tipo CHECK (tipo IN (N'Almacen',N'Picking',N'Devoluciones'))
);
GO

-- Inventario
CREATE TABLE wms.inventario(
    id_inventario INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    id_ubicacion INT NOT NULL,
    cantidad INT NOT NULL DEFAULT (0),
    fecha_actualizacion DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    lote_id INT NULL,
    numero_serie_id INT NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT uk_inv_prod_ubi UNIQUE (id_producto, id_ubicacion),
    CONSTRAINT chk_inv_cantidad CHECK (cantidad >= 0),
    CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto) ON DELETE CASCADE,
    CONSTRAINT fk_inv_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES wms.ubicaciones(id_ubicacion) ON DELETE CASCADE
);
GO

-- ============================================================================
-- TABLAS DE LOTES Y TRAZABILIDAD
-- ============================================================================

-- Lotes
CREATE TABLE wms.lotes(
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo_lote NVARCHAR(50) NOT NULL UNIQUE,
    producto_id INT NOT NULL,
    cantidad_inicial DECIMAL(10,2) NOT NULL,
    cantidad_disponible DECIMAL(10,2) NOT NULL,
    fecha_fabricacion DATE NOT NULL,
    fecha_caducidad DATE NULL,
    fecha_vencimiento DATE NULL,
    proveedor NVARCHAR(100) NULL,
    numero_serie NVARCHAR(50) NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
    observaciones NVARCHAR(MAX) NULL,
    activo BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_lotes_producto FOREIGN KEY (producto_id) REFERENCES wms.productos (id_producto)
);
GO

-- Agregar Foreign Key de lote_id en inventario
ALTER TABLE wms.inventario
ADD CONSTRAINT FK_inventario_lote FOREIGN KEY (lote_id) REFERENCES wms.lotes (id);
GO

-- Movimientos de Inventario
CREATE TABLE wms.movimientos_inventario(
    id INT IDENTITY(1,1) PRIMARY KEY,
    lote_id INT NULL,
    producto_id INT NOT NULL,
    ubicacion_id INT NULL,
    tipo_movimiento NVARCHAR(20) NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    cantidad_anterior DECIMAL(10,2) NULL,
    cantidad_nueva DECIMAL(10,2) NULL,
    motivo NVARCHAR(200) NULL,
    referencia NVARCHAR(100) NULL,
    usuario_id INT NOT NULL,
    fecha_movimiento DATETIME2 NOT NULL DEFAULT GETDATE(),
    observaciones NVARCHAR(MAX) NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT CHK_movimientos_tipo CHECK (tipo_movimiento IN (
        'ENTRADA', 
        'SALIDA', 
        'TRASLADO', 
        'AJUSTE', 
        'DEVOLUCION',
        'RESERVA',
        'LIBERACION'
    )),
    CONSTRAINT FK_movimientos_producto FOREIGN KEY (producto_id) REFERENCES wms.productos (id_producto),
    CONSTRAINT FK_movimientos_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES wms.ubicaciones (id_ubicacion),
    CONSTRAINT FK_movimientos_usuario FOREIGN KEY (usuario_id) REFERENCES wms.usuarios (id_usuario),
    CONSTRAINT FK_movimientos_lote FOREIGN KEY (lote_id) REFERENCES wms.lotes (id)
);
GO

-- ============================================================================
-- TABLAS DE TAREAS
-- ============================================================================

-- Tipos de Tarea
CREATE TABLE wms.tipos_tarea(
    id_tipo_tarea INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(20) NOT NULL UNIQUE,
    nombre NVARCHAR(80) NOT NULL,
    categoria NVARCHAR(20) NOT NULL DEFAULT (N'Interna'),
    requiere_producto BIT NOT NULL DEFAULT (0),
    requiere_lote BIT NOT NULL DEFAULT (0),
    requiere_ubicacion_origen BIT NOT NULL DEFAULT (0),
    requiere_ubicacion_destino BIT NOT NULL DEFAULT (0),
    requiere_cantidad BIT NOT NULL DEFAULT (1),
    afecta_inventario BIT NOT NULL DEFAULT (0),
    CONSTRAINT chk_tipos_tarea_categoria CHECK (categoria IN (N'Entrada',N'Salida',N'Interna',N'Inventario',N'Devolucion',N'Calidad',N'Especial'))
);
GO

-- Estados de Tarea
CREATE TABLE wms.estados_tarea(
    id_estado_tarea INT IDENTITY(1,1) PRIMARY KEY,
    codigo NVARCHAR(20) NOT NULL UNIQUE,
    nombre NVARCHAR(80) NOT NULL
);
GO

-- Tareas
CREATE TABLE wms.tareas(
    id_tarea INT IDENTITY(1,1) PRIMARY KEY,
    tipo_tarea_id INT NOT NULL,
    estado_tarea_id INT NOT NULL,
    prioridad NVARCHAR(20) NOT NULL DEFAULT (N'Media'),
    descripcion NVARCHAR(MAX) NULL,
    creado_por INT NOT NULL,
    fecha_creacion DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    fecha_cierre DATETIME2(7) NULL,
    fecha_vencimiento DATETIME2(7) NULL,
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_tareas_prioridad CHECK (prioridad IN (N'Alta',N'Media',N'Baja')),
    CONSTRAINT fk_tareas_tipo FOREIGN KEY (tipo_tarea_id) REFERENCES wms.tipos_tarea(id_tipo_tarea),
    CONSTRAINT fk_tareas_estado FOREIGN KEY (estado_tarea_id) REFERENCES wms.estados_tarea(id_estado_tarea),
    CONSTRAINT fk_tareas_creador FOREIGN KEY (creado_por) REFERENCES wms.usuarios(id_usuario)
);
GO

-- Tarea Usuario (muchos a muchos)
CREATE TABLE wms.tarea_usuario(
    id_tarea INT NOT NULL,
    id_usuario INT NOT NULL,
    es_responsable BIT NOT NULL DEFAULT (0),
    asignado_desde DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    asignado_hasta DATETIME2(7) NULL,
    PRIMARY KEY (id_tarea, id_usuario),
    CONSTRAINT fk_tu_tarea FOREIGN KEY (id_tarea) REFERENCES wms.tareas(id_tarea) ON DELETE CASCADE,
    CONSTRAINT fk_tu_usuario FOREIGN KEY (id_usuario) REFERENCES wms.usuarios(id_usuario) ON DELETE CASCADE
);
GO

-- Detalle de Tareas
CREATE TABLE wms.tarea_detalle(
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_tarea INT NOT NULL,
    id_producto INT NOT NULL,
    id_ubicacion_origen INT NULL,
    id_ubicacion_destino INT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_confirmada INT NOT NULL DEFAULT (0),
    notas NVARCHAR(MAX) NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_td_solicitada CHECK (cantidad_solicitada > 0),
    CONSTRAINT chk_td_confirmada CHECK (cantidad_confirmada >= 0),
    CONSTRAINT fk_td_tarea FOREIGN KEY (id_tarea) REFERENCES wms.tareas(id_tarea) ON DELETE CASCADE,
    CONSTRAINT fk_td_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto),
    CONSTRAINT fk_td_ubi_ori FOREIGN KEY (id_ubicacion_origen) REFERENCES wms.ubicaciones(id_ubicacion),
    CONSTRAINT fk_td_ubi_des FOREIGN KEY (id_ubicacion_destino) REFERENCES wms.ubicaciones(id_ubicacion)
);
GO

-- ============================================================================
-- TABLAS DE INCIDENCIAS
-- ============================================================================

-- Incidencias
CREATE TABLE wms.incidencias(
    id_incidencia INT IDENTITY(1,1) PRIMARY KEY,
    id_tarea INT NULL,
    id_operario INT NOT NULL,
    id_producto INT NOT NULL,
    descripcion NVARCHAR(MAX) NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT (N'Pendiente'),
    fecha_reporte DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    fecha_resolucion DATETIME2(7) NULL,
    tipo_incidencia_id INT NULL,
    prioridad INT NULL,
    categoria NVARCHAR(50) NULL,
    fecha_estimada_resolucion DATETIME2(7) NULL,
    fecha_resolucion_real DATETIME2(7) NULL,
    tiempo_resolucion_estimado INT NULL,
    tiempo_resolucion_real INT NULL,
    operario_resolucion INT NULL,
    supervisor_aprobacion INT NULL,
    fecha_aprobacion DATETIME2(7) NULL,
    evidencia_fotos NVARCHAR(MAX) NULL,
    acciones_correctivas NVARCHAR(MAX) NULL,
    acciones_preventivas NVARCHAR(MAX) NULL,
    costo_estimado DECIMAL(10,2) NULL,
    costo_real DECIMAL(10,2) NULL,
    impacto_operaciones NVARCHAR(50) NULL,
    recurrencia BIT NULL DEFAULT (0),
    incidencia_padre_id INT NULL,
    escalado BIT NULL DEFAULT (0),
    fecha_escalado DATETIME2(7) NULL,
    nivel_escalado INT NULL,
    activo BIT NOT NULL DEFAULT (1),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_incidencias_estado CHECK (estado IN (N'Pendiente',N'Resuelta',N'En Proceso',N'Cerrada')),
    CONSTRAINT fk_inc_tarea FOREIGN KEY (id_tarea) REFERENCES wms.tareas(id_tarea) ON DELETE SET NULL,
    CONSTRAINT fk_inc_operario FOREIGN KEY (id_operario) REFERENCES wms.usuarios(id_usuario),
    CONSTRAINT fk_inc_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto)
);
GO

-- ============================================================================
-- TABLAS DE ÓRDENES Y PICKING
-- ============================================================================

-- Órdenes de Salida
CREATE TABLE wms.orden_salida(
    id_orden INT IDENTITY(1,1) PRIMARY KEY,
    estado NVARCHAR(20) NOT NULL DEFAULT (N'CREADA'),
    prioridad INT NOT NULL DEFAULT (3),
    cliente NVARCHAR(100) NULL,
    fecha_creacion DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    fecha_entrega DATETIME2(7) NULL,
    creado_por INT NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_orden_salida_estado CHECK (estado IN (N'CREADA',N'EN_PICKING',N'PICKING_COMPLETO',N'CANCELADA'))
);
GO

-- Detalle de Órdenes de Salida
CREATE TABLE wms.orden_salida_det(
    id_det INT IDENTITY(1,1) PRIMARY KEY,
    id_orden INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_confirmada INT NOT NULL DEFAULT (0),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_orden_det_solicitada CHECK (cantidad_solicitada > 0),
    CONSTRAINT chk_orden_det_confirmada CHECK (cantidad_confirmada >= 0),
    CONSTRAINT fk_orden_det_orden FOREIGN KEY (id_orden) REFERENCES wms.orden_salida(id_orden) ON DELETE CASCADE,
    CONSTRAINT fk_orden_det_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto)
);
GO

-- Picking
CREATE TABLE wms.picking(
    id_picking INT IDENTITY(1,1) PRIMARY KEY,
    id_orden INT NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT (N'ASIGNADO'),
    asignado_a INT NULL,
    fecha_inicio DATETIME2(7) NULL,
    fecha_fin DATETIME2(7) NULL,
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_picking_estado CHECK (estado IN (N'ASIGNADO',N'EN_PROCESO',N'PAUSADO',N'COMPLETADO',N'CANCELADO')),
    CONSTRAINT fk_picking_usuario FOREIGN KEY (asignado_a) REFERENCES wms.usuarios(id_usuario)
);
GO

-- Detalle de Picking
CREATE TABLE wms.picking_det(
    id_picking_det INT IDENTITY(1,1) PRIMARY KEY,
    id_picking INT NOT NULL,
    id_orden_det INT NOT NULL,
    id_producto INT NOT NULL,
    id_ubicacion INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_confirmada INT NOT NULL DEFAULT (0),
    estado NVARCHAR(20) NOT NULL DEFAULT (N'Pendiente'),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_picking_det_estado CHECK (estado IN (N'Pendiente',N'En Proceso',N'Completado',N'Cancelado')),
    CONSTRAINT fk_picking_det_picking FOREIGN KEY (id_picking) REFERENCES wms.picking(id_picking) ON DELETE CASCADE,
    CONSTRAINT fk_picking_det_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto),
    CONSTRAINT fk_picking_det_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES wms.ubicaciones(id_ubicacion)
);
GO

-- ============================================================================
-- TABLAS DE NOTIFICACIONES
-- ============================================================================

-- Notificaciones
CREATE TABLE wms.notificaciones(
    id_notificacion INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    mensaje NVARCHAR(MAX) NOT NULL,
    tipo NVARCHAR(20) NOT NULL,
    fecha DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    leido BIT NOT NULL DEFAULT (0),
    created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
    CONSTRAINT chk_notif_tipo CHECK (tipo IN (N'Nueva tarea',N'Stock bajo',N'Incidencia',N'Otra')),
    CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario) REFERENCES wms.usuarios(id_usuario) ON DELETE CASCADE
);
GO

-- ============================================================================
-- TABLAS DE AUTENTICACIÓN (Laravel Sanctum)
-- ============================================================================

-- Personal Access Tokens (Laravel Sanctum)
CREATE TABLE personal_access_tokens(
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    tokenable_type NVARCHAR(255) NOT NULL,
    tokenable_id BIGINT NOT NULL,
    name NVARCHAR(255) NOT NULL,
    token NVARCHAR(64) NOT NULL UNIQUE,
    abilities NVARCHAR(MAX) NULL,
    last_used_at DATETIME2(7) NULL,
    expires_at DATETIME2(7) NULL,
    created_at DATETIME2(7) NULL,
    updated_at DATETIME2(7) NULL
);
GO

-- ============================================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================================

CREATE INDEX ix_prod_estado ON wms.productos(estado_producto_id);
CREATE INDEX ix_prod_unidad_medida ON wms.productos(unidad_medida_id);
CREATE INDEX ix_ubic_codigo ON wms.ubicaciones(codigo);
CREATE INDEX ix_tarea_estado_tipo ON wms.tareas(estado_tarea_id, tipo_tarea_id, prioridad);
CREATE INDEX ix_tarea_usuario ON wms.tarea_usuario(id_usuario);
CREATE INDEX ix_inv_producto ON wms.inventario(id_producto);
CREATE INDEX ix_inv_ubicacion ON wms.inventario(id_ubicacion);
CREATE INDEX ix_inv_lote ON wms.inventario(lote_id);
CREATE INDEX ix_notif_leido ON wms.notificaciones(leido, id_usuario);
CREATE INDEX ix_usuarios_usuario ON wms.usuarios(usuario);
CREATE INDEX ix_picking_estado ON wms.picking(estado);
CREATE INDEX ix_orden_salida_estado ON wms.orden_salida(estado);
CREATE INDEX ix_lotes_producto ON wms.lotes(producto_id);
CREATE INDEX ix_lotes_codigo ON wms.lotes(codigo_lote);
CREATE INDEX ix_lotes_fecha_caducidad ON wms.lotes(fecha_caducidad);
CREATE INDEX ix_lotes_estado ON wms.lotes(estado);
CREATE INDEX ix_movimientos_lote ON wms.movimientos_inventario(lote_id);
CREATE INDEX ix_movimientos_producto ON wms.movimientos_inventario(producto_id);
CREATE INDEX ix_movimientos_ubicacion ON wms.movimientos_inventario(ubicacion_id);
CREATE INDEX ix_movimientos_fecha ON wms.movimientos_inventario(fecha_movimiento);
CREATE INDEX ix_movimientos_tipo ON wms.movimientos_inventario(tipo_movimiento);
CREATE INDEX ix_movimientos_usuario ON wms.movimientos_inventario(usuario_id);
GO

-- ============================================================================
-- DATOS INICIALES
-- ============================================================================

-- Roles
INSERT INTO wms.roles (nombre, descripcion) VALUES
(N'Admin', N'Administrador del sistema'),
(N'Supervisor', N'Supervisor de almacén'),
(N'Operario', N'Operario de almacén');
GO

-- Estados de Productos
INSERT INTO wms.estados_producto (codigo, nombre) VALUES
(N'DISPONIBLE', N'Disponible'),
(N'DANADO', N'Dañado'),
(N'RETENIDO', N'Retenido'),
(N'CALIDAD', N'En Calidad');
GO

-- Unidades de Medida
INSERT INTO wms.unidad_de_medida (codigo, nombre) VALUES
(N'UN', N'Unidad'),
(N'KG', N'Kilogramo'),
(N'LT', N'Litro'),
(N'CJ', N'Caja'),
(N'OT', N'Otro');
GO

-- Tipos de Tareas
INSERT INTO wms.tipos_tarea (codigo, nombre, categoria, requiere_producto, requiere_lote, requiere_ubicacion_origen, requiere_ubicacion_destino, requiere_cantidad, afecta_inventario) VALUES
(N'PICK_ENTRADA', N'Picking de Entrada', N'Entrada', 1, 1, 0, 1, 1, 1),
(N'PICK_SALIDA', N'Picking de Salida', N'Salida', 1, 1, 1, 0, 1, 1),
(N'PUTAWAY', N'Putaway', N'Entrada', 1, 1, 0, 1, 1, 1),
(N'REUBICACION', N'Reubicación', N'Interna', 1, 1, 1, 1, 1, 1),
(N'INVENTARIO', N'Inventario', N'Inventario', 1, 1, 1, 0, 1, 0);
GO

-- Estados de Tareas
INSERT INTO wms.estados_tarea (codigo, nombre) VALUES
(N'NUEVA', N'Nueva'),
(N'ASIGNADA', N'Asignada'),
(N'EN_PROCESO', N'En Proceso'),
(N'COMPLETADA', N'Completada'),
(N'CANCELADA', N'Cancelada'),
(N'BLOQUEADA', N'Bloqueada');
GO

-- Usuario Admin (password: password)
INSERT INTO wms.usuarios (nombre, usuario, contrasena, rol_id, email) VALUES
(N'Administrador', N'admin', N'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, N'admin@escasan.com');
GO

-- Ubicaciones de ejemplo
INSERT INTO wms.ubicaciones (codigo, pasillo, estanteria, nivel, capacidad, tipo) VALUES
(N'A-01-01', N'A', N'01', N'01', 100, N'Almacen'),
(N'A-01-02', N'A', N'01', N'02', 100, N'Almacen'),
(N'A-02-01', N'A', N'02', N'01', 100, N'Almacen'),
(N'B-01-01', N'B', N'01', N'01', 100, N'Almacen'),
(N'P-01-01', N'P', N'01', N'01', 50, N'Picking');
GO

-- Productos de ejemplo
INSERT INTO wms.productos (nombre, descripcion, codigo_barra, lote, estado_producto_id, fecha_caducidad, unidad_medida, unidad_medida_id, stock_minimo, precio) VALUES
(N'Producto Ejemplo 1', N'Descripción del producto 1', N'1234567890123', N'LOTE001', 1, N'2025-12-31', N'Unidad', 1, 10, 25.50),
(N'Producto Ejemplo 2', N'Descripción del producto 2', N'1234567890124', N'LOTE002', 1, N'2025-11-30', N'Caja', 4, 5, 150.00),
(N'Producto Ejemplo 3', N'Descripción del producto 3', N'1234567890125', N'LOTE003', 1, N'2025-10-15', N'Kg', 2, 20, 75.25);
GO

-- Inventario de ejemplo
INSERT INTO wms.inventario (id_producto, id_ubicacion, cantidad) VALUES
(1, 1, 50),
(1, 2, 30),
(2, 3, 25),
(3, 4, 40);
GO

-- ============================================================================
-- FINALIZACIÓN
-- ============================================================================

PRINT '';
PRINT '============================================================================';
PRINT '✅ BASE DE DATOS WMS ESCASAN CREADA EXITOSAMENTE';
PRINT '============================================================================';
PRINT '📊 Tablas creadas: 25+';
PRINT '📋 Datos iniciales insertados';
PRINT '🔧 Índices creados';
PRINT '🎯 Sistema listo para usar';
PRINT '';
PRINT 'Tablas principales:';
PRINT '  - roles, usuarios';
PRINT '  - productos, estados_producto, unidad_de_medida';
PRINT '  - ubicaciones, inventario';
PRINT '  - lotes, movimientos_inventario';
PRINT '  - tipos_tarea, estados_tarea, tareas, tarea_detalle, tarea_usuario';
PRINT '  - incidencias';
PRINT '  - orden_salida, orden_salida_det';
PRINT '  - picking, picking_det';
PRINT '  - notificaciones';
PRINT '  - personal_access_tokens';
PRINT '============================================================================';
GO

