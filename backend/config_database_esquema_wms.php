<?php

// Configuración alternativa para usar esquema wms por defecto
// Archivo: config/database.php

return [
    'default' => env('DB_CONNECTION', 'sqlsrv'),
    
    'connections' => [
        'sqlsrv' => [
            'driver' => 'sqlsrv',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', 'localhost'),
            'port' => env('DB_PORT', '1433'),
            'database' => env('DB_DATABASE', 'wms_escasan'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8'),
            'prefix' => '',
            'prefix_indexes' => true,
            'options' => [
                'TrustServerCertificate' => true,
                'DefaultSchema' => 'wms', // Esquema por defecto
            ],
        ],
    ],
];
