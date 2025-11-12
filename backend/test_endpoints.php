<?php

/**
 * Script de pruebas para endpoints de la API
 * Ejecutar: php test_endpoints.php
 */

$baseUrl = 'http://127.0.0.1:8000/api';
$token = null;

function makeRequest($method, $url, $data = null, $token = null) {
    $ch = curl_init($url);
    
    $headers = [
        'Content-Type: application/json',
        'Accept: application/json',
    ];
    
    if ($token) {
        $headers[] = "Authorization: Bearer {$token}";
    }
    
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    
    if ($data && in_array($method, ['POST', 'PUT', 'PATCH'])) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'body' => json_decode($response, true),
        'raw' => $response
    ];
}

function test($name, $callback) {
    echo "\n" . str_repeat("=", 60) . "\n";
    echo "🧪 TEST: {$name}\n";
    echo str_repeat("=", 60) . "\n";
    
    try {
        $result = $callback();
        
        if ($result['code'] >= 200 && $result['code'] < 300) {
            echo "✅ PASSED (HTTP {$result['code']})\n";
            if (isset($result['body']['success'])) {
                echo "   Success: " . ($result['body']['success'] ? 'true' : 'false') . "\n";
            }
            if (isset($result['body']['message'])) {
                echo "   Message: {$result['body']['message']}\n";
            }
            if (isset($result['body']['data'])) {
                if (is_array($result['body']['data'])) {
                    echo "   Data count: " . count($result['body']['data']) . "\n";
                }
            }
        } else {
            echo "❌ FAILED (HTTP {$result['code']})\n";
            echo "   Response: " . substr($result['raw'], 0, 200) . "\n";
        }
        
        return $result;
    } catch (Exception $e) {
        echo "❌ ERROR: {$e->getMessage()}\n";
        return null;
    }
}

echo "\n🚀 INICIANDO PRUEBAS DE ENDPOINTS DE LA API\n";
echo "Base URL: {$baseUrl}\n";

// 1. Login
$loginResult = test('Login', function() use ($baseUrl) {
    return makeRequest('POST', "{$baseUrl}/auth/login", [
        'usuario' => 'admin',
        'password' => 'admin123'
    ]);
});

if ($loginResult && isset($loginResult['body']['token'])) {
    $token = $loginResult['body']['token'];
    echo "\n✅ Token obtenido: " . substr($token, 0, 20) . "...\n";
} else {
    echo "\n❌ No se pudo obtener token. Abortando pruebas.\n";
    exit(1);
}

// 2. GET /api/tareas (sin filtros)
test('GET /api/tareas (sin filtros)', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas", null, $token);
});

// 3. GET /api/tareas?tipo=picking
test('GET /api/tareas?tipo=picking', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?tipo=picking", null, $token);
});

// 4. GET /api/tareas?tipo=packing
test('GET /api/tareas?tipo=packing', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?tipo=packing", null, $token);
});

// 5. GET /api/tareas con múltiples filtros
test('GET /api/tareas?tipo=picking&per_page=5', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?tipo=picking&per_page=5", null, $token);
});

// 6. GET /api/tareas-catalogos
test('GET /api/tareas-catalogos', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas-catalogos", null, $token);
});

// 7. GET /api/picking (deprecado pero debería funcionar)
test('GET /api/picking (deprecado)', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/picking", null, $token);
});

// 8. GET /api/packing (deprecado pero debería funcionar)
test('GET /api/packing (deprecado)', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/packing", null, $token);
});

// 9. Crear una tarea de prueba
$tareaId = null;
$createResult = test('POST /api/tareas (crear)', function() use ($baseUrl, $token) {
    return makeRequest('POST', "{$baseUrl}/tareas", [
        'tipo_tarea_id' => 1, // Ajustar según tus datos
        'prioridad' => 'Media',
        'descripcion' => 'Tarea de prueba creada desde test_endpoints.php',
        'fecha_vencimiento' => date('Y-m-d', strtotime('+7 days'))
    ], $token);
});

if ($createResult && isset($createResult['body']['data']['id_tarea'])) {
    $tareaId = $createResult['body']['data']['id_tarea'];
    echo "   Tarea ID creada: {$tareaId}\n";
    
    // 10. Obtener tarea específica
    test("GET /api/tareas/{$tareaId}", function() use ($baseUrl, $token, $tareaId) {
        return makeRequest('GET', "{$baseUrl}/tareas/{$tareaId}", null, $token);
    });
    
    // 11. Cambiar estado de la tarea
    test("PATCH /api/tareas/{$tareaId}/cambiar-estado", function() use ($baseUrl, $token, $tareaId) {
        return makeRequest('PATCH', "{$baseUrl}/tareas/{$tareaId}/cambiar-estado", [
            'estado' => 'EN_PROCESO',
            'comentarios' => 'Estado cambiado desde test'
        ], $token);
    });
    
    // 12. Completar tarea
    test("PATCH /api/tareas/{$tareaId}/completar", function() use ($baseUrl, $token, $tareaId) {
        return makeRequest('PATCH', "{$baseUrl}/tareas/{$tareaId}/completar", [
            'comentarios' => 'Tarea completada desde test'
        ], $token);
    });
}

// 13. Prueba con filtros avanzados
test('GET /api/tareas con filtros avanzados', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?per_page=10&order_by=fecha_creacion&order_dir=desc", null, $token);
});

// 14. Verificar formato de respuesta estandarizada
test('Verificar formato de respuesta estandarizada', function() use ($baseUrl, $token) {
    $result = makeRequest('GET', "{$baseUrl}/tareas?per_page=1", null, $token);
    
    if (isset($result['body']['success'])) {
        echo "   ✅ Respuesta tiene campo 'success'\n";
    } else {
        echo "   ❌ Respuesta NO tiene campo 'success'\n";
    }
    
    if (isset($result['body']['message'])) {
        echo "   ✅ Respuesta tiene campo 'message'\n";
    } else {
        echo "   ❌ Respuesta NO tiene campo 'message'\n";
    }
    
    if (isset($result['body']['data'])) {
        echo "   ✅ Respuesta tiene campo 'data'\n";
    } else {
        echo "   ❌ Respuesta NO tiene campo 'data'\n";
    }
    
    return $result;
});

echo "\n" . str_repeat("=", 60) . "\n";
echo "✅ PRUEBAS COMPLETADAS\n";
echo str_repeat("=", 60) . "\n\n";


