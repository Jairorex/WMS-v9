<?php

/**
 * Script para probar la conexión a la base de datos
 * Ejecutar: php test_db_connection.php
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Config;

echo "🔍 Probando conexión a la base de datos...\n\n";

// Obtener configuración
$connection = env('DB_CONNECTION', 'sqlsrv');
$host = env('DB_HOST', 'localhost');
$port = env('DB_PORT', '1433');
$database = env('DB_DATABASE', 'wms');
$username = env('DB_USERNAME', '');
$password = env('DB_PASSWORD', '');

echo "📋 Configuración:\n";
echo "   Connection: {$connection}\n";
echo "   Host: {$host}\n";
echo "   Port: {$port}\n";
echo "   Database: {$database}\n";
echo "   Username: {$username}\n";
echo "   Password: " . (empty($password) ? '(vacío)' : '***' . substr($password, -3)) . "\n\n";

try {
    echo "🔌 Intentando conectar...\n";
    
    // Intentar conexión
    $pdo = DB::connection($connection)->getPdo();
    
    echo "✅ Conexión exitosa!\n\n";
    
    // Obtener información de la conexión
    echo "📊 Información de la conexión:\n";
    try {
        echo "   Driver: " . $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) . "\n";
    } catch (\Exception $e) {
        echo "   Driver: No disponible\n";
    }
    
    try {
        $serverVersion = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);
        echo "   Server Version: " . (is_string($serverVersion) ? $serverVersion : 'No disponible') . "\n";
    } catch (\Exception $e) {
        echo "   Server Version: No disponible\n";
    }
    
    try {
        $clientVersion = $pdo->getAttribute(PDO::ATTR_CLIENT_VERSION);
        if (is_array($clientVersion)) {
            echo "   Client Version: " . implode(', ', $clientVersion) . "\n";
        } else {
            echo "   Client Version: " . ($clientVersion ?? 'No disponible') . "\n";
        }
    } catch (\Exception $e) {
        echo "   Client Version: No disponible\n";
    }
    
    echo "\n";
    
    // Probar una consulta simple
    echo "🔍 Probando consulta simple...\n";
    try {
        $result = DB::select("SELECT @@VERSION AS version, DB_NAME() AS database_name, SYSTEM_USER AS [current_user]");
        
        if (!empty($result) && is_array($result)) {
            $row = $result[0];
            echo "✅ Consulta exitosa!\n";
            echo "   Database: " . ($row->database_name ?? 'N/A') . "\n";
            echo "   User: " . ($row->current_user ?? 'N/A') . "\n";
            $version = is_string($row->version) ? $row->version : (is_object($row->version) ? (string)$row->version : 'N/A');
            echo "   SQL Server Version: " . substr($version, 0, 80) . "...\n\n";
        } else {
            echo "⚠️ Consulta ejecutada pero sin resultados\n\n";
        }
    } catch (\Exception $e) {
        echo "❌ Error en consulta: " . $e->getMessage() . "\n\n";
    }
    
    // Verificar tablas importantes
    echo "📋 Verificando tablas importantes...\n";
    
    $tables = [
        'usuarios',
        'personal_access_tokens',
        'sessions',
        'productos',
        'inventario',
        'tareas',
    ];
    
    foreach ($tables as $table) {
        try {
            $exists = DB::select("SELECT COUNT(*) as count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?", [$table]);
            if (!empty($exists) && $exists[0]->count > 0) {
                echo "   ✅ {$table} - Existe\n";
            } else {
                echo "   ❌ {$table} - NO existe\n";
            }
        } catch (\Exception $e) {
            echo "   ⚠️ {$table} - Error al verificar: " . $e->getMessage() . "\n";
        }
    }
    
    echo "\n✅ Todas las pruebas completadas exitosamente!\n";
    
} catch (\PDOException $e) {
    echo "❌ Error de conexión PDO:\n";
    echo "   Código: " . $e->getCode() . "\n";
    echo "   Mensaje: " . $e->getMessage() . "\n";
    echo "\n💡 Posibles soluciones:\n";
    echo "   1. Verifica que las credenciales sean correctas\n";
    echo "   2. Verifica que el servidor de Azure SQL esté accesible\n";
    echo "   3. Verifica que el firewall de Azure permita conexiones desde Railway\n";
    echo "   4. Verifica que las extensiones PHP sqlsrv estén instaladas\n";
    exit(1);
    
} catch (\Exception $e) {
    echo "❌ Error general:\n";
    echo "   Mensaje: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . "\n";
    echo "   Línea: " . $e->getLine() . "\n";
    exit(1);
}

