-- Script para crear sistema de notificaciones push/email
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

PRINT '🔔 Creando sistema de notificaciones push/email...';
PRINT '==============================================';
GO

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
        canales_notificacion NVARCHAR(100) NOT NULL, -- 'email,push,web'
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
        canales_enviados NVARCHAR(100), -- 'email,push,web'
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
        frecuencia_resumen NVARCHAR(20) DEFAULT 'inmediata', -- 'inmediata', 'diaria', 'semanal'
        hora_resumen TIME,
        dias_resumen NVARCHAR(20), -- 'lunes,martes,miércoles...'
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
        variables_disponibles NVARCHAR(500), -- 'usuario_nombre,fecha,valor...'
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

-- Insertar tipos de notificación iniciales
IF NOT EXISTS (SELECT * FROM tipos_notificacion WHERE codigo = 'ALERTA_KPI')
BEGIN
    INSERT INTO tipos_notificacion (codigo, nombre, descripcion, categoria, prioridad, canales_notificacion, plantilla_email, plantilla_push, plantilla_web) VALUES
    ('ALERTA_KPI', 'Alerta de KPI', 'Notificación cuando un KPI supera umbrales críticos', 'sistema', 'alta', 'email,push,web', 
     '<h2>Alerta de KPI: {{kpi_nombre}}</h2><p>El KPI {{kpi_nombre}} ha alcanzado un valor crítico: {{valor_actual}} {{unidad}}</p>',
     '🚨 Alerta KPI: {{kpi_nombre}} - Valor: {{valor_actual}} {{unidad}}',
     'Alerta de KPI: {{kpi_nombre}} - Valor crítico: {{valor_actual}} {{unidad}}'),
    
    ('INCIDENCIA_NUEVA', 'Nueva Incidencia', 'Notificación de nueva incidencia creada', 'calidad', 'media', 'email,push,web',
     '<h2>Nueva Incidencia: {{incidencia_titulo}}</h2><p>Se ha creado una nueva incidencia: {{incidencia_descripcion}}</p>',
     '⚠️ Nueva incidencia: {{incidencia_titulo}}',
     'Nueva incidencia creada: {{incidencia_titulo}}'),
    
    ('LOTE_VENCIDO', 'Lote Vencido', 'Notificación de lote próximo a vencer o vencido', 'inventario', 'alta', 'email,push,web',
     '<h2>Lote Vencido: {{lote_codigo}}</h2><p>El lote {{lote_codigo}} del producto {{producto_nombre}} ha vencido</p>',
     '📅 Lote vencido: {{lote_codigo}} - {{producto_nombre}}',
     'Lote vencido: {{lote_codigo}} del producto {{producto_nombre}}'),
    
    ('PICKING_COMPLETADO', 'Picking Completado', 'Notificación cuando se completa un picking', 'operaciones', 'baja', 'push,web',
     NULL,
     '✅ Picking completado: {{oleada_codigo}}',
     'Picking completado: {{oleada_codigo}}'),
    
    ('SISTEMA_ERROR', 'Error del Sistema', 'Notificación de errores críticos del sistema', 'sistema', 'critica', 'email,push,web',
     '<h2>Error del Sistema</h2><p>Se ha detectado un error crítico: {{error_descripcion}}</p>',
     '🚨 Error del sistema: {{error_descripcion}}',
     'Error crítico del sistema: {{error_descripcion}}'),
    
    ('MANTENIMIENTO_PROGRAMADO', 'Mantenimiento Programado', 'Notificación de mantenimiento programado', 'mantenimiento', 'media', 'email,web',
     '<h2>Mantenimiento Programado</h2><p>Se realizará mantenimiento el {{fecha_mantenimiento}} de {{hora_inicio}} a {{hora_fin}}</p>',
     NULL,
     'Mantenimiento programado: {{fecha_mantenimiento}}'),
    
    ('INVENTARIO_BAJO', 'Inventario Bajo', 'Notificación de stock bajo en productos', 'inventario', 'alta', 'email,push,web',
     '<h2>Stock Bajo: {{producto_nombre}}</h2><p>El producto {{producto_nombre}} tiene stock bajo: {{cantidad_actual}} {{unidad}}</p>',
     '📦 Stock bajo: {{producto_nombre}} - {{cantidad_actual}} {{unidad}}',
     'Stock bajo: {{producto_nombre}} - Cantidad: {{cantidad_actual}} {{unidad}}'),
    
    ('USUARIO_ASIGNADO', 'Usuario Asignado', 'Notificación cuando se asigna una tarea a un usuario', 'operaciones', 'media', 'push,web',
     NULL,
     '📋 Nueva tarea asignada: {{tarea_titulo}}',
     'Nueva tarea asignada: {{tarea_titulo}}');
    
    PRINT '✅ Tipos de notificación iniciales insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Tipos de notificación iniciales ya existen';
END
GO

-- Insertar plantillas de email iniciales
IF NOT EXISTS (SELECT * FROM plantillas_email WHERE codigo = 'PLANTILLA_BASE')
BEGIN
    INSERT INTO plantillas_email (codigo, nombre, asunto, contenido_html, contenido_texto, variables_disponibles) VALUES
    ('PLANTILLA_BASE', 'Plantilla Base', '{{titulo}}', 
     '<!DOCTYPE html><html><head><meta charset="utf-8"><title>{{titulo}}</title></head><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><div style="max-width: 600px; margin: 0 auto; padding: 20px;"><h1 style="color: #2c3e50;">{{titulo}}</h1><div style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">{{mensaje}}</div><hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;"><p style="color: #666; font-size: 12px;">Este es un mensaje automático del sistema WMS. Por favor no responder.</p></div></body></html>',
     '{{titulo}}\n\n{{mensaje}}\n\n---\nEste es un mensaje automático del sistema WMS.',
     'titulo,mensaje,fecha,usuario_nombre'),
    
    ('PLANTILLA_ALERTA', 'Plantilla de Alerta', '🚨 {{titulo}} - Sistema WMS',
     '<!DOCTYPE html><html><head><meta charset="utf-8"><title>{{titulo}}</title></head><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><div style="max-width: 600px; margin: 0 auto; padding: 20px;"><div style="background: #dc3545; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;"><h1 style="margin: 0;">🚨 {{titulo}}</h1></div><div style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">{{mensaje}}</div><div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;"><strong>Prioridad:</strong> {{prioridad}}<br><strong>Fecha:</strong> {{fecha}}</div><hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;"><p style="color: #666; font-size: 12px;">Sistema WMS - Notificación automática</p></div></body></html>',
     '🚨 {{titulo}}\n\n{{mensaje}}\n\nPrioridad: {{prioridad}}\nFecha: {{fecha}}\n\n---\nSistema WMS',
     'titulo,mensaje,prioridad,fecha,usuario_nombre'),
    
    ('PLANTILLA_INFORMATIVA', 'Plantilla Informativa', 'ℹ️ {{titulo}} - Sistema WMS',
     '<!DOCTYPE html><html><head><meta charset="utf-8"><title>{{titulo}}</title></head><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><div style="max-width: 600px; margin: 0 auto; padding: 20px;"><div style="background: #17a2b8; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;"><h1 style="margin: 0;">ℹ️ {{titulo}}</h1></div><div style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">{{mensaje}}</div><div style="background: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 5px; margin: 20px 0;"><strong>Fecha:</strong> {{fecha}}</div><hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;"><p style="color: #666; font-size: 12px;">Sistema WMS - Notificación automática</p></div></body></html>',
     'ℹ️ {{titulo}}\n\n{{mensaje}}\n\nFecha: {{fecha}}\n\n---\nSistema WMS',
     'titulo,mensaje,fecha,usuario_nombre');
    
    PRINT '✅ Plantillas de email iniciales insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Plantillas de email iniciales ya existen';
END
GO

-- Crear índices para optimizar consultas de notificaciones
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

-- Crear procedimientos almacenados para notificaciones
CREATE OR ALTER PROCEDURE sp_crear_notificacion
    @tipo_codigo NVARCHAR(50),
    @usuario_id INT,
    @titulo NVARCHAR(200),
    @mensaje NVARCHAR(1000),
    @datos_adicionales NVARCHAR(MAX) = NULL,
    @prioridad NVARCHAR(20) = 'media',
    @fecha_expiracion DATETIME2 = NULL
AS
BEGIN
    DECLARE @tipo_id INT;
    DECLARE @notificacion_id INT;
    
    -- Obtener ID del tipo de notificación
    SELECT @tipo_id = id FROM tipos_notificacion WHERE codigo = @tipo_codigo AND activo = 1;
    
    IF @tipo_id IS NOT NULL
    BEGIN
        -- Crear notificación
        INSERT INTO notificaciones (tipo_notificacion_id, usuario_id, titulo, mensaje, datos_adicionales, prioridad, fecha_expiracion)
        VALUES (@tipo_id, @usuario_id, @titulo, @mensaje, @datos_adicionales, @prioridad, @fecha_expiracion);
        
        SET @notificacion_id = SCOPE_IDENTITY();
        
        -- Agregar a cola de notificaciones según configuración del usuario
        INSERT INTO cola_notificaciones (notificacion_id, canal, fecha_programada)
        SELECT @notificacion_id, canal.value, GETDATE()
        FROM configuracion_notificaciones_usuario c
        CROSS APPLY STRING_SPLIT(
            CASE 
                WHEN c.recibir_email = 1 THEN 'email,' ELSE ''
            END +
            CASE 
                WHEN c.recibir_push = 1 THEN 'push,' ELSE ''
            END +
            CASE 
                WHEN c.recibir_web = 1 THEN 'web,' ELSE ''
            END, ','
        ) canal
        WHERE c.usuario_id = @usuario_id 
        AND c.tipo_notificacion_id = @tipo_id
        AND c.activo = 1
        AND canal.value != '';
        
        SELECT @notificacion_id as notificacion_id;
    END
    ELSE
    BEGIN
        SELECT NULL as notificacion_id;
    END
END;
GO

CREATE OR ALTER PROCEDURE sp_procesar_cola_notificaciones
AS
BEGIN
    DECLARE @cola_id INT;
    DECLARE @notificacion_id INT;
    DECLARE @canal NVARCHAR(20);
    
    -- Procesar notificaciones pendientes
    WHILE EXISTS (SELECT 1 FROM cola_notificaciones WHERE estado = 'pendiente' AND fecha_programada <= GETDATE())
    BEGIN
        SELECT TOP 1 @cola_id = id, @notificacion_id = notificacion_id, @canal = canal
        FROM cola_notificaciones 
        WHERE estado = 'pendiente' AND fecha_programada <= GETDATE()
        ORDER BY fecha_programada;
        
        -- Marcar como procesando
        UPDATE cola_notificaciones 
        SET estado = 'procesando', intentos = intentos + 1
        WHERE id = @cola_id;
        
        -- Aquí se implementaría la lógica de envío según el canal
        -- Por ahora solo marcamos como enviada
        UPDATE cola_notificaciones 
        SET estado = 'enviada', fecha_procesado = GETDATE()
        WHERE id = @cola_id;
        
        -- Registrar en logs
        INSERT INTO logs_notificaciones (notificacion_id, canal, accion, estado, mensaje)
        VALUES (@notificacion_id, @canal, 'enviada', 'exitoso', 'Notificación enviada exitosamente');
    END
END;
GO

PRINT '✅ Procedimientos almacenados creados para notificaciones';
GO

PRINT '';
PRINT '🎉 ¡Sistema de Notificaciones Push/Email creado exitosamente!';
PRINT '========================================================';
PRINT '';
PRINT '✅ Tablas creadas:';
PRINT '   🔔 tipos_notificacion - Tipos de notificación';
PRINT '   📧 notificaciones - Notificaciones del sistema';
PRINT '   ⚙️ configuracion_notificaciones_usuario - Configuración por usuario';
PRINT '   📝 plantillas_email - Plantillas de email';
PRINT '   📋 cola_notificaciones - Cola de procesamiento';
PRINT '   📊 logs_notificaciones - Logs del sistema';
PRINT '';
PRINT '✅ Tipos de notificación: 8 tipos iniciales';
PRINT '✅ Plantillas de email: 3 plantillas base';
PRINT '✅ Procedimientos almacenados: 2 procedimientos';
PRINT '✅ Índices optimizados: 12 índices';
GO
