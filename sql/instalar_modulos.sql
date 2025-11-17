-- ========================================
-- INSTALACIÓN COMPLETA DE MÓDULOS WMS
-- ========================================

USE [wms_escasan];
GO

PRINT '🚀 Instalando módulos completos del sistema WMS...';
PRINT '===============================================';
GO

-- Ejecutar script de módulos (que incluye lotes y notificaciones)
PRINT '';
PRINT '📦 Ejecutando script de módulos...';
:r instalar_modulos_completos.sql

-- Verificar instalación
PRINT '';
PRINT '🔍 Verificando instalación...';
:r verificar_instalacion.sql

PRINT '';
PRINT '🎉 Instalación de módulos completada!';
PRINT '====================================';
PRINT '';
PRINT '📋 Módulos instalados:';
PRINT '   ✅ Módulo de Lotes y Trazabilidad';
PRINT '   ✅ Módulo de Notificaciones';
PRINT '   ✅ Sistema completo de WMS';
PRINT '';
PRINT '🚀 El sistema está listo para usar en producción!';
GO

