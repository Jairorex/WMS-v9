-- Script unificado para instalar módulos de Lotes y Notificaciones
-- Ejecutar en SQL Server Management Studio

USE [wms_escasan];
GO

PRINT '🚀 Instalando módulos de Lotes y Notificaciones...';
PRINT '==============================================';
GO

-- ========================================
-- MÓDULO DE LOTES
-- ========================================

PRINT '';
PRINT '📦 Instalando módulo de Lotes...';
PRINT '==============================';

-- 1. Tabla de lotes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    CREATE TABLE lotes (
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
        
        CONSTRAINT FK_lotes_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto)
    );
    
    CREATE INDEX IX_lotes_producto ON lotes (producto_id);
    CREATE INDEX IX_lotes_codigo ON lotes (codigo_lote);
    CREATE INDEX IX_lotes_fecha_caducidad ON lotes (fecha_caducidad);
    CREATE INDEX IX_lotes_estado ON lotes (estado);
    
    PRINT '✅ Tabla lotes creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla lotes ya existe';
END
GO

-- 2. Tabla de movimientos de inventario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'movimientos_inventario')
BEGIN
    CREATE TABLE movimientos_inventario (
        id INT IDENTITY(1,1) PRIMARY KEY,
        lote_id INT NULL,
        producto_id INT NOT NULL,
        ubicacion_id INT NULL,
        tipo_movimiento NVARCHAR(20) NOT NULL,
        cantidad DECIMAL(10,2) NOT NULL,
        cantidad_anterior DECIMAL(10,2) NULL,
        cantidad_nueva DECIMAL(10,2) NULL,
        motivo NVARCHAR(200) NULL,
        usuario_id INT NOT NULL,
        fecha_movimiento DATETIME2 DEFAULT GETDATE(),
        observaciones NVARCHAR(MAX) NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_movimientos_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id),
        CONSTRAINT FK_movimientos_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto),
        CONSTRAINT FK_movimientos_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios (id),
        CONSTRAINT CHK_movimientos_tipo CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'TRASLADO', 'AJUSTE', 'DEVOLUCION'))
    );
    
    CREATE INDEX IX_movimientos_lote ON movimientos_inventario (lote_id);
    CREATE INDEX IX_movimientos_producto ON movimientos_inventario (producto_id);
    CREATE INDEX IX_movimientos_fecha ON movimientos_inventario (fecha_movimiento);
    CREATE INDEX IX_movimientos_tipo ON movimientos_inventario (tipo_movimiento);
    
    PRINT '✅ Tabla movimientos_inventario creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla movimientos_inventario ya existe';
END
GO

-- 3. Tabla de números de serie
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'numeros_serie')
BEGIN
    CREATE TABLE numeros_serie (
        id INT IDENTITY(1,1) PRIMARY KEY,
        lote_id INT NULL,
        producto_id INT NOT NULL,
        numero_serie NVARCHAR(100) NOT NULL UNIQUE,
        estado NVARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
        ubicacion_id INT NULL,
        fecha_asignacion DATETIME2 NULL,
        usuario_asignacion INT NULL,
        observaciones NVARCHAR(MAX) NULL,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_numeros_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id),
        CONSTRAINT FK_numeros_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto),
        CONSTRAINT FK_numeros_usuario FOREIGN KEY (usuario_asignacion) 
        REFERENCES usuarios (id),
        CONSTRAINT CHK_numeros_estado CHECK (estado IN ('DISPONIBLE', 'ASIGNADO', 'EN_TRANSITO', 'DANADO', 'PERDIDO'))
    );
    
    CREATE INDEX IX_numeros_lote ON numeros_serie (lote_id);
    CREATE INDEX IX_numeros_producto ON numeros_serie (producto_id);
    CREATE INDEX IX_numeros_serie ON numeros_serie (numero_serie);
    CREATE INDEX IX_numeros_estado ON numeros_serie (estado);
    
    PRINT '✅ Tabla numeros_serie creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla numeros_serie ya existe';
END
GO

-- 4. Tabla de trazabilidad de productos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'trazabilidad_productos')
BEGIN
    CREATE TABLE trazabilidad_productos (
        id INT IDENTITY(1,1) PRIMARY KEY,
        lote_id INT NULL,
        numero_serie_id INT NULL,
        producto_id INT NOT NULL,
        tipo_evento NVARCHAR(50) NOT NULL,
        descripcion_evento NVARCHAR(500) NULL,
        ubicacion_id INT NULL,
        usuario_id INT NOT NULL,
        fecha_evento DATETIME2 DEFAULT GETDATE(),
        referencia_documento NVARCHAR(100) NULL,
        datos_adicionales NVARCHAR(MAX) NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_trazabilidad_lote FOREIGN KEY (lote_id) 
        REFERENCES lotes (id),
        CONSTRAINT FK_trazabilidad_numero FOREIGN KEY (numero_serie_id) 
        REFERENCES numeros_serie (id),
        CONSTRAINT FK_trazabilidad_producto FOREIGN KEY (producto_id) 
        REFERENCES productos (id_producto),
        CONSTRAINT FK_trazabilidad_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios (id)
    );
    
    CREATE INDEX IX_trazabilidad_lote ON trazabilidad_productos (lote_id);
    CREATE INDEX IX_trazabilidad_numero ON trazabilidad_productos (numero_serie_id);
    CREATE INDEX IX_trazabilidad_producto ON trazabilidad_productos (producto_id);
    CREATE INDEX IX_trazabilidad_fecha ON trazabilidad_productos (fecha_evento);
    
    PRINT '✅ Tabla trazabilidad_productos creada exitosamente';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla trazabilidad_productos ya existe';
END
GO

-- 5. Agregar columnas de lote al inventario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventario')
BEGIN
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'lote_id')
    BEGIN
        ALTER TABLE inventario ADD lote_id INT NULL;
        ALTER TABLE inventario ADD CONSTRAINT FK_inventario_lote FOREIGN KEY (lote_id) REFERENCES lotes (id);
        CREATE INDEX IX_inventario_lote ON inventario (lote_id);
        PRINT '✅ Columna lote_id agregada a tabla inventario';
    END
    
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'inventario' AND COLUMN_NAME = 'numero_serie_id')
    BEGIN
        ALTER TABLE inventario ADD numero_serie_id INT NULL;
        ALTER TABLE inventario ADD CONSTRAINT FK_inventario_numero FOREIGN KEY (numero_serie_id) REFERENCES numeros_serie (id);
        CREATE INDEX IX_inventario_numero ON inventario (numero_serie_id);
        PRINT '✅ Columna numero_serie_id agregada a tabla inventario';
    END
END

-- Insertar datos de prueba para lotes
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'lotes')
BEGIN
    DECLARE @lotes_count INT;
    SELECT @lotes_count = COUNT(*) FROM lotes;
    
    IF @lotes_count = 0
    BEGIN
        INSERT INTO lotes (codigo_lote, producto_id, cantidad_inicial, cantidad_disponible, fecha_fabricacion, fecha_caducidad, proveedor, estado) VALUES
        ('LOTE-001-2024', 1, 100.00, 100.00, '2024-01-15', '2024-12-31', 'Proveedor A', 'DISPONIBLE'),
        ('LOTE-002-2024', 1, 50.00, 50.00, '2024-02-01', '2024-11-30', 'Proveedor B', 'DISPONIBLE'),
        ('LOTE-003-2024', 2, 75.00, 75.00, '2024-01-20', '2024-10-31', 'Proveedor A', 'DISPONIBLE');
        
        PRINT '✅ Datos de prueba insertados en tabla lotes';
    END
END

-- ========================================
-- MÓDULO DE NOTIFICACIONES
-- ========================================

PRINT '';
PRINT '🔔 Instalando módulo de Notificaciones...';
PRINT '======================================';

-- 1. Tabla de tipos de notificación
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_notificacion')
BEGIN
    CREATE TABLE tipos_notificacion (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        categoria NVARCHAR(50) NOT NULL,
        prioridad NVARCHAR(20) NOT NULL DEFAULT 'media',
        canales_notificacion NVARCHAR(100) NOT NULL,
        plantilla_email NVARCHAR(MAX),
        plantilla_push NVARCHAR(500),
        plantilla_web NVARCHAR(500),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT CHK_tipos_notif_prioridad CHECK (prioridad IN ('baja', 'media', 'alta', 'critica')),
        CONSTRAINT CHK_tipos_notif_categoria CHECK (categoria IN ('sistema', 'operaciones', 'inventario', 'calidad', 'seguridad', 'mantenimiento'))
    );
    PRINT '✅ Tabla tipos_notificacion creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tipos_notificacion ya existe';
END
GO

-- 2. Tabla de notificaciones
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'notificaciones')
BEGIN
    CREATE TABLE notificaciones (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tipo_notificacion_id INT NOT NULL,
        usuario_id INT NOT NULL,
        titulo NVARCHAR(200) NOT NULL,
        mensaje NVARCHAR(1000) NOT NULL,
        datos_adicionales NVARCHAR(MAX),
        prioridad NVARCHAR(20) NOT NULL DEFAULT 'media',
        estado NVARCHAR(20) NOT NULL DEFAULT 'pendiente',
        fecha_envio DATETIME2,
        fecha_lectura DATETIME2,
        fecha_expiracion DATETIME2,
        intentos_envio INT DEFAULT 0,
        max_intentos INT DEFAULT 3,
        error_ultimo_envio NVARCHAR(500),
        canales_enviados NVARCHAR(100),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_notificaciones_tipo FOREIGN KEY (tipo_notificacion_id) REFERENCES tipos_notificacion(id),
        CONSTRAINT FK_notificaciones_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_notificaciones_prioridad CHECK (prioridad IN ('baja', 'media', 'alta', 'critica')),
        CONSTRAINT CHK_notificaciones_estado CHECK (estado IN ('pendiente', 'enviando', 'enviada', 'leida', 'fallida', 'expirada'))
    );
    PRINT '✅ Tabla notificaciones creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla notificaciones ya existe';
END
GO

-- 3. Tabla de configuración de notificaciones por usuario
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'configuracion_notificaciones_usuario')
BEGIN
    CREATE TABLE configuracion_notificaciones_usuario (
        id INT IDENTITY(1,1) PRIMARY KEY,
        usuario_id INT NOT NULL,
        tipo_notificacion_id INT NOT NULL,
        recibir_email BIT NOT NULL DEFAULT 1,
        recibir_push BIT NOT NULL DEFAULT 1,
        recibir_web BIT NOT NULL DEFAULT 1,
        frecuencia_resumen NVARCHAR(20) DEFAULT 'inmediata',
        hora_resumen TIME,
        dias_resumen NVARCHAR(20),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_config_notif_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT FK_config_notif_tipo FOREIGN KEY (tipo_notificacion_id) REFERENCES tipos_notificacion(id),
        CONSTRAINT CHK_config_frecuencia CHECK (frecuencia_resumen IN ('inmediata', 'diaria', 'semanal', 'mensual')),
        CONSTRAINT UK_config_usuario_tipo UNIQUE (usuario_id, tipo_notificacion_id)
    );
    PRINT '✅ Tabla configuracion_notificaciones_usuario creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla configuracion_notificaciones_usuario ya existe';
END
GO

-- 4. Tabla de plantillas de email
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_email')
BEGIN
    CREATE TABLE plantillas_email (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        asunto NVARCHAR(200) NOT NULL,
        contenido_html NVARCHAR(MAX) NOT NULL,
        contenido_texto NVARCHAR(MAX),
        variables_disponibles NVARCHAR(500),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla plantillas_email creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla plantillas_email ya existe';
END
GO

-- 5. Tabla de cola de notificaciones
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'cola_notificaciones')
BEGIN
    CREATE TABLE cola_notificaciones (
        id INT IDENTITY(1,1) PRIMARY KEY,
        notificacion_id INT NOT NULL,
        canal NVARCHAR(20) NOT NULL,
        estado NVARCHAR(20) NOT NULL DEFAULT 'pendiente',
        fecha_programada DATETIME2 NOT NULL DEFAULT GETDATE(),
        fecha_procesado DATETIME2,
        intentos INT DEFAULT 0,
        max_intentos INT DEFAULT 3,
        error_ultimo_intento NVARCHAR(500),
        datos_envio NVARCHAR(MAX),
        created_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_cola_notificacion FOREIGN KEY (notificacion_id) REFERENCES notificaciones(id),
        CONSTRAINT CHK_cola_canal CHECK (canal IN ('email', 'push', 'web', 'sms')),
        CONSTRAINT CHK_cola_estado CHECK (estado IN ('pendiente', 'procesando', 'enviada', 'fallida', 'cancelada'))
    );
    PRINT '✅ Tabla cola_notificaciones creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla cola_notificaciones ya existe';
END
GO

-- 6. Tabla de logs de notificaciones
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'logs_notificaciones')
BEGIN
    CREATE TABLE logs_notificaciones (
        id INT IDENTITY(1,1) PRIMARY KEY,
        notificacion_id INT NOT NULL,
        canal NVARCHAR(20) NOT NULL,
        accion NVARCHAR(50) NOT NULL,
        estado NVARCHAR(20) NOT NULL,
        mensaje NVARCHAR(500),
        datos_adicionales NVARCHAR(MAX),
        fecha_accion DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_logs_notificacion FOREIGN KEY (notificacion_id) REFERENCES notificaciones(id),
        CONSTRAINT CHK_logs_canal CHECK (canal IN ('email', 'push', 'web', 'sms')),
        CONSTRAINT CHK_logs_accion CHECK (accion IN ('creada', 'enviada', 'leida', 'fallida', 'expirada', 'cancelada')),
        CONSTRAINT CHK_logs_estado CHECK (estado IN ('exitoso', 'fallido', 'pendiente'))
    );
    PRINT '✅ Tabla logs_notificaciones creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla logs_notificaciones ya existe';
END
GO

-- Insertar tipos de notificación específicos para Escasan
IF NOT EXISTS (SELECT * FROM tipos_notificacion WHERE codigo = 'TAREA_ASIGNADA')
BEGIN
    INSERT INTO tipos_notificacion (codigo, nombre, descripcion, categoria, prioridad, canales_notificacion, plantilla_email, plantilla_push, plantilla_web) VALUES
    ('TAREA_ASIGNADA', 'Tarea Asignada', 'Notificación cuando se asigna una nueva tarea', 'operaciones', 'media', 'push,web', 
     NULL,
     '📋 Nueva tarea asignada: {{tarea_titulo}}',
     'Nueva tarea asignada: {{tarea_titulo}}'),
    
    ('TAREA_COMPLETADA', 'Tarea Completada', 'Notificación cuando se completa una tarea', 'operaciones', 'baja', 'push,web',
     NULL,
     '✅ Tarea completada: {{tarea_titulo}}',
     'Tarea completada: {{tarea_titulo}}'),
    
    ('INCIDENCIA_NUEVA', 'Nueva Incidencia', 'Notificación de nueva incidencia creada', 'calidad', 'alta', 'email,push,web',
     '<h2>Nueva Incidencia: {{incidencia_titulo}}</h2><p>Se ha creado una nueva incidencia: {{incidencia_descripcion}}</p>',
     '⚠️ Nueva incidencia: {{incidencia_titulo}}',
     'Nueva incidencia creada: {{incidencia_titulo}}'),
    
    ('INCIDENCIA_RESUELTA', 'Incidencia Resuelta', 'Notificación cuando se resuelve una incidencia', 'calidad', 'media', 'push,web',
     NULL,
     '✅ Incidencia resuelta: {{incidencia_titulo}}',
     'Incidencia resuelta: {{incidencia_titulo}}'),
    
    ('PRODUCTO_BAJO_STOCK', 'Producto Bajo Stock', 'Notificación de stock bajo en productos', 'inventario', 'alta', 'email,push,web',
     '<h2>Stock Bajo: {{producto_nombre}}</h2><p>El producto {{producto_nombre}} tiene stock bajo: {{cantidad_actual}} {{unidad}}</p>',
     '📦 Stock bajo: {{producto_nombre}} - {{cantidad_actual}} {{unidad}}',
     'Stock bajo: {{producto_nombre}} - Cantidad: {{cantidad_actual}} {{unidad}}'),
    
    ('LOTE_VENCIDO', 'Lote Vencido', 'Notificación de lote próximo a vencer o vencido', 'inventario', 'alta', 'email,push,web',
     '<h2>Lote Vencido: {{lote_codigo}}</h2><p>El lote {{lote_codigo}} del producto {{producto_nombre}} ha vencido</p>',
     '📅 Lote vencido: {{lote_codigo}} - {{producto_nombre}}',
     'Lote vencido: {{lote_codigo}} del producto {{producto_nombre}}'),
    
    ('PICKING_COMPLETADO', 'Picking Completado', 'Notificación cuando se completa un picking', 'operaciones', 'baja', 'push,web',
     NULL,
     '✅ Picking completado: {{picking_codigo}}',
     'Picking completado: {{picking_codigo}}'),
    
    ('SISTEMA_ERROR', 'Error del Sistema', 'Notificación de errores críticos del sistema', 'sistema', 'critica', 'email,push,web',
     '<h2>Error del Sistema</h2><p>Se ha detectado un error crítico: {{error_descripcion}}</p>',
     '🚨 Error del sistema: {{error_descripcion}}',
     'Error crítico del sistema: {{error_descripcion}}'),
    
    ('USUARIO_LOGIN', 'Login de Usuario', 'Notificación de inicio de sesión de usuario', 'sistema', 'baja', 'web',
     NULL,
     NULL,
     'Inicio de sesión: {{usuario_nombre}}');
    
    PRINT '✅ Tipos de notificación específicos para Escasan insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Tipos de notificación específicos para Escasan ya existen';
END
GO

-- Insertar plantillas de email específicas para Escasan
IF NOT EXISTS (SELECT * FROM plantillas_email WHERE codigo = 'PLANTILLA_ESCASAN')
BEGIN
    INSERT INTO plantillas_email (codigo, nombre, asunto, contenido_html, contenido_texto, variables_disponibles) VALUES
    ('PLANTILLA_ESCASAN', 'Plantilla Escasan', '{{titulo}} - Sistema Escasan', 
     '<!DOCTYPE html><html><head><meta charset="utf-8"><title>{{titulo}}</title></head><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><div style="max-width: 600px; margin: 0 auto; padding: 20px;"><div style="background: #2c3e50; color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px;"><h1 style="margin: 0;">🏢 Sistema Escasan</h1></div><h2 style="color: #2c3e50;">{{titulo}}</h2><div style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">{{mensaje}}</div><hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;"><p style="color: #666; font-size: 12px;">Este es un mensaje automático del Sistema Escasan. Por favor no responder.</p></div></body></html>',
     '🏢 Sistema Escasan\n\n{{titulo}}\n\n{{mensaje}}\n\n---\nEste es un mensaje automático del Sistema Escasan.',
     'titulo,mensaje,fecha,usuario_nombre'),
    
    ('PLANTILLA_ALERTA_ESCASAN', 'Plantilla de Alerta Escasan', '🚨 {{titulo}} - Sistema Escasan',
     '<!DOCTYPE html><html><head><meta charset="utf-8"><title>{{titulo}}</title></head><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><div style="max-width: 600px; margin: 0 auto; padding: 20px;"><div style="background: #2c3e50; color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px;"><h1 style="margin: 0;">🏢 Sistema Escasan</h1></div><div style="background: #dc3545; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;"><h2 style="margin: 0;">🚨 {{titulo}}</h2></div><div style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">{{mensaje}}</div><div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;"><strong>Prioridad:</strong> {{prioridad}}<br><strong>Fecha:</strong> {{fecha}}</div><hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;"><p style="color: #666; font-size: 12px;">Sistema Escasan - Notificación automática</p></div></body></html>',
     '🏢 Sistema Escasan\n\n🚨 {{titulo}}\n\n{{mensaje}}\n\nPrioridad: {{prioridad}}\nFecha: {{fecha}}\n\n---\nSistema Escasan',
     'titulo,mensaje,prioridad,fecha,usuario_nombre');
    
    PRINT '✅ Plantillas de email específicas para Escasan insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Plantillas de email específicas para Escasan ya existen';
END
GO

-- Crear índices para notificaciones
CREATE NONCLUSTERED INDEX idx_notificaciones_usuario ON notificaciones(usuario_id);
CREATE NONCLUSTERED INDEX idx_notificaciones_estado ON notificaciones(estado);
CREATE NONCLUSTERED INDEX idx_notificaciones_prioridad ON notificaciones(prioridad);
CREATE NONCLUSTERED INDEX idx_notificaciones_fecha_envio ON notificaciones(fecha_envio);
CREATE NONCLUSTERED INDEX idx_notificaciones_tipo ON notificaciones(tipo_notificacion_id);

CREATE NONCLUSTERED INDEX idx_cola_estado ON cola_notificaciones(estado);
CREATE NONCLUSTERED INDEX idx_cola_canal ON cola_notificaciones(canal);
CREATE NONCLUSTERED INDEX idx_cola_fecha_programada ON cola_notificaciones(fecha_programada);

CREATE NONCLUSTERED INDEX idx_logs_notificacion ON logs_notificaciones(notificacion_id);
CREATE NONCLUSTERED INDEX idx_logs_fecha ON logs_notificaciones(fecha_accion);
CREATE NONCLUSTERED INDEX idx_logs_canal ON logs_notificaciones(canal);

CREATE NONCLUSTERED INDEX idx_config_usuario ON configuracion_notificaciones_usuario(usuario_id);
CREATE NONCLUSTERED INDEX idx_config_tipo ON configuracion_notificaciones_usuario(tipo_notificacion_id);

PRINT '✅ Índices creados para notificaciones';
GO

-- Crear configuración por defecto para usuarios existentes
DECLARE @configuraciones_creadas INT = 0;

INSERT INTO configuracion_notificaciones_usuario (usuario_id, tipo_notificacion_id, recibir_email, recibir_push, recibir_web, frecuencia_resumen, activo)
SELECT 
    u.id_usuario,
    tn.id,
    CASE 
        WHEN tn.categoria IN ('sistema', 'calidad', 'inventario') THEN 1 
        ELSE 0 
    END as recibir_email,
    1 as recibir_push,
    1 as recibir_web,
    'inmediata' as frecuencia_resumen,
    1 as activo
FROM usuarios u
CROSS JOIN tipos_notificacion tn
WHERE u.activo = 1
AND tn.activo = 1
AND NOT EXISTS (
    SELECT 1 FROM configuracion_notificaciones_usuario cnu 
    WHERE cnu.usuario_id = u.id_usuario 
    AND cnu.tipo_notificacion_id = tn.id
);

SET @configuraciones_creadas = @@ROWCOUNT;

IF @configuraciones_creadas > 0
BEGIN
    PRINT '✅ Configuraciones: ' + CAST(@configuraciones_creadas AS NVARCHAR(10)) + ' configuraciones por defecto creadas';
END
ELSE
BEGIN
    PRINT 'ℹ️ INFO: Las configuraciones por defecto ya existen';
END
GO

-- Crear una notificación de prueba
DECLARE @usuario_prueba INT;
SELECT TOP 1 @usuario_prueba = id_usuario FROM usuarios WHERE activo = 1;

IF @usuario_prueba IS NOT NULL
BEGIN
    DECLARE @tipo_prueba INT;
    SELECT @tipo_prueba = id FROM tipos_notificacion WHERE codigo = 'SISTEMA_ERROR';
    
    IF @tipo_prueba IS NOT NULL
    BEGIN
        INSERT INTO notificaciones (tipo_notificacion_id, usuario_id, titulo, mensaje, prioridad, estado)
        VALUES (@tipo_prueba, @usuario_prueba, 'Módulos Instalados Exitosamente', 'Los módulos de Lotes y Notificaciones han sido instalados exitosamente en Escasan.', 'media', 'pendiente');
        
        PRINT '✅ Notificación de prueba creada para usuario ID: ' + CAST(@usuario_prueba AS NVARCHAR(10));
    END
END
GO

PRINT '';
PRINT '🎉 ¡Módulos de Lotes y Notificaciones instalados exitosamente!';
PRINT '==========================================================';
PRINT '';
PRINT '📦 MÓDULO DE LOTES:';
PRINT '   ✅ lotes - Gestión de lotes de productos';
PRINT '   ✅ movimientos_inventario - Trazabilidad de movimientos';
PRINT '   ✅ numeros_serie - Gestión de números de serie';
PRINT '   ✅ trazabilidad_productos - Historial de eventos';
PRINT '   ✅ Columnas lote_id y numero_serie_id agregadas a inventario';
PRINT '   ✅ Datos de prueba insertados';
PRINT '';
PRINT '🔔 MÓDULO DE NOTIFICACIONES:';
PRINT '   ✅ tipos_notificacion - 9 tipos específicos para Escasan';
PRINT '   ✅ notificaciones - Sistema completo de notificaciones';
PRINT '   ✅ configuracion_notificaciones_usuario - Configuración por usuario';
PRINT '   ✅ plantillas_email - 2 plantillas con branding Escasan';
PRINT '   ✅ cola_notificaciones - Cola de procesamiento';
PRINT '   ✅ logs_notificaciones - Logs del sistema';
PRINT '   ✅ Configuraciones por defecto para usuarios';
PRINT '   ✅ Notificación de prueba creada';
PRINT '';
PRINT '🚀 FUNCIONALIDADES DISPONIBLES:';
PRINT '   📦 Gestión completa de lotes y trazabilidad';
PRINT '   🔔 Sistema de notificaciones multi-canal';
PRINT '   📧 Plantillas de email personalizadas';
PRINT '   ⚙️ Configuración individual por usuario';
PRINT '   📊 Logs y estadísticas completas';
PRINT '   🔍 Índices optimizados para rendimiento';
PRINT '';
PRINT '📋 PRÓXIMOS PASOS:';
PRINT '   1. Limpiar caché de Laravel: php artisan cache:clear';
PRINT '   2. Probar el sistema en el frontend';
PRINT '   3. Verificar que las APIs funcionen correctamente';
PRINT '';
PRINT '🎯 ¡Los módulos están listos para usar en producción!';
GO
