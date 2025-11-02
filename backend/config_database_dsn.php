<?php

// Configuración con DSN específico para esquema wms
// Archivo: config/database.php

return [
    'default' => env('DB_CONNECTION', 'sqlsrv'),
    
    'connections' => [
        'sqlsrv' => [
            'driver' => 'sqlsrv',
            'dsn' => 'sqlsrv:Server=' . env('DB_HOST', 'localhost') . ';Database=' . env('DB_DATABASE', 'wms_escasan') . ';',
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
                'CharacterSet' => 'UTF-8',
                'ReturnDatesAsStrings' => true,
            ],
        ],
    ],
];
