-- ============================================================================
-- SCRIPT SQL PARA AZURE SQL DATABASE - WMS ESCASAN
-- ============================================================================
-- Este script replica la estructura completa de la base de datos en Azure
-- IMPORTANTE: La base de datos ya debe estar creada en Azure
-- Ejecutar este script conectado a tu base de datos en Azure
-- ============================================================================

-- ============================================================================
-- NOTA: En Azure SQL Database, no se puede usar USE database
-- Conéctate directamente a tu base de datos antes de ejecutar este script
-- ============================================================================

-- Verificar que estamos en la base de datos correcta
IF DB_NAME() IS NULL
BEGIN
    PRINT '⚠️ ERROR: Debes conectarte a tu base de datos antes de ejecutar este script';
    RETURN;
END
GO

PRINT '🚀 Iniciando creación de estructura de base de datos...';
PRINT '📊 Base de datos: ' + DB_NAME();
GO

-- ============================================================================
-- CREAR ESQUEMA
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'wms')
BEGIN
    EXEC('CREATE SCHEMA wms');
    PRINT '✅ Esquema wms creado';
END
ELSE
BEGIN
    PRINT '⚠️ Esquema wms ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.roles
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'roles')
BEGIN
    CREATE TABLE wms.roles(
        id_rol INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(50) NOT NULL,
        descripcion NVARCHAR(255) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT uk_roles_nombre UNIQUE (nombre),
        CONSTRAINT chk_roles_nombre CHECK (nombre IN (N'Admin',N'Supervisor',N'Operario'))
    );
    PRINT '✅ Tabla wms.roles creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.roles ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.usuarios
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'usuarios')
BEGIN
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
    PRINT '✅ Tabla wms.usuarios creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.usuarios ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.estados_producto
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'estados_producto')
BEGIN
    CREATE TABLE wms.estados_producto(
        id_estado_producto INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(20) NOT NULL UNIQUE,
        nombre NVARCHAR(50) NOT NULL
    );
    PRINT '✅ Tabla wms.estados_producto creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.estados_producto ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.productos
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'productos')
BEGIN
    CREATE TABLE wms.productos(
        id_producto INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(MAX) NULL,
        codigo_barra NVARCHAR(50) NULL,
        lote NVARCHAR(50) NOT NULL,
        estado_producto_id INT NOT NULL,
        fecha_caducidad DATE NULL,
        unidad_medida NVARCHAR(20) NOT NULL,
        stock_minimo INT NOT NULL DEFAULT (0),
        precio DECIMAL(10,2) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT chk_productos_uom CHECK (unidad_medida IN (N'Unidad',N'Caja',N'Kg',N'Litro',N'Otro')),
        CONSTRAINT fk_productos_estado FOREIGN KEY (estado_producto_id) REFERENCES wms.estados_producto(id_estado_producto)
    );
    
    -- Índice único filtrado para permitir múltiples NULL en SQL Server
    CREATE UNIQUE INDEX ux_productos_codigo_barra ON wms.productos(codigo_barra) WHERE codigo_barra IS NOT NULL;
    PRINT '✅ Tabla wms.productos creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.productos ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.ubicaciones
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'ubicaciones')
BEGIN
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
    PRINT '✅ Tabla wms.ubicaciones creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.ubicaciones ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.inventario
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'inventario')
BEGIN
    CREATE TABLE wms.inventario(
        id_inventario INT IDENTITY(1,1) PRIMARY KEY,
        id_producto INT NOT NULL,
        id_ubicacion INT NOT NULL,
        cantidad INT NOT NULL DEFAULT (0),
        fecha_actualizacion DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT uk_inv_prod_ubi UNIQUE (id_producto, id_ubicacion),
        CONSTRAINT chk_inv_cantidad CHECK (cantidad >= 0),
        CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto) ON DELETE CASCADE,
        CONSTRAINT fk_inv_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES wms.ubicaciones(id_ubicacion) ON DELETE CASCADE
    );
    PRINT '✅ Tabla wms.inventario creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.inventario ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.tipos_tarea
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'tipos_tarea')
BEGIN
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
    PRINT '✅ Tabla wms.tipos_tarea creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.tipos_tarea ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.estados_tarea
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'estados_tarea')
BEGIN
    CREATE TABLE wms.estados_tarea(
        id_estado_tarea INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(20) NOT NULL UNIQUE,
        nombre NVARCHAR(80) NOT NULL
    );
    PRINT '✅ Tabla wms.estados_tarea creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.estados_tarea ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.tareas
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'tareas')
BEGIN
    CREATE TABLE wms.tareas(
        id_tarea INT IDENTITY(1,1) PRIMARY KEY,
        tipo_tarea_id INT NOT NULL,
        estado_tarea_id INT NOT NULL,
        prioridad NVARCHAR(20) NOT NULL DEFAULT (N'Media'),
        descripcion NVARCHAR(MAX) NULL,
        creado_por INT NOT NULL,
        fecha_creacion DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        fecha_cierre DATETIME2(7) NULL,
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT chk_tareas_prioridad CHECK (prioridad IN (N'Alta',N'Media',N'Baja')),
        CONSTRAINT fk_tareas_tipo FOREIGN KEY (tipo_tarea_id) REFERENCES wms.tipos_tarea(id_tipo_tarea),
        CONSTRAINT fk_tareas_estado FOREIGN KEY (estado_tarea_id) REFERENCES wms.estados_tarea(id_estado_tarea),
        CONSTRAINT fk_tareas_creador FOREIGN KEY (creado_por) REFERENCES wms.usuarios(id_usuario)
    );
    PRINT '✅ Tabla wms.tareas creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.tareas ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.tarea_usuario
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'tarea_usuario')
BEGIN
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
    PRINT '✅ Tabla wms.tarea_usuario creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.tarea_usuario ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.tarea_detalle
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'tarea_detalle')
BEGIN
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
    PRINT '✅ Tabla wms.tarea_detalle creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.tarea_detalle ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.tareas_log (Log de cambios de estado de tareas)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'tareas_log')
BEGIN
    CREATE TABLE wms.tareas_log(
        id_log BIGINT IDENTITY(1,1) PRIMARY KEY,
        id_tarea INT NOT NULL,
        usuario_id INT NULL,
        estado_anterior NVARCHAR(50) NULL,
        estado_nuevo NVARCHAR(50) NULL,
        accion NVARCHAR(100) NULL,
        dispositivo NVARCHAR(500) NULL,
        ip_address NVARCHAR(50) NULL,
        comentarios NVARCHAR(MAX) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT fk_tareas_log_tarea FOREIGN KEY (id_tarea) REFERENCES wms.tareas(id_tarea) ON DELETE CASCADE,
        CONSTRAINT fk_tareas_log_usuario FOREIGN KEY (usuario_id) REFERENCES wms.usuarios(id_usuario) ON DELETE SET NULL
    );
    
    -- Índices para mejorar consultas
    CREATE INDEX IX_tareas_log_id_tarea ON wms.tareas_log(id_tarea);
    CREATE INDEX IX_tareas_log_usuario_id ON wms.tareas_log(usuario_id);
    CREATE INDEX IX_tareas_log_created_at ON wms.tareas_log(created_at);
    CREATE INDEX IX_tareas_log_estado_nuevo ON wms.tareas_log(estado_nuevo);
    PRINT '✅ Tabla wms.tareas_log creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.tareas_log ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.incidencias
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'incidencias')
BEGIN
    CREATE TABLE wms.incidencias(
        id_incidencia INT IDENTITY(1,1) PRIMARY KEY,
        id_tarea INT NULL,
        id_operario INT NOT NULL,
        id_producto INT NOT NULL,
        descripcion NVARCHAR(MAX) NOT NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT (N'Pendiente'),
        fecha_reporte DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        fecha_resolucion DATETIME2(7) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT chk_incidencias_estado CHECK (estado IN (N'Pendiente',N'Resuelta')),
        CONSTRAINT fk_inc_tarea FOREIGN KEY (id_tarea) REFERENCES wms.tareas(id_tarea) ON DELETE SET NULL,
        CONSTRAINT fk_inc_operario FOREIGN KEY (id_operario) REFERENCES wms.usuarios(id_usuario),
        CONSTRAINT fk_inc_producto FOREIGN KEY (id_producto) REFERENCES wms.productos(id_producto)
    );
    PRINT '✅ Tabla wms.incidencias creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.incidencias ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.notificaciones
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'notificaciones')
BEGIN
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
    PRINT '✅ Tabla wms.notificaciones creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.notificaciones ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.picking
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'picking')
BEGIN
    CREATE TABLE wms.picking(
        id_picking INT IDENTITY(1,1) PRIMARY KEY,
        id_orden INT NOT NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT (N'Pendiente'),
        asignado_a INT NULL,
        fecha_inicio DATETIME2(7) NULL,
        fecha_fin DATETIME2(7) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT chk_picking_estado CHECK (estado IN (N'Pendiente',N'En Proceso',N'Completado',N'Cancelado')),
        CONSTRAINT fk_picking_usuario FOREIGN KEY (asignado_a) REFERENCES wms.usuarios(id_usuario)
    );
    PRINT '✅ Tabla wms.picking creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.picking ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.picking_det
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'picking_det')
BEGIN
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
    PRINT '✅ Tabla wms.picking_det creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.picking_det ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.orden_salida
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'orden_salida')
BEGIN
    CREATE TABLE wms.orden_salida(
        id_orden INT IDENTITY(1,1) PRIMARY KEY,
        estado NVARCHAR(20) NOT NULL DEFAULT (N'Pendiente'),
        prioridad NVARCHAR(20) NOT NULL DEFAULT (N'Media'),
        fecha_creacion DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        fecha_entrega DATETIME2(7) NULL,
        created_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        updated_at DATETIME2(7) NOT NULL DEFAULT (sysdatetime()),
        CONSTRAINT chk_orden_salida_estado CHECK (estado IN (N'Pendiente',N'En Proceso',N'Completada',N'Cancelada')),
        CONSTRAINT chk_orden_salida_prioridad CHECK (prioridad IN (N'Alta',N'Media',N'Baja'))
    );
    PRINT '✅ Tabla wms.orden_salida creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.orden_salida ya existe';
END
GO

-- ============================================================================
-- TABLA: wms.orden_salida_det
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME = 'orden_salida_det')
BEGIN
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
    PRINT '✅ Tabla wms.orden_salida_det creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla wms.orden_salida_det ya existe';
END
GO

-- ============================================================================
-- TABLAS DE LARAVEL (Esquema dbo)
-- ============================================================================

-- ============================================================================
-- TABLA: personal_access_tokens (Laravel Sanctum)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'personal_access_tokens')
BEGIN
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
    PRINT '✅ Tabla personal_access_tokens creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla personal_access_tokens ya existe';
END
GO

-- ============================================================================
-- TABLA: sessions (Laravel Sessions)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'sessions')
BEGIN
    CREATE TABLE sessions(
        id NVARCHAR(255) PRIMARY KEY,
        user_id BIGINT NULL,
        ip_address NVARCHAR(45) NULL,
        user_agent NVARCHAR(MAX) NULL,
        payload NVARCHAR(MAX) NOT NULL,
        last_activity INT NOT NULL
    );
    
    CREATE INDEX ix_sessions_user_id ON sessions(user_id);
    CREATE INDEX ix_sessions_last_activity ON sessions(last_activity);
    PRINT '✅ Tabla sessions creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla sessions ya existe';
END
GO

-- ============================================================================
-- TABLA: migrations (Laravel Migrations)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'migrations')
BEGIN
    CREATE TABLE migrations(
        id INT IDENTITY(1,1) PRIMARY KEY,
        migration NVARCHAR(255) NOT NULL,
        batch INT NOT NULL
    );
    PRINT '✅ Tabla migrations creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla migrations ya existe';
END
GO

-- ============================================================================
-- TABLA: password_reset_tokens (Laravel Password Reset)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'password_reset_tokens')
BEGIN
    CREATE TABLE password_reset_tokens(
        email NVARCHAR(255) PRIMARY KEY,
        token NVARCHAR(255) NOT NULL,
        created_at DATETIME2(7) NULL
    );
    PRINT '✅ Tabla password_reset_tokens creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla password_reset_tokens ya existe';
END
GO

-- ============================================================================
-- ÍNDICES ÚTILES
-- ============================================================================
PRINT '🔧 Creando índices...';
GO

-- Índices para productos
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_prod_estado' AND object_id = OBJECT_ID('wms.productos'))
    CREATE INDEX ix_prod_estado ON wms.productos(estado_producto_id);
GO

-- Índices para ubicaciones
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_ubic_codigo' AND object_id = OBJECT_ID('wms.ubicaciones'))
    CREATE INDEX ix_ubic_codigo ON wms.ubicaciones(codigo);
GO

-- Índices para tareas
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_tarea_estado_tipo' AND object_id = OBJECT_ID('wms.tareas'))
    CREATE INDEX ix_tarea_estado_tipo ON wms.tareas(estado_tarea_id, tipo_tarea_id, prioridad);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_tarea_usuario' AND object_id = OBJECT_ID('wms.tarea_usuario'))
    CREATE INDEX ix_tarea_usuario ON wms.tarea_usuario(id_usuario);
GO

-- Índices para inventario
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_inv_producto' AND object_id = OBJECT_ID('wms.inventario'))
    CREATE INDEX ix_inv_producto ON wms.inventario(id_producto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_inv_ubicacion' AND object_id = OBJECT_ID('wms.inventario'))
    CREATE INDEX ix_inv_ubicacion ON wms.inventario(id_ubicacion);
GO

-- Índices para notificaciones
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_notif_leido' AND object_id = OBJECT_ID('wms.notificaciones'))
    CREATE INDEX ix_notif_leido ON wms.notificaciones(leido, id_usuario);
GO

-- Índices para usuarios
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_usuarios_usuario' AND object_id = OBJECT_ID('wms.usuarios'))
    CREATE INDEX ix_usuarios_usuario ON wms.usuarios(usuario);
GO

-- Índices para picking
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_picking_estado' AND object_id = OBJECT_ID('wms.picking'))
    CREATE INDEX ix_picking_estado ON wms.picking(estado);
GO

-- Índices para orden_salida
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_orden_salida_estado' AND object_id = OBJECT_ID('wms.orden_salida'))
    CREATE INDEX ix_orden_salida_estado ON wms.orden_salida(estado);
GO

PRINT '✅ Índices creados';
GO

-- ============================================================================
-- DATOS INICIALES
-- ============================================================================
PRINT '📋 Insertando datos iniciales...';
GO

-- Insertar roles
IF NOT EXISTS (SELECT 1 FROM wms.roles WHERE nombre = N'Admin')
BEGIN
    INSERT INTO wms.roles (nombre, descripcion) VALUES
    (N'Admin', N'Administrador del sistema'),
    (N'Supervisor', N'Supervisor de almacén'),
    (N'Operario', N'Operario de almacén');
    PRINT '✅ Roles insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Roles ya existen';
END
GO

-- Insertar estados de productos
IF NOT EXISTS (SELECT 1 FROM wms.estados_producto WHERE codigo = N'DISPONIBLE')
BEGIN
    INSERT INTO wms.estados_producto (codigo, nombre) VALUES
    (N'DISPONIBLE', N'Disponible'),
    (N'DANADO', N'Dañado'),
    (N'RETENIDO', N'Retenido'),
    (N'CALIDAD', N'En Calidad');
    PRINT '✅ Estados de productos insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Estados de productos ya existen';
END
GO

-- Insertar tipos de tareas
IF NOT EXISTS (SELECT 1 FROM wms.tipos_tarea WHERE codigo = N'PICK_ENTRADA')
BEGIN
    INSERT INTO wms.tipos_tarea (codigo, nombre, categoria, requiere_producto, requiere_lote, requiere_ubicacion_origen, requiere_ubicacion_destino, requiere_cantidad, afecta_inventario) VALUES
    (N'PICK_ENTRADA', N'Picking de Entrada', N'Entrada', 1, 1, 0, 1, 1, 1),
    (N'PICK_SALIDA', N'Picking de Salida', N'Salida', 1, 1, 1, 0, 1, 1),
    (N'PUTAWAY', N'Putaway', N'Entrada', 1, 1, 0, 1, 1, 1),
    (N'REUBICACION', N'Reubicación', N'Interna', 1, 1, 1, 1, 1, 1),
    (N'INVENTARIO', N'Inventario', N'Inventario', 1, 1, 1, 0, 1, 0);
    PRINT '✅ Tipos de tareas insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Tipos de tareas ya existen';
END
GO

-- Insertar estados de tareas
IF NOT EXISTS (SELECT 1 FROM wms.estados_tarea WHERE codigo = N'NUEVA')
BEGIN
    INSERT INTO wms.estados_tarea (codigo, nombre) VALUES
    (N'NUEVA', N'Nueva'),
    (N'ABIERTA', N'Abierta'),
    (N'EN_PROCESO', N'En Proceso'),
    (N'COMPLETADA', N'Completada'),
    (N'CANCELADA', N'Cancelada');
    PRINT '✅ Estados de tareas insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Estados de tareas ya existen';
END
GO

-- Insertar usuario admin
IF NOT EXISTS (SELECT 1 FROM wms.usuarios WHERE usuario = N'admin')
BEGIN
    INSERT INTO wms.usuarios (nombre, usuario, contrasena, rol_id, email) VALUES
    (N'Administrador', N'admin', N'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, N'admin@escasan.com');
    PRINT '✅ Usuario admin insertado (password: password)';
END
ELSE
BEGIN
    PRINT '⚠️ Usuario admin ya existe';
END
GO

-- Insertar ubicaciones de ejemplo
IF NOT EXISTS (SELECT 1 FROM wms.ubicaciones WHERE codigo = N'A-01-01')
BEGIN
    INSERT INTO wms.ubicaciones (codigo, pasillo, estanteria, nivel, capacidad, tipo) VALUES
    (N'A-01-01', N'A', N'01', N'01', 100, N'Almacen'),
    (N'A-01-02', N'A', N'01', N'02', 100, N'Almacen'),
    (N'A-02-01', N'A', N'02', N'01', 100, N'Almacen'),
    (N'B-01-01', N'B', N'01', N'01', 100, N'Almacen'),
    (N'P-01-01', N'P', N'01', N'01', 50, N'Picking');
    PRINT '✅ Ubicaciones de ejemplo insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Ubicaciones de ejemplo ya existen';
END
GO

-- Insertar productos de ejemplo
IF NOT EXISTS (SELECT 1 FROM wms.productos WHERE codigo_barra = N'1234567890123')
BEGIN
    INSERT INTO wms.productos (nombre, descripcion, codigo_barra, lote, estado_producto_id, fecha_caducidad, unidad_medida, stock_minimo, precio) VALUES
    (N'Producto Ejemplo 1', N'Descripción del producto 1', N'1234567890123', N'LOTE001', 1, N'2025-12-31', N'Unidad', 10, 25.50),
    (N'Producto Ejemplo 2', N'Descripción del producto 2', N'1234567890124', N'LOTE002', 1, N'2025-11-30', N'Caja', 5, 150.00),
    (N'Producto Ejemplo 3', N'Descripción del producto 3', N'1234567890125', N'LOTE003', 1, N'2025-10-15', N'Kg', 20, 75.25);
    PRINT '✅ Productos de ejemplo insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Productos de ejemplo ya existen';
END
GO

-- Insertar inventario de ejemplo
IF NOT EXISTS (SELECT 1 FROM wms.inventario WHERE id_producto = 1 AND id_ubicacion = 1)
BEGIN
    INSERT INTO wms.inventario (id_producto, id_ubicacion, cantidad) VALUES
    (1, 1, 50),
    (1, 2, 30),
    (2, 3, 25),
    (3, 4, 40);
    PRINT '✅ Inventario de ejemplo insertado';
END
ELSE
BEGIN
    PRINT '⚠️ Inventario de ejemplo ya existe';
END
GO

-- ============================================================================
-- RESUMEN FINAL
-- ============================================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ BASE DE DATOS WMS ESCASAN CREADA EXITOSAMENTE EN AZURE SQL';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📊 Resumen:';
PRINT '   - Esquema wms creado';
PRINT '   - Tablas del sistema: 18';
PRINT '   - Tablas de Laravel: 4';
PRINT '   - Total de tablas: 22';
PRINT '   - Índices creados';
PRINT '   - Datos iniciales insertados';
PRINT '';
PRINT '🔐 Usuario por defecto:';
PRINT '   - Usuario: admin';
PRINT '   - Password: password';
PRINT '';
PRINT '🎯 Sistema listo para usar!';
PRINT '';
GO

