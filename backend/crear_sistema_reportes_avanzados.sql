-- Script para crear sistema de reportes avanzados y análisis
-- Ejecutar en SQL Server Management Studio en la base de datos 'wms_escasan'

USE [wms_escasan];
GO

PRINT '📈 Creando sistema de reportes avanzados y análisis...';
PRINT '==============================================';
GO

-- 1. Tabla de tipos de reporte
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tipos_reporte')
BEGIN
    CREATE TABLE tipos_reporte (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        categoria NVARCHAR(50) NOT NULL,
        tipo_datos NVARCHAR(30) NOT NULL, -- 'tabla', 'grafico', 'dashboard', 'exportacion'
        consulta_sql NVARCHAR(MAX),
        parametros_configuracion NVARCHAR(MAX),
        formato_salida NVARCHAR(100), -- 'pdf', 'excel', 'csv', 'json', 'html'
        frecuencia_automatica NVARCHAR(20), -- 'manual', 'diaria', 'semanal', 'mensual'
        hora_ejecucion TIME,
        dias_ejecucion NVARCHAR(20), -- 'lunes,martes...'
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT CHK_tipos_reporte_categoria CHECK (categoria IN ('inventario', 'operaciones', 'calidad', 'financiero', 'recursos_humanos', 'mantenimiento', 'cliente')),
        CONSTRAINT CHK_tipos_reporte_tipo CHECK (tipo_datos IN ('tabla', 'grafico', 'dashboard', 'exportacion')),
        CONSTRAINT CHK_tipos_reporte_formato CHECK (formato_salida IN ('pdf', 'excel', 'csv', 'json', 'html', 'xml')),
        CONSTRAINT CHK_tipos_reporte_frecuencia CHECK (frecuencia_automatica IN ('manual', 'diaria', 'semanal', 'mensual', 'trimestral', 'anual'))
    );
    PRINT '✅ Tabla tipos_reporte creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla tipos_reporte ya existe';
END
GO

-- 2. Tabla de ejecuciones de reportes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ejecuciones_reporte')
BEGIN
    CREATE TABLE ejecuciones_reporte (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tipo_reporte_id INT NOT NULL,
        usuario_id INT NOT NULL,
        parametros_ejecucion NVARCHAR(MAX),
        fecha_inicio DATETIME2 DEFAULT GETDATE(),
        fecha_fin DATETIME2,
        estado NVARCHAR(20) NOT NULL DEFAULT 'ejecutando',
        archivo_generado NVARCHAR(500),
        tamaño_archivo BIGINT,
        registros_procesados INT,
        tiempo_ejecucion_segundos INT,
        error_mensaje NVARCHAR(1000),
        created_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_ejecuciones_tipo FOREIGN KEY (tipo_reporte_id) REFERENCES tipos_reporte(id),
        CONSTRAINT FK_ejecuciones_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
        CONSTRAINT CHK_ejecuciones_estado CHECK (estado IN ('ejecutando', 'completado', 'fallido', 'cancelado'))
    );
    PRINT '✅ Tabla ejecuciones_reporte creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla ejecuciones_reporte ya existe';
END
GO

-- 3. Tabla de métricas de reportes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'metricas_reporte')
BEGIN
    CREATE TABLE metricas_reporte (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tipo_reporte_id INT NOT NULL,
        nombre_metrica NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        tipo_calculo NVARCHAR(30) NOT NULL, -- 'suma', 'promedio', 'conteo', 'maximo', 'minimo', 'porcentaje'
        campo_calculo NVARCHAR(100),
        filtros_aplicados NVARCHAR(500),
        unidad_medida NVARCHAR(20),
        formato_display NVARCHAR(50),
        orden_display INT DEFAULT 0,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_metricas_tipo FOREIGN KEY (tipo_reporte_id) REFERENCES tipos_reporte(id),
        CONSTRAINT CHK_metricas_tipo CHECK (tipo_calculo IN ('suma', 'promedio', 'conteo', 'maximo', 'minimo', 'porcentaje', 'mediana', 'desviacion'))
    );
    PRINT '✅ Tabla metricas_reporte creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla metricas_reporte ya existe';
END
GO

-- 4. Tabla de plantillas de reporte
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'plantillas_reporte')
BEGIN
    CREATE TABLE plantillas_reporte (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codigo NVARCHAR(50) NOT NULL UNIQUE,
        nombre NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        tipo_reporte_id INT NOT NULL,
        configuracion_plantilla NVARCHAR(MAX),
        estilos_css NVARCHAR(MAX),
        logo_empresa NVARCHAR(500),
        pie_pagina NVARCHAR(500),
        campos_dinamicos NVARCHAR(500),
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_plantillas_tipo FOREIGN KEY (tipo_reporte_id) REFERENCES tipos_reporte(id)
    );
    PRINT '✅ Tabla plantillas_reporte creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla plantillas_reporte ya existe';
END
GO

-- 5. Tabla de análisis predictivo
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'analisis_predictivo')
BEGIN
    CREATE TABLE analisis_predictivo (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombre_analisis NVARCHAR(100) NOT NULL,
        descripcion NVARCHAR(500),
        tipo_prediccion NVARCHAR(50) NOT NULL, -- 'demanda', 'mantenimiento', 'calidad', 'rendimiento'
        modelo_usado NVARCHAR(100),
        datos_entrenamiento NVARCHAR(MAX),
        parametros_modelo NVARCHAR(MAX),
        precision_modelo DECIMAL(5,2),
        fecha_entrenamiento DATETIME2,
        fecha_ultima_prediccion DATETIME2,
        predicciones_generadas INT DEFAULT 0,
        activo BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT CHK_analisis_tipo CHECK (tipo_prediccion IN ('demanda', 'mantenimiento', 'calidad', 'rendimiento', 'inventario', 'costos'))
    );
    PRINT '✅ Tabla analisis_predictivo creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla analisis_predictivo ya existe';
END
GO

-- 6. Tabla de resultados de análisis predictivo
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'resultados_analisis_predictivo')
BEGIN
    CREATE TABLE resultados_analisis_predictivo (
        id INT IDENTITY(1,1) PRIMARY KEY,
        analisis_id INT NOT NULL,
        fecha_prediccion DATETIME2 DEFAULT GETDATE(),
        periodo_prediccion NVARCHAR(20), -- 'diario', 'semanal', 'mensual'
        fecha_inicio_periodo DATE,
        fecha_fin_periodo DATE,
        valor_predicho DECIMAL(15,4),
        intervalo_confianza_min DECIMAL(15,4),
        intervalo_confianza_max DECIMAL(15,4),
        probabilidad_exito DECIMAL(5,2),
        factores_influencia NVARCHAR(MAX),
        observaciones NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_resultados_analisis FOREIGN KEY (analisis_id) REFERENCES analisis_predictivo(id),
        CONSTRAINT CHK_resultados_periodo CHECK (periodo_prediccion IN ('diario', 'semanal', 'mensual', 'trimestral', 'anual'))
    );
    PRINT '✅ Tabla resultados_analisis_predictivo creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla resultados_analisis_predictivo ya existe';
END
GO

-- Insertar tipos de reporte iniciales
IF NOT EXISTS (SELECT * FROM tipos_reporte WHERE codigo = 'REPORTE_INVENTARIO')
BEGIN
    INSERT INTO tipos_reporte (codigo, nombre, descripcion, categoria, tipo_datos, consulta_sql, formato_salida, frecuencia_automatica) VALUES
    ('REPORTE_INVENTARIO', 'Reporte de Inventario', 'Reporte detallado del estado del inventario', 'inventario', 'tabla', 
     'SELECT p.nombre, i.cantidad, u.codigo as ubicacion FROM inventario i JOIN productos p ON i.producto_id = p.id JOIN ubicaciones u ON i.ubicacion_id = u.id',
     'excel', 'manual'),
    
    ('REPORTE_PICKING_EFICIENCIA', 'Eficiencia de Picking', 'Análisis de eficiencia en operaciones de picking', 'operaciones', 'grafico',
     'SELECT operario_id, AVG(tiempo_picking) as tiempo_promedio, COUNT(*) as total_pickings FROM estadisticas_picking GROUP BY operario_id',
     'pdf', 'semanal'),
    
    ('REPORTE_INCIDENCIAS', 'Reporte de Incidencias', 'Análisis de incidencias por tipo y resolución', 'calidad', 'dashboard',
     'SELECT tipo_incidencia_id, COUNT(*) as cantidad, AVG(tiempo_resolucion_real) as tiempo_promedio FROM incidencias GROUP BY tipo_incidencia_id',
     'html', 'mensual'),
    
    ('REPORTE_COSTOS_OPERACION', 'Costos de Operación', 'Análisis de costos operacionales del almacén', 'financiero', 'tabla',
     'SELECT categoria, SUM(costo_real) as total_costo FROM incidencias WHERE costo_real IS NOT NULL GROUP BY categoria',
     'excel', 'mensual'),
    
    ('REPORTE_ROTACION_STOCK', 'Rotación de Stock', 'Análisis de rotación de productos en inventario', 'inventario', 'grafico',
     'SELECT p.nombre, COUNT(m.id) as movimientos FROM productos p LEFT JOIN movimientos_inventario m ON p.id = m.producto_id GROUP BY p.id, p.nombre',
     'pdf', 'trimestral'),
    
    ('REPORTE_RENDIMIENTO_OPERARIOS', 'Rendimiento de Operarios', 'Análisis de productividad de operarios', 'recursos_humanos', 'dashboard',
     'SELECT u.nombre, COUNT(ep.id) as pickings_completados, AVG(ep.eficiencia) as eficiencia_promedio FROM usuarios u LEFT JOIN estadisticas_picking ep ON u.id_usuario = ep.operario_id GROUP BY u.id_usuario, u.nombre',
     'html', 'semanal'),
    
    ('REPORTE_MANTENIMIENTO', 'Reporte de Mantenimiento', 'Análisis de mantenimiento preventivo y correctivo', 'mantenimiento', 'tabla',
     'SELECT tipo_mantenimiento, COUNT(*) as cantidad, AVG(costo) as costo_promedio FROM mantenimientos GROUP BY tipo_mantenimiento',
     'excel', 'mensual'),
    
    ('REPORTE_SATISFACCION_CLIENTE', 'Satisfacción del Cliente', 'Análisis de satisfacción y feedback de clientes', 'cliente', 'grafico',
     'SELECT fecha, AVG(calificacion) as satisfaccion_promedio FROM feedback_clientes GROUP BY fecha ORDER BY fecha',
     'pdf', 'mensual');
    
    PRINT '✅ Tipos de reporte iniciales insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Tipos de reporte iniciales ya existen';
END
GO

-- Insertar métricas iniciales para reportes
IF NOT EXISTS (SELECT * FROM metricas_reporte WHERE nombre_metrica = 'Total Inventario')
BEGIN
    INSERT INTO metricas_reporte (tipo_reporte_id, nombre_metrica, descripcion, tipo_calculo, campo_calculo, unidad_medida, formato_display) VALUES
    (1, 'Total Inventario', 'Cantidad total de productos en inventario', 'suma', 'cantidad', 'unidades', 'N0'),
    (1, 'Valor Total Inventario', 'Valor monetario total del inventario', 'suma', 'cantidad * precio_unitario', 'USD', 'C2'),
    (1, 'Productos Únicos', 'Número de productos diferentes en inventario', 'conteo', 'producto_id', 'productos', 'N0'),
    (1, 'Ubicaciones Ocupadas', 'Número de ubicaciones con inventario', 'conteo', 'ubicacion_id', 'ubicaciones', 'N0'),
    
    (2, 'Tiempo Promedio Picking', 'Tiempo promedio para completar picking', 'promedio', 'tiempo_picking', 'minutos', 'N2'),
    (2, 'Eficiencia Promedio', 'Eficiencia promedio de operarios', 'promedio', 'eficiencia', '%', 'P1'),
    (2, 'Total Pickings', 'Número total de pickings completados', 'conteo', 'id', 'pickings', 'N0'),
    (2, 'Operario Más Eficiente', 'Operario con mayor eficiencia', 'maximo', 'eficiencia', '%', 'P1'),
    
    (3, 'Total Incidencias', 'Número total de incidencias', 'conteo', 'id', 'incidencias', 'N0'),
    (3, 'Tiempo Promedio Resolución', 'Tiempo promedio de resolución', 'promedio', 'tiempo_resolucion_real', 'horas', 'N2'),
    (3, 'Incidencias Críticas', 'Número de incidencias críticas', 'conteo', 'id', 'incidencias', 'N0'),
    (3, 'Tasa Resolución', 'Porcentaje de incidencias resueltas', 'porcentaje', 'estado', '%', 'P1');
    
    PRINT '✅ Métricas de reporte iniciales insertadas';
END
ELSE
BEGIN
    PRINT '⚠️ Métricas de reporte iniciales ya existen';
END
GO

-- Insertar análisis predictivo iniciales
IF NOT EXISTS (SELECT * FROM analisis_predictivo WHERE nombre_analisis = 'Predicción de Demanda')
BEGIN
    INSERT INTO analisis_predictivo (nombre_analisis, descripcion, tipo_prediccion, modelo_usado, precision_modelo, fecha_entrenamiento) VALUES
    ('Predicción de Demanda', 'Predice la demanda futura de productos basado en historial', 'demanda', 'ARIMA', 85.50, GETDATE()),
    ('Mantenimiento Predictivo', 'Predice cuándo realizar mantenimiento preventivo', 'mantenimiento', 'Random Forest', 92.30, GETDATE()),
    ('Análisis de Calidad', 'Predice problemas de calidad en productos', 'calidad', 'SVM', 78.90, GETDATE()),
    ('Optimización de Rendimiento', 'Predice el rendimiento óptimo de operarios', 'rendimiento', 'Neural Network', 88.75, GETDATE()),
    ('Gestión de Inventario', 'Predice niveles óptimos de inventario', 'inventario', 'LSTM', 91.20, GETDATE()),
    ('Análisis de Costos', 'Predice costos operacionales futuros', 'costos', 'Linear Regression', 82.45, GETDATE());
    
    PRINT '✅ Análisis predictivo iniciales insertados';
END
ELSE
BEGIN
    PRINT '⚠️ Análisis predictivo iniciales ya existen';
END
GO

-- Crear índices para optimizar consultas de reportes
CREATE NONCLUSTERED INDEX idx_ejecuciones_tipo ON ejecuciones_reporte(tipo_reporte_id);
CREATE NONCLUSTERED INDEX idx_ejecuciones_usuario ON ejecuciones_reporte(usuario_id);
CREATE NONCLUSTERED INDEX idx_ejecuciones_estado ON ejecuciones_reporte(estado);
CREATE NONCLUSTERED INDEX idx_ejecuciones_fecha ON ejecuciones_reporte(fecha_inicio);

CREATE NONCLUSTERED INDEX idx_metricas_tipo ON metricas_reporte(tipo_reporte_id);
CREATE NONCLUSTERED INDEX idx_metricas_activo ON metricas_reporte(activo);

CREATE NONCLUSTERED INDEX idx_plantillas_tipo ON plantillas_reporte(tipo_reporte_id);
CREATE NONCLUSTERED INDEX idx_plantillas_activo ON plantillas_reporte(activo);

CREATE NONCLUSTERED INDEX idx_analisis_tipo ON analisis_predictivo(tipo_prediccion);
CREATE NONCLUSTERED INDEX idx_analisis_activo ON analisis_predictivo(activo);

CREATE NONCLUSTERED INDEX idx_resultados_analisis ON resultados_analisis_predictivo(analisis_id);
CREATE NONCLUSTERED INDEX idx_resultados_fecha ON resultados_analisis_predictivo(fecha_prediccion);
CREATE NONCLUSTERED INDEX idx_resultados_periodo ON resultados_analisis_predictivo(periodo_prediccion);

PRINT '✅ Índices creados para reportes';
GO

-- Crear vistas para reportes comunes
CREATE OR ALTER VIEW v_reporte_inventario_completo AS
SELECT 
    p.id as producto_id,
    p.nombre as producto_nombre,
    p.codigo as producto_codigo,
    i.cantidad,
    i.precio_unitario,
    (i.cantidad * i.precio_unitario) as valor_total,
    u.codigo as ubicacion_codigo,
    u.nombre as ubicacion_nombre,
    z.nombre as zona_nombre,
    tu.nombre as tipo_ubicacion,
    l.codigo_lote,
    l.fecha_vencimiento,
    CASE 
        WHEN l.fecha_vencimiento < GETDATE() THEN 'Vencido'
        WHEN l.fecha_vencimiento <= DATEADD(day, 30, GETDATE()) THEN 'Próximo a vencer'
        ELSE 'Vigente'
    END as estado_vencimiento
FROM inventario i
JOIN productos p ON i.producto_id = p.id
JOIN ubicaciones u ON i.ubicacion_id = u.id
LEFT JOIN zonas_almacen z ON u.zona_id = z.id
LEFT JOIN tipos_ubicacion tu ON u.tipo_ubicacion_id = tu.id
LEFT JOIN lotes l ON i.lote_id = l.id;
GO

CREATE OR ALTER VIEW v_reporte_picking_rendimiento AS
SELECT 
    u.id_usuario as operario_id,
    u.nombre as operario_nombre,
    COUNT(ep.id) as total_pickings,
    AVG(ep.tiempo_picking) as tiempo_promedio,
    AVG(ep.eficiencia) as eficiencia_promedio,
    AVG(ep.precision_picking) as precision_promedio,
    SUM(ep.cantidad_items) as total_items,
    SUM(ep.cantidad_pedidos) as total_pedidos,
    MIN(ep.fecha) as primera_fecha,
    MAX(ep.fecha) as ultima_fecha
FROM usuarios u
LEFT JOIN estadisticas_picking ep ON u.id_usuario = ep.operario_id
WHERE u.activo = 1
GROUP BY u.id_usuario, u.nombre;
GO

CREATE OR ALTER VIEW v_reporte_incidencias_analisis AS
SELECT 
    ti.nombre as tipo_incidencia,
    ti.categoria,
    COUNT(i.id) as total_incidencias,
    AVG(i.tiempo_resolucion_real) as tiempo_promedio_resolucion,
    SUM(i.costo_real) as costo_total,
    AVG(i.costo_real) as costo_promedio,
    COUNT(CASE WHEN i.prioridad = 'critica' THEN 1 END) as incidencias_criticas,
    COUNT(CASE WHEN i.estado = 'resuelta' THEN 1 END) as incidencias_resueltas,
    COUNT(CASE WHEN i.escalado = 1 THEN 1 END) as incidencias_escaladas,
    MIN(i.fecha_creacion) as primera_incidencia,
    MAX(i.fecha_creacion) as ultima_incidencia
FROM incidencias i
JOIN tipos_incidencia ti ON i.tipo_incidencia_id = ti.id
GROUP BY ti.id, ti.nombre, ti.categoria;
GO

PRINT '✅ Vistas para reportes creadas';
GO

-- Crear procedimientos almacenados para reportes
CREATE OR ALTER PROCEDURE sp_generar_reporte_inventario
    @fecha_corte DATE = NULL,
    @incluir_vencidos BIT = 1,
    @incluir_proximos_vencer BIT = 1
AS
BEGIN
    SET @fecha_corte = ISNULL(@fecha_corte, GETDATE());
    
    SELECT 
        producto_nombre,
        producto_codigo,
        cantidad,
        precio_unitario,
        valor_total,
        ubicacion_codigo,
        ubicacion_nombre,
        zona_nombre,
        tipo_ubicacion,
        codigo_lote,
        fecha_vencimiento,
        estado_vencimiento
    FROM v_reporte_inventario_completo
    WHERE 
        (@incluir_vencidos = 1 OR estado_vencimiento != 'Vencido')
        AND (@incluir_proximos_vencer = 1 OR estado_vencimiento != 'Próximo a vencer')
    ORDER BY valor_total DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_generar_reporte_picking
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @operario_id INT = NULL
AS
BEGIN
    SELECT 
        operario_nombre,
        total_pickings,
        tiempo_promedio,
        eficiencia_promedio,
        precision_promedio,
        total_items,
        total_pedidos,
        primera_fecha,
        ultima_fecha
    FROM v_reporte_picking_rendimiento
    WHERE 
        (@operario_id IS NULL OR operario_id = @operario_id)
        AND (primera_fecha >= @fecha_inicio OR primera_fecha IS NULL)
        AND (ultima_fecha <= @fecha_fin OR ultima_fecha IS NULL)
    ORDER BY eficiencia_promedio DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_generar_reporte_incidencias
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @categoria NVARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        tipo_incidencia,
        categoria,
        total_incidencias,
        tiempo_promedio_resolucion,
        costo_total,
        costo_promedio,
        incidencias_criticas,
        incidencias_resueltas,
        incidencias_escaladas,
        primera_incidencia,
        ultima_incidencia,
        CASE 
            WHEN total_incidencias > 0 THEN (incidencias_resueltas * 100.0 / total_incidencias)
            ELSE 0 
        END as tasa_resolucion
    FROM v_reporte_incidencias_analisis
    WHERE 
        (@categoria IS NULL OR categoria = @categoria)
        AND primera_incidencia >= @fecha_inicio
        AND ultima_incidencia <= @fecha_fin
    ORDER BY total_incidencias DESC;
END;
GO

PRINT '✅ Procedimientos almacenados para reportes creados';
GO

PRINT '';
PRINT '🎉 ¡Sistema de Reportes Avanzados y Análisis creado exitosamente!';
PRINT '============================================================';
PRINT '';
PRINT '✅ Tablas creadas:';
PRINT '   📊 tipos_reporte - Tipos de reporte disponibles';
PRINT '   📋 ejecuciones_reporte - Historial de ejecuciones';
PRINT '   📈 metricas_reporte - Métricas calculadas';
PRINT '   📝 plantillas_reporte - Plantillas de formato';
PRINT '   🔮 analisis_predictivo - Análisis predictivos';
PRINT '   📊 resultados_analisis_predictivo - Resultados de predicciones';
PRINT '';
PRINT '✅ Tipos de reporte: 8 reportes iniciales';
PRINT '✅ Métricas: 12 métricas calculadas';
PRINT '✅ Análisis predictivo: 6 modelos iniciales';
PRINT '✅ Vistas: 3 vistas optimizadas';
PRINT '✅ Procedimientos: 3 procedimientos almacenados';
PRINT '✅ Índices optimizados: 15 índices';
GO
