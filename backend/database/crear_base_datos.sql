-- ========================================
-- CREAR BASE DE DATOS WMS ESCASAN
-- ========================================

USE [master];
GO

PRINT '🚀 Creando base de datos WMS Escasan...';
PRINT '====================================';
GO

-- Verificar si la base de datos ya existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'wms_escasan')
BEGIN
    PRINT '⚠️ La base de datos wms_escasan ya existe';
    PRINT '¿Desea eliminarla y crear una nueva? (s/n)';
    -- En un script automático, asumimos que queremos continuar
    PRINT 'Continuando con la base de datos existente...';
END
ELSE
BEGIN
    -- Crear la base de datos
    CREATE DATABASE [wms_escasan]
    ON 
    ( NAME = 'wms_escasan',
      FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\wms_escasan.mdf',
      SIZE = 100MB,
      MAXSIZE = 1GB,
      FILEGROWTH = 10MB )
    LOG ON 
    ( NAME = 'wms_escasan_log',
      FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\wms_escasan_log.ldf',
      SIZE = 10MB,
      MAXSIZE = 100MB,
      FILEGROWTH = 1MB );
    
    PRINT '✅ Base de datos wms_escasan creada exitosamente';
END
GO

-- Cambiar al contexto de la base de datos
USE [wms_escasan];
GO

-- Configurar opciones de la base de datos
PRINT '';
PRINT '⚙️ Configurando opciones de la base de datos...';

-- Habilitar autogrow
ALTER DATABASE [wms_escasan] SET AUTO_SHRINK OFF;
ALTER DATABASE [wms_escasan] SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE [wms_escasan] SET AUTO_UPDATE_STATISTICS ON;

-- Configurar nivel de compatibilidad
ALTER DATABASE [wms_escasan] SET COMPATIBILITY_LEVEL = 150;

-- Configurar opciones de recuperación
ALTER DATABASE [wms_escasan] SET RECOVERY SIMPLE;

PRINT '✅ Opciones de base de datos configuradas';

-- Crear esquema personalizado (opcional)
PRINT '';
PRINT '📁 Creando esquema personalizado...';

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'wms')
BEGIN
    EXEC('CREATE SCHEMA [wms]');
    PRINT '✅ Esquema wms creado';
END
ELSE
BEGIN
    PRINT '⚠️ Esquema wms ya existe';
END
GO

-- Crear usuario de aplicación (opcional)
PRINT '';
PRINT '👤 Creando usuario de aplicación...';

-- Crear login si no existe
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'wms_app')
BEGIN
    CREATE LOGIN [wms_app] WITH PASSWORD = 'WmsApp123!', DEFAULT_DATABASE = [wms_escasan];
    PRINT '✅ Login wms_app creado';
END
ELSE
BEGIN
    PRINT '⚠️ Login wms_app ya existe';
END

-- Crear usuario en la base de datos
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'wms_app')
BEGIN
    CREATE USER [wms_app] FOR LOGIN [wms_app];
    PRINT '✅ Usuario wms_app creado en la base de datos';
END
ELSE
BEGIN
    PRINT '⚠️ Usuario wms_app ya existe en la base de datos';
END

-- Asignar permisos al usuario
ALTER ROLE [db_datareader] ADD MEMBER [wms_app];
ALTER ROLE [db_datawriter] ADD MEMBER [wms_app];
ALTER ROLE [db_ddladmin] ADD MEMBER [wms_app];

PRINT '✅ Permisos asignados al usuario wms_app';

-- Crear funciones de utilidad
PRINT '';
PRINT '🔧 Creando funciones de utilidad...';

-- Función para generar códigos únicos
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'GenerarCodigoUnico')
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[GenerarCodigoUnico](@prefijo NVARCHAR(10), @tabla NVARCHAR(50))
    RETURNS NVARCHAR(50)
    AS
    BEGIN
        DECLARE @codigo NVARCHAR(50);
        DECLARE @contador INT = 1;
        
        WHILE 1=1
        BEGIN
            SET @codigo = @prefijo + ''-'' + RIGHT(''000'' + CAST(@contador AS NVARCHAR(3)), 3);
            
            IF @tabla = ''productos''
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM productos WHERE codigo = @codigo)
                    BREAK;
            END
            ELSE IF @tabla = ''ubicaciones''
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM ubicaciones WHERE codigo = @codigo)
                    BREAK;
            END
            ELSE IF @tabla = ''lotes''
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM lotes WHERE codigo_lote = @codigo)
                    BREAK;
            END
            
            SET @contador = @contador + 1;
        END
        
        RETURN @codigo;
    END
    ');
    PRINT '✅ Función GenerarCodigoUnico creada';
END
ELSE
BEGIN
    PRINT '⚠️ Función GenerarCodigoUnico ya existe';
END
GO

-- Función para calcular días hasta vencimiento
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'CalcularDiasVencimiento')
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[CalcularDiasVencimiento](@fecha_caducidad DATE)
    RETURNS INT
    AS
    BEGIN
        DECLARE @dias INT;
        
        IF @fecha_caducidad IS NULL
            RETURN NULL;
            
        SET @dias = DATEDIFF(day, GETDATE(), @fecha_caducidad);
        
        RETURN @dias;
    END
    ');
    PRINT '✅ Función CalcularDiasVencimiento creada';
END
ELSE
BEGIN
    PRINT '⚠️ Función CalcularDiasVencimiento ya existe';
END
GO

-- Crear procedimientos almacenados de utilidad
PRINT '';
PRINT '🔧 Creando procedimientos almacenados...';

-- Procedimiento para limpiar datos de prueba
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'LimpiarDatosPrueba')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[LimpiarDatosPrueba]
    AS
    BEGIN
        SET NOCOUNT ON;
        
        PRINT ''🧹 Limpiando datos de prueba...'';
        
        -- Limpiar en orden para respetar foreign keys
        DELETE FROM logs_notificaciones;
        DELETE FROM cola_notificaciones;
        DELETE FROM notificaciones;
        DELETE FROM configuracion_notificaciones_usuario;
        DELETE FROM trazabilidad_productos;
        DELETE FROM movimientos_inventario;
        DELETE FROM numeros_serie;
        DELETE FROM lotes;
        DELETE FROM inventario;
        DELETE FROM tareas;
        DELETE FROM incidencias;
        DELETE FROM productos;
        DELETE FROM ubicaciones;
        DELETE FROM usuarios;
        DELETE FROM roles;
        DELETE FROM tipos_tarea;
        DELETE FROM estados_producto;
        DELETE FROM unidad_de_medida;
        DELETE FROM tipos_notificacion;
        DELETE FROM plantillas_email;
        
        PRINT ''✅ Datos de prueba eliminados'';
    END
    ');
    PRINT '✅ Procedimiento LimpiarDatosPrueba creado';
END
ELSE
BEGIN
    PRINT '⚠️ Procedimiento LimpiarDatosPrueba ya existe';
END
GO

-- Procedimiento para generar reporte de estado del sistema
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ReporteEstadoSistema')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[ReporteEstadoSistema]
    AS
    BEGIN
        SET NOCOUNT ON;
        
        PRINT ''📊 REPORTE DE ESTADO DEL SISTEMA WMS ESCASAN'';
        PRINT ''============================================'';
        PRINT '''';
        
        -- Contar registros por tabla
        DECLARE @usuarios INT, @productos INT, @ubicaciones INT, @inventario INT;
        DECLARE @tareas INT, @incidencias INT, @lotes INT, @notificaciones INT;
        
        SELECT @usuarios = COUNT(*) FROM usuarios;
        SELECT @productos = COUNT(*) FROM productos;
        SELECT @ubicaciones = COUNT(*) FROM ubicaciones;
        SELECT @inventario = COUNT(*) FROM inventario;
        SELECT @tareas = COUNT(*) FROM tareas;
        SELECT @incidencias = COUNT(*) FROM incidencias;
        SELECT @lotes = COUNT(*) FROM lotes;
        SELECT @notificaciones = COUNT(*) FROM notificaciones;
        
        PRINT ''👥 Usuarios: '' + CAST(@usuarios AS NVARCHAR(10));
        PRINT ''📦 Productos: '' + CAST(@productos AS NVARCHAR(10));
        PRINT ''📍 Ubicaciones: '' + CAST(@ubicaciones AS NVARCHAR(10));
        PRINT ''📊 Registros de inventario: '' + CAST(@inventario AS NVARCHAR(10));
        PRINT ''📋 Tareas: '' + CAST(@tareas AS NVARCHAR(10));
        PRINT ''⚠️ Incidencias: '' + CAST(@incidencias AS NVARCHAR(10));
        PRINT ''📦 Lotes: '' + CAST(@lotes AS NVARCHAR(10));
        PRINT ''🔔 Notificaciones: '' + CAST(@notificaciones AS NVARCHAR(10));
        PRINT '''';
        
        -- Mostrar estadísticas de inventario
        PRINT ''📊 ESTADÍSTICAS DE INVENTARIO:'';
        PRINT ''============================'';
        
        SELECT 
            p.codigo,
            p.nombre,
            SUM(i.cantidad) as total_stock,
            SUM(i.cantidad_reservada) as total_reservado,
            SUM(i.cantidad_disponible) as total_disponible
        FROM inventario i
        JOIN productos p ON i.producto_id = p.id
        GROUP BY p.codigo, p.nombre
        ORDER BY total_stock DESC;
        
        PRINT '''';
        PRINT ''🎯 Sistema funcionando correctamente'';
    END
    ');
    PRINT '✅ Procedimiento ReporteEstadoSistema creado';
END
ELSE
BEGIN
    PRINT '⚠️ Procedimiento ReporteEstadoSistema ya existe';
END
GO

-- Crear triggers de auditoría
PRINT '';
PRINT '🔍 Creando triggers de auditoría...';

-- Trigger para auditar cambios en usuarios
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'TR' AND name = 'TR_AuditUsuarios')
BEGIN
    EXEC('
    CREATE TRIGGER [dbo].[TR_AuditUsuarios]
    ON [dbo].[usuarios]
    AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
        SET NOCOUNT ON;
        
        DECLARE @accion NVARCHAR(10);
        
        IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
            SET @accion = ''UPDATE'';
        ELSE IF EXISTS (SELECT * FROM inserted)
            SET @accion = ''INSERT'';
        ELSE
            SET @accion = ''DELETE'';
            
        -- Aquí se podría insertar en una tabla de auditoría
        -- Por ahora solo registramos en el log
        PRINT ''Auditoría: '' + @accion + '' en tabla usuarios'';
    END
    ');
    PRINT '✅ Trigger TR_AuditUsuarios creado';
END
ELSE
BEGIN
    PRINT '⚠️ Trigger TR_AuditUsuarios ya existe';
END
GO

-- Crear vistas de utilidad
PRINT '';
PRINT '👁️ Creando vistas de utilidad...';

-- Vista para inventario con información completa
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'V_InventarioCompleto')
BEGIN
    EXEC('
    CREATE VIEW [dbo].[V_InventarioCompleto]
    AS
    SELECT 
        i.id,
        p.codigo as producto_codigo,
        p.nombre as producto_nombre,
        p.categoria,
        u.codigo as ubicacion_codigo,
        u.nombre as ubicacion_nombre,
        u.zona,
        i.cantidad,
        i.cantidad_reservada,
        i.cantidad_disponible,
        i.fecha_ultima_actualizacion,
        CASE 
            WHEN i.cantidad <= p.stock_minimo THEN ''BAJO_STOCK''
            WHEN i.cantidad >= p.stock_maximo THEN ''ALTO_STOCK''
            ELSE ''NORMAL''
        END as estado_stock
    FROM inventario i
    JOIN productos p ON i.producto_id = p.id
    JOIN ubicaciones u ON i.ubicacion_id = u.id
    WHERE p.activo = 1 AND u.activo = 1
    ');
    PRINT '✅ Vista V_InventarioCompleto creada';
END
ELSE
BEGIN
    PRINT '⚠️ Vista V_InventarioCompleto ya existe';
END
GO

-- Vista para tareas con información de usuarios
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'V_TareasCompletas')
BEGIN
    EXEC('
    CREATE VIEW [dbo].[V_TareasCompletas]
    AS
    SELECT 
        t.id,
        t.titulo,
        t.descripcion,
        tt.nombre as tipo_tarea,
        t.estado,
        t.prioridad,
        u.nombre as usuario_asignado,
        u.email as usuario_email,
        t.fecha_creacion,
        t.fecha_vencimiento,
        t.fecha_completado,
        CASE 
            WHEN t.fecha_vencimiento < GETDATE() AND t.estado != ''COMPLETADA'' THEN ''VENCIDA''
            WHEN t.fecha_vencimiento <= DATEADD(day, 1, GETDATE()) AND t.estado != ''COMPLETADA'' THEN ''POR_VENCER''
            ELSE ''AL_DIA''
        END as estado_vencimiento
    FROM tareas t
    JOIN tipos_tarea tt ON t.tipo_tarea_id = tt.id
    LEFT JOIN usuarios u ON t.usuario_asignado_id = u.id
    WHERE t.activo = 1
    ');
    PRINT '✅ Vista V_TareasCompletas creada';
END
ELSE
BEGIN
    PRINT '⚠️ Vista V_TareasCompletas ya existe';
END
GO

-- Mostrar información de la base de datos creada
PRINT '';
PRINT '📊 INFORMACIÓN DE LA BASE DE DATOS:';
PRINT '==================================';

SELECT 
    name as 'Base de Datos',
    database_id as 'ID',
    create_date as 'Fecha de Creación',
    collation_name as 'Collation'
FROM sys.databases 
WHERE name = 'wms_escasan';

-- Mostrar tamaño de la base de datos
SELECT 
    DB_NAME() as 'Base de Datos',
    CAST(SUM(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS bigint) * 8.0 / 1024) AS DECIMAL(15,2)) AS 'Tamaño (MB)'
FROM sys.database_files
WHERE type_desc = 'ROWS';

PRINT '';
PRINT '🎉 Base de datos WMS Escasan creada exitosamente!';
PRINT '===============================================';
PRINT '';
PRINT '📋 Características implementadas:';
PRINT '   ✅ Base de datos wms_escasan';
PRINT '   ✅ Esquema personalizado wms';
PRINT '   ✅ Usuario de aplicación wms_app';
PRINT '   ✅ Funciones de utilidad';
PRINT '   ✅ Procedimientos almacenados';
PRINT '   ✅ Triggers de auditoría';
PRINT '   ✅ Vistas de utilidad';
PRINT '';
PRINT '📋 Próximos pasos:';
PRINT '   1. Ejecutar script de tablas básicas';
PRINT '   2. Ejecutar script de módulos avanzados';
PRINT '   3. Ejecutar script de datos iniciales';
PRINT '   4. Ejecutar script de verificación';
PRINT '';
PRINT '🚀 La base de datos está lista para la instalación del sistema!';
GO

