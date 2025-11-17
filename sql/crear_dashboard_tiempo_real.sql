-- Script para crear sistema de dashboard en tiempo real con KPIs
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

PRINT '📊 Creando sistema de dashboard en tiempo real con KPIs...';
PRINT '====================================================';
GO

-- 1. Tabla de KPIs del sistema
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'kpis_sistema')
BEGIN
    CREATE TABLE kpis_sistema (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        categoria NVARCHAR(50) NOT NULL,
        tipo_metrica NVARCHAR(30) NOT NULL,
        unidad NVARCHAR(20),
        valor_objetivo DECIMAL(10,2),
        valor_minimo DECIMAL(10,2),
        valor_maximo DECIMAL(10,2),
        frecuencia_actualizacion INT DEFAULT 60, -- minutos
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT CHK_kpis_tipo CHECK (tipo_metrica IN ('contador', 'porcentaje', 'tiempo', 'cantidad', 'valor_monetario', 'ratio'))
    );
    PRINT '✅ Tabla kpis_sistema creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla kpis_sistema ya existe';
END
GO

-- 2. Tabla de valores históricos de KPIs
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'kpis_historicos')
BEGIN
    CREATE TABLE kpis_historicos (
        id INT IDENTITY(1,1) PRIMARY KEY,
        kpi_id INT NOT NULL,
        fecha_medicion DATETIME2 NOT NULL,
        valor DECIMAL(15,4) NOT NULL,
        valor_anterior DECIMAL(15,4),
        tendencia NVARCHAR(20),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_kpis_historicos_kpi FOREIGN KEY (kpi_id) REFERENCES kpis_sistema(id),
        CONSTRAINT CHK_kpis_tendencia CHECK (tendencia IN ('ascendente', 'descendente', 'estable', 'volatil'))
    );
    PRINT '✅ Tabla kpis_historicos creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla kpis_historicos ya existe';
END
GO

-- 3. Tabla de alertas del dashboard
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'alertas_dashboard')
BEGIN
    CREATE TABLE alertas_dashboard (
        id INT IDENTITY(1,1) PRIMARY KEY,
        kpi_id INT NOT NULL,
        tipo_alerta NVARCHAR(30) NOT NULL,
        nivel_criticidad NVARCHAR(20) NOT NULL,
        mensaje NVARCHAR(500) NOT NULL,
        valor_actual DECIMAL(15,4),
        valor_umbral DECIMAL(15,4),
        fecha_alerta DATETIME2 DEFAULT GETDATE(),
        fecha_resolucion DATETIME2,
        estado NVARCHAR(20) NOT NULL DEFAULT 'activa',
        usuario_notificado INT,
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_alertas_kpi FOREIGN KEY (kpi_id) REFERENCES kpis_sistema(id),
        CONSTRAINT FK_alertas_usuario FOREIGN KEY (usuario_notificado) REFERENCES usuarios(id),
        CONSTRAINT CHK_alertas_tipo CHECK (tipo_alerta IN ('umbral_superado', 'umbral_inferior', 'tendencia_negativa', 'valor_atipico', 'sistema_error')),
        CONSTRAINT CHK_alertas_nivel CHECK (nivel_criticidad IN ('baja', 'media', 'alta', 'critica')),
        CONSTRAINT CHK_alertas_estado CHECK (estado IN ('activa', 'resuelta', 'descartada'))
    );
    PRINT '✅ Tabla alertas_dashboard creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla alertas_dashboard ya existe';
END
GO

-- 4. Tabla de widgets del dashboard
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'widgets_dashboard')
BEGIN
    CREATE TABLE widgets_dashboard (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL,
        tipo_widget NVARCHAR(30) NOT NULL,
        configuracion NVARCHAR(MAX),
        posicion_x INT DEFAULT 0,
        posicion_y INT DEFAULT 0,
        ancho INT DEFAULT 4,
        alto INT DEFAULT 3,
        usuario_id INT,
        es_global BIT DEFAULT 0,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_widgets_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_widgets_tipo CHECK (tipo_widget IN ('grafico_linea', 'grafico_barras', 'grafico_pie', 'kpi_card', 'tabla_datos', 'mapa_calor', 'indicador_tendencia'))
    );
    PRINT '✅ Tabla widgets_dashboard creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla widgets_dashboard ya existe';
END
GO

-- 5. Tabla de métricas en tiempo real
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'metricas_tiempo_real')
BEGIN
    CREATE TABLE metricas_tiempo_real (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo_metrica NVARCHAR(50) NOT NULL,
        nombre NVARCHAR(100) NOT NULL,
        valor_actual DECIMAL(15,4) NOT NULL,
        valor_anterior DECIMAL(15,4),
        fecha_actualizacion DATETIME2 DEFAULT GETDATE(),
        intervalo_actualizacion INT DEFAULT 30, -- segundos
        fuente_datos NVARCHAR(100),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT '✅ Tabla metricas_tiempo_real creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla metricas_tiempo_real ya existe';
END
GO

-- Insertar KPIs iniciales del sistema
IF NOT EXISTS (SELECT * FROM kpis_sistema WHERE codigo = 'EFICIENCIA_PICKING')
BEGIN
    INSERT INTO kpis_sistema (codigo, nombre, descripcion, categoria, tipo_metrica, unidad, valor_objetivo, valor_minimo, valor_maximo, frecuencia_actualizacion) VALUES
    ('EFICIENCIA_PICKING', 'Eficiencia de Picking', 'Porcentaje de eficiencia en el proceso de picking', 'OPERACIONES', 'porcentaje', '%', 95.00, 80.00, 100.00, 30),
    ('TIEMPO_PROMEDIO_PICKING', 'Tiempo Promedio de Picking', 'Tiempo promedio para completar un picking', 'OPERACIONES', 'tiempo', 'min', 15.00, 5.00, 30.00, 15),
    ('PRECISION_INVENTARIO', 'Precisión de Inventario', 'Porcentaje de precisión en el inventario', 'INVENTARIO', 'porcentaje', '%', 98.00, 90.00, 100.00, 60),
    ('ROTACION_STOCK', 'Rotación de Stock', 'Veces que se rota el inventario por mes', 'INVENTARIO', 'ratio', 'veces', 4.00, 2.00, 8.00, 60),
    ('TIEMPO_RESOLUCION_INCIDENCIAS', 'Tiempo de Resolución de Incidencias', 'Tiempo promedio para resolver incidencias', 'CALIDAD', 'tiempo', 'horas', 2.00, 0.50, 8.00, 30),
    ('SATISFACCION_CLIENTE', 'Satisfacción del Cliente', 'Nivel de satisfacción del cliente', 'CLIENTE', 'porcentaje', '%', 90.00, 70.00, 100.00, 120),
    ('UTILIZACION_UBICACIONES', 'Utilización de Ubicaciones', 'Porcentaje de utilización de ubicaciones', 'CAPACIDAD', 'porcentaje', '%', 85.00, 60.00, 95.00, 60),
    ('COSTO_OPERACION', 'Costo por Operación', 'Costo promedio por operación de almacén', 'FINANCIERO', 'valor_monetario', '$', 5.00, 2.00, 10.00, 60),
    ('DISPONIBILIDAD_SISTEMA', 'Disponibilidad del Sistema', 'Porcentaje de disponibilidad del sistema', 'TECNOLOGIA', 'porcentaje', '%', 99.50, 95.00, 100.00, 15),
    ('PRODUCTIVIDAD_OPERARIO', 'Productividad por Operario', 'Items procesados por operario por hora', 'RECURSOS_HUMANOS', 'cantidad', 'items/h', 50.00, 30.00, 80.00, 30);
    PRINT '✅ KPIs iniciales insertados';
END
ELSE
BEGIN
    PRINT '⚠️ KPIs iniciales ya existen';
END
GO

-- Insertar métricas en tiempo real iniciales
IF NOT EXISTS (SELECT * FROM metricas_tiempo_real WHERE codigo_metrica = 'PICKING_ACTIVO')
BEGIN
    INSERT INTO metricas_tiempo_real (codigo_metrica, nombre, valor_actual, intervalo_actualizacion, fuente_datos) VALUES
    ('PICKING_ACTIVO', 'Picking Activos', 0, 30, 'oleadas_picking'),
    ('INCIDENCIAS_ABIERTAS', 'Incidencias Abiertas', 0, 60, 'incidencias'),
    ('INVENTARIO_TOTAL', 'Inventario Total', 0, 60, 'inventario'),
    ('UBICACIONES_OCUPADAS', 'Ubicaciones Ocupadas', 0, 60, 'ubicaciones'),
    ('OPERARIOS_ACTIVOS', 'Operarios Activos', 0, 30, 'usuarios'),
    ('PEDIDOS_PENDIENTES', 'Pedidos Pendientes', 0, 30, 'pedidos_picking'),
    ('LOTES_VENCIDOS', 'Lotes Vencidos', 0, 60, 'lotes'),
    ('TEMPERATURA_PROMEDIO', 'Temperatura Promedio', 20.00, 15, 'ubicaciones'),
    ('HUMEDAD_PROMEDIO', 'Humedad Promedio', 50.00, 15, 'ubicaciones'),
    ('ERRORES_SISTEMA', 'Errores del Sistema', 0, 30, 'logs_sistema');
    PRINT '✅ Métricas en tiempo real iniciales insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Métricas en tiempo real iniciales ya existen';
END
GO

-- Crear índices para optimizar consultas del dashboard
CREATE NONCLUSTERED INDEX idx_kpis_categoria ON kpis_sistema(categoria);
CREATE NONCLUSTERED INDEX idx_kpis_activo ON kpis_sistema(activo);

CREATE NONCLUSTERED INDEX idx_kpis_historicos_kpi ON kpis_historicos(kpi_id);
CREATE NONCLUSTERED INDEX idx_kpis_historicos_fecha ON kpis_historicos(fecha_medicion);

CREATE NONCLUSTERED INDEX idx_alertas_kpi ON alertas_dashboard(kpi_id);
CREATE NONCLUSTERED INDEX idx_alertas_estado ON alertas_dashboard(estado);
CREATE NONCLUSTERED INDEX idx_alertas_fecha ON alertas_dashboard(fecha_alerta);
CREATE NONCLUSTERED INDEX idx_alertas_nivel ON alertas_dashboard(nivel_criticidad);

CREATE NONCLUSTERED INDEX idx_widgets_usuario ON widgets_dashboard(usuario_id);
CREATE NONCLUSTERED INDEX idx_widgets_activo ON widgets_dashboard(activo);

CREATE NONCLUSTERED INDEX idx_metricas_codigo ON metricas_tiempo_real(codigo_metrica);
CREATE NONCLUSTERED INDEX idx_metricas_activo ON metricas_tiempo_real(activo);
CREATE NONCLUSTERED INDEX idx_metricas_fecha ON metricas_tiempo_real(fecha_actualizacion);

PRINT '✅ Índices creados para dashboard';
GO

-- Crear procedimientos almacenados para actualizar KPIs
CREATE OR ALTER PROCEDURE sp_actualizar_kpi
    @kpi_codigo NVARCHAR(50),
    @nuevo_valor DECIMAL(15,4)
AS
BEGIN
    DECLARE @kpi_id INT;
    DECLARE @valor_anterior DECIMAL(15,4);
    DECLARE @tendencia NVARCHAR(20);
    
    -- Obtener ID del KPI
    SELECT @kpi_id = id FROM kpis_sistema WHERE codigo = @kpi_codigo AND activo = 1;
    
    IF @kpi_id IS NOT NULL
    BEGIN
        -- Obtener valor anterior
        SELECT TOP 1 @valor_anterior = valor 
        FROM kpis_historicos 
        WHERE kpi_id = @kpi_id 
        ORDER BY fecha_medicion DESC;
        
        -- Determinar tendencia
        IF @valor_anterior IS NULL
            SET @tendencia = 'estable';
        ELSE IF @nuevo_valor > @valor_anterior * 1.05
            SET @tendencia = 'ascendente';
        ELSE IF @nuevo_valor < @valor_anterior * 0.95
            SET @tendencia = 'descendente';
        ELSE
            SET @tendencia = 'estable';
        
        -- Insertar nuevo valor histórico
        INSERT INTO kpis_historicos (kpi_id, fecha_medicion, valor, valor_anterior, tendencia)
        VALUES (@kpi_id, GETDATE(), @nuevo_valor, @valor_anterior, @tendencia);
        
        -- Verificar alertas
        EXEC sp_verificar_alertas_kpi @kpi_id, @nuevo_valor;
    END
END;
GO

CREATE OR ALTER PROCEDURE sp_verificar_alertas_kpi
    @kpi_id INT,
    @valor_actual DECIMAL(15,4)
AS
BEGIN
    DECLARE @valor_objetivo DECIMAL(10,2);
    DECLARE @valor_minimo DECIMAL(10,2);
    DECLARE @valor_maximo DECIMAL(10,2);
    DECLARE @codigo_kpi NVARCHAR(50);
    DECLARE @nombre_kpi NVARCHAR(100);
    
    -- Obtener configuración del KPI
    SELECT @valor_objetivo = valor_objetivo,
           @valor_minimo = valor_minimo,
           @valor_maximo = valor_maximo,
           @codigo_kpi = codigo,
           @nombre_kpi = nombre
    FROM kpis_sistema 
    WHERE id = @kpi_id;
    
    -- Verificar si hay alertas activas
    IF NOT EXISTS (SELECT 1 FROM alertas_dashboard WHERE kpi_id = @kpi_id AND estado = 'activa')
    BEGIN
        -- Alerta por valor superior al máximo
        IF @valor_actual > @valor_maximo
        BEGIN
            INSERT INTO alertas_dashboard (kpi_id, tipo_alerta, nivel_criticidad, mensaje, valor_actual, valor_umbral)
            VALUES (@kpi_id, 'umbral_superado', 'alta', 
                   'El KPI ' + @nombre_kpi + ' ha superado el valor máximo permitido', 
                   @valor_actual, @valor_maximo);
        END
        
        -- Alerta por valor inferior al mínimo
        IF @valor_actual < @valor_minimo
        BEGIN
            INSERT INTO alertas_dashboard (kpi_id, tipo_alerta, nivel_criticidad, mensaje, valor_actual, valor_umbral)
            VALUES (@kpi_id, 'umbral_inferior', 'alta', 
                   'El KPI ' + @nombre_kpi + ' está por debajo del valor mínimo requerido', 
                   @valor_actual, @valor_minimo);
        END
    END
END;
GO

PRINT '✅ Procedimientos almacenados creados para dashboard';
GO

PRINT '';
PRINT '🎉 ¡Sistema de Dashboard en Tiempo Real con KPIs creado exitosamente!';
PRINT '================================================================';
PRINT '';
PRINT '✅ Tablas creadas:';
PRINT '   📊 kpis_sistema - Definición de KPIs';
PRINT '   📈 kpis_historicos - Valores históricos';
PRINT '   🚨 alertas_dashboard - Sistema de alertas';
PRINT '   🎛️ widgets_dashboard - Configuración de widgets';
PRINT '   ⚡ metricas_tiempo_real - Métricas en tiempo real';
PRINT '';
PRINT '✅ KPIs iniciales: 10 KPIs del sistema';
PRINT '✅ Métricas en tiempo real: 10 métricas';
PRINT '✅ Procedimientos almacenados: 2 procedimientos';
PRINT '✅ Índices optimizados: 15 índices';
GO
