<?php

/**
 * Script para comparar la estructura de la base de datos local con Azure
 * 
 * Este script compara:
 * - Tablas existentes
 * - Columnas de cada tabla
 * - Tipos de datos
 * - Índices
 * - Constraints
 */

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// Cargar configuración de Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "🔍 COMPARACIÓN DE BASES DE DATOS\n";
echo "================================\n\n";

// Configuración de conexiones
$localConfig = [
    'host' => env('DB_HOST', 'localhost'),
    'database' => env('DB_DATABASE', 'wms_escasan'),
    'username' => env('DB_USERNAME', ''),
    'password' => env('DB_PASSWORD', ''),
];

// Configuración de Azure (debes configurar estas variables en .env)
$azureConfig = [
    'host' => env('AZURE_DB_HOST', ''),
    'database' => env('AZURE_DB_DATABASE', 'wms_escasan'),
    'username' => env('AZURE_DB_USERNAME', ''),
    'password' => env('AZURE_DB_PASSWORD', ''),
];

// Función para obtener tablas de una base de datos
function getTables($connection, $schema = 'wms') {
    $tables = [];
    
    $query = "
        SELECT 
            TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = ?
        ORDER BY TABLE_NAME
    ";
    
    try {
        $results = $connection->select($query, [$schema]);
        foreach ($results as $row) {
            $tables[] = $row->TABLE_NAME;
        }
    } catch (\Exception $e) {
        echo "❌ Error obteniendo tablas: " . $e->getMessage() . "\n";
    }
    
    return $tables;
}

// Función para obtener columnas de una tabla
function getColumns($connection, $schema, $table) {
    $columns = [];
    
    $query = "
        SELECT 
            COLUMN_NAME,
            DATA_TYPE,
            CHARACTER_MAXIMUM_LENGTH,
            IS_NULLABLE,
            COLUMN_DEFAULT,
            ORDINAL_POSITION
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION
    ";
    
    try {
        $results = $connection->select($query, [$schema, $table]);
        foreach ($results as $row) {
            $columns[$row->COLUMN_NAME] = [
                'type' => $row->DATA_TYPE,
                'length' => $row->CHARACTER_MAXIMUM_LENGTH,
                'nullable' => $row->IS_NULLABLE === 'YES',
                'default' => $row->COLUMN_DEFAULT,
                'position' => $row->ORDINAL_POSITION,
            ];
        }
    } catch (\Exception $e) {
        echo "❌ Error obteniendo columnas de {$table}: " . $e->getMessage() . "\n";
    }
    
    return $columns;
}

// Función para obtener índices de una tabla
function getIndexes($connection, $schema, $table) {
    $indexes = [];
    
    $query = "
        SELECT 
            i.name AS index_name,
            i.is_unique,
            i.is_primary_key,
            STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS columns
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        INNER JOIN sys.tables t ON i.object_id = t.object_id
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = ? AND t.name = ?
        GROUP BY i.name, i.is_unique, i.is_primary_key
        ORDER BY i.name
    ";
    
    try {
        $results = $connection->select($query, [$schema, $table]);
        foreach ($results as $row) {
            $indexes[] = [
                'name' => $row->index_name,
                'unique' => $row->is_unique,
                'primary' => $row->is_primary_key,
                'columns' => $row->columns,
            ];
        }
    } catch (\Exception $e) {
        // Intentar con versión alternativa para SQL Server más antiguo
        $query = "
            SELECT 
                i.name AS index_name,
                i.is_unique,
                i.is_primary_key,
                (
                    SELECT STRING_AGG(c.name, ', ')
                    FROM sys.index_columns ic2
                    INNER JOIN sys.columns c ON ic2.object_id = c.object_id AND ic2.column_id = c.column_id
                    WHERE ic2.object_id = i.object_id AND ic2.index_id = i.index_id
                ) AS columns
            FROM sys.indexes i
            INNER JOIN sys.tables t ON i.object_id = t.object_id
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ? AND t.name = ?
            ORDER BY i.name
        ";
        
        try {
            $results = $connection->select($query, [$schema, $table]);
            foreach ($results as $row) {
                $indexes[] = [
                    'name' => $row->index_name,
                    'unique' => $row->is_unique,
                    'primary' => $row->is_primary_key,
                    'columns' => $row->columns ?? '',
                ];
            }
        } catch (\Exception $e2) {
            echo "⚠️ No se pudieron obtener índices de {$table}\n";
        }
    }
    
    return $indexes;
}

// Conectar a base local
echo "📡 Conectando a base de datos LOCAL...\n";
try {
    $localConnection = DB::connection('wms');
    $localConnection->getPdo();
    echo "✅ Conexión local establecida\n\n";
} catch (\Exception $e) {
    echo "❌ Error conectando a base local: " . $e->getMessage() . "\n";
    exit(1);
}

// Conectar a base Azure
echo "📡 Conectando a base de datos AZURE...\n";
if (empty($azureConfig['host'])) {
    echo "⚠️ Configuración de Azure no encontrada. Usando variables de entorno:\n";
    echo "   AZURE_DB_HOST, AZURE_DB_DATABASE, AZURE_DB_USERNAME, AZURE_DB_PASSWORD\n\n";
    echo "💡 Para comparar con Azure, configura estas variables en tu .env\n";
    echo "   O pasa los parámetros directamente en el código.\n\n";
    
    // Intentar usar la misma conexión si no hay configuración de Azure
    echo "📊 Analizando solo la base de datos LOCAL...\n\n";
    $azureConnection = null;
} else {
    try {
        $azureConnection = new \PDO(
            "sqlsrv:Server={$azureConfig['host']};Database={$azureConfig['database']}",
            $azureConfig['username'],
            $azureConfig['password'],
            [
                \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
                \PDO::SQLSRV_ATTR_ENCODING => \PDO::SQLSRV_ENCODING_UTF8,
            ]
        );
        echo "✅ Conexión Azure establecida\n\n";
    } catch (\Exception $e) {
        echo "❌ Error conectando a Azure: " . $e->getMessage() . "\n";
        echo "📊 Continuando solo con análisis local...\n\n";
        $azureConnection = null;
    }
}

// Obtener tablas de local
echo "📋 Obteniendo tablas de LOCAL...\n";
$localTables = getTables($localConnection, 'wms');
echo "✅ Encontradas " . count($localTables) . " tablas en LOCAL\n\n";

// Obtener tablas de Azure si está disponible
$azureTables = [];
if ($azureConnection) {
    echo "📋 Obteniendo tablas de AZURE...\n";
    // Crear conexión Laravel para Azure
    config(['database.connections.azure' => [
        'driver' => 'sqlsrv',
        'host' => $azureConfig['host'],
        'database' => $azureConfig['database'],
        'username' => $azureConfig['username'],
        'password' => $azureConfig['password'],
        'options' => [
            'TrustServerCertificate' => true,
            'DefaultSchema' => 'wms',
        ],
    ]]);
    
    $azureLaravelConnection = DB::connection('azure');
    $azureTables = getTables($azureLaravelConnection, 'wms');
    echo "✅ Encontradas " . count($azureTables) . " tablas en AZURE\n\n";
}

// Comparar tablas
echo "═══════════════════════════════════════════════════════════════\n";
echo "📊 COMPARACIÓN DE TABLAS\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$allTables = array_unique(array_merge($localTables, $azureTables));
sort($allTables);

$differences = [
    'missing_in_azure' => [],
    'missing_in_local' => [],
    'column_differences' => [],
    'index_differences' => [],
];

foreach ($allTables as $table) {
    $inLocal = in_array($table, $localTables);
    $inAzure = in_array($table, $azureTables);
    
    if ($inLocal && !$inAzure) {
        echo "❌ Tabla '{$table}' existe en LOCAL pero NO en AZURE\n";
        $differences['missing_in_azure'][] = $table;
    } elseif (!$inLocal && $inAzure) {
        echo "❌ Tabla '{$table}' existe en AZURE pero NO en LOCAL\n";
        $differences['missing_in_local'][] = $table;
    } elseif ($inLocal && $inAzure) {
        echo "✅ Tabla '{$table}' existe en ambas\n";
        
        // Comparar columnas
        $localColumns = getColumns($localConnection, 'wms', $table);
        $azureColumns = $azureConnection ? getColumns($azureLaravelConnection, 'wms', $table) : [];
        
        if ($azureConnection) {
            $allColumns = array_unique(array_merge(array_keys($localColumns), array_keys($azureColumns)));
            
            foreach ($allColumns as $column) {
                $localCol = $localColumns[$column] ?? null;
                $azureCol = $azureColumns[$column] ?? null;
                
                if (!$localCol && $azureCol) {
                    echo "   ⚠️ Columna '{$column}' existe en AZURE pero NO en LOCAL\n";
                    $differences['column_differences'][] = [
                        'table' => $table,
                        'column' => $column,
                        'issue' => 'missing_in_local',
                    ];
                } elseif ($localCol && !$azureCol) {
                    echo "   ⚠️ Columna '{$column}' existe en LOCAL pero NO en AZURE\n";
                    $differences['column_differences'][] = [
                        'table' => $table,
                        'column' => $column,
                        'issue' => 'missing_in_azure',
                    ];
                } elseif ($localCol && $azureCol) {
                    // Comparar tipos
                    if ($localCol['type'] !== $azureCol['type']) {
                        echo "   ⚠️ Columna '{$column}': tipo diferente (LOCAL: {$localCol['type']}, AZURE: {$azureCol['type']})\n";
                        $differences['column_differences'][] = [
                            'table' => $table,
                            'column' => $column,
                            'issue' => 'type_difference',
                            'local' => $localCol['type'],
                            'azure' => $azureCol['type'],
                        ];
                    }
                }
            }
        }
    }
}

echo "\n";

// Resumen
echo "═══════════════════════════════════════════════════════════════\n";
echo "📊 RESUMEN DE DIFERENCIAS\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

echo "📋 Tablas faltantes en AZURE: " . count($differences['missing_in_azure']) . "\n";
if (!empty($differences['missing_in_azure'])) {
    foreach ($differences['missing_in_azure'] as $table) {
        echo "   - {$table}\n";
    }
}

echo "\n📋 Tablas faltantes en LOCAL: " . count($differences['missing_in_local']) . "\n";
if (!empty($differences['missing_in_local'])) {
    foreach ($differences['missing_in_local'] as $table) {
        echo "   - {$table}\n";
    }
}

echo "\n📋 Diferencias en columnas: " . count($differences['column_differences']) . "\n";
if (!empty($differences['column_differences'])) {
    foreach ($differences['column_differences'] as $diff) {
        echo "   - {$diff['table']}.{$diff['column']}: {$diff['issue']}\n";
    }
}

echo "\n";

// Listar todas las tablas de local con detalles
echo "═══════════════════════════════════════════════════════════════\n";
echo "📋 TABLAS EN BASE LOCAL (wms schema)\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

foreach ($localTables as $table) {
    $columns = getColumns($localConnection, 'wms', $table);
    $indexes = getIndexes($localConnection, 'wms', $table);
    
    echo "📦 {$table}\n";
    echo "   Columnas: " . count($columns) . "\n";
    echo "   Índices: " . count($indexes) . "\n";
    
    if (!empty($indexes)) {
        foreach ($indexes as $idx) {
            $type = $idx['primary'] ? 'PRIMARY KEY' : ($idx['unique'] ? 'UNIQUE' : 'INDEX');
            echo "      - {$idx['name']} ({$type}): {$idx['columns']}\n";
        }
    }
    echo "\n";
}

// Generar script SQL para sincronizar
if (!empty($differences['missing_in_azure'])) {
    echo "═══════════════════════════════════════════════════════════════\n";
    echo "💡 RECOMENDACIÓN\n";
    echo "═══════════════════════════════════════════════════════════════\n\n";
    echo "Las siguientes tablas faltan en Azure:\n";
    foreach ($differences['missing_in_azure'] as $table) {
        echo "   - {$table}\n";
    }
    echo "\n💡 Ejecuta el script 'sql/crear_tablas_lotes_movimientos_historial.sql' en Azure\n";
    echo "   o revisa otros scripts SQL en la carpeta sql/ para sincronizar.\n\n";
}

echo "✅ Comparación completada\n";

