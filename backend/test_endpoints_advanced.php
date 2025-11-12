<?php

/**
 * Script de pruebas avanzadas para endpoints de la API
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
    echo "\n" . str_repeat("=", 70) . "\n";
    echo "🧪 TEST: {$name}\n";
    echo str_repeat("=", 70) . "\n";
    
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
                } elseif (isset($result['body']['total'])) {
                    echo "   Total: {$result['body']['total']}, Current page: {$result['body']['current_page']}\n";
                }
            }
            // Mostrar algunos datos si existen
            if (isset($result['body']['data'][0])) {
                $first = $result['body']['data'][0];
                if (isset($first['id_tarea'])) {
                    echo "   Primer ID: {$first['id_tarea']}\n";
                }
            }
        } else {
            echo "❌ FAILED (HTTP {$result['code']})\n";
            echo "   Response: " . substr($result['raw'], 0, 300) . "\n";
        }
        
        return $result;
    } catch (Exception $e) {
        echo "❌ ERROR: {$e->getMessage()}\n";
        return null;
    }
}

echo "\n🚀 PRUEBAS AVANZADAS DE ENDPOINTS\n";
echo "Base URL: {$baseUrl}\n";

// Login
$loginResult = makeRequest('POST', "{$baseUrl}/auth/login", [
    'usuario' => 'admin',
    'password' => 'admin123'
]);

if ($loginResult && isset($loginResult['body']['token'])) {
    $token = $loginResult['body']['token'];
    echo "\n✅ Token obtenido\n";
} else {
    echo "\n❌ No se pudo obtener token.\n";
    exit(1);
}

// 1. Paginación
test('Paginación: GET /api/tareas?per_page=2&page=1', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?per_page=2&page=1", null, $token);
});

test('Paginación: GET /api/tareas?per_page=2&page=2', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?per_page=2&page=2", null, $token);
});

// 2. Filtros por estado (código string)
test('Filtro por estado (código): GET /api/tareas?estado=COMPLETADA', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?estado=COMPLETADA", null, $token);
});

// 3. Filtros combinados
test('Filtros combinados: GET /api/tareas?prioridad=Alta&per_page=5', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?prioridad=Alta&per_page=5", null, $token);
});

// 4. Búsqueda general
test('Búsqueda general: GET /api/tareas?q=prueba', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?q=prueba", null, $token);
});

// 5. Ordenamiento
test('Ordenamiento: GET /api/tareas?order_by=id_tarea&order_dir=asc&per_page=3', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?order_by=id_tarea&order_dir=asc&per_page=3", null, $token);
});

// 6. Sin paginación
test('Sin paginación: GET /api/tareas?paginate=false', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?paginate=false", null, $token);
});

// 7. Filtros de fecha (si hay datos)
test('Filtro fecha inicio: GET /api/tareas?fecha_inicio=2024-01-01', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas?fecha_inicio=2024-01-01", null, $token);
});

// 8. Verificar formato de respuesta paginada
test('Formato respuesta paginada', function() use ($baseUrl, $token) {
    $result = makeRequest('GET', "{$baseUrl}/tareas?per_page=2", null, $token);
    
    $requiredFields = ['success', 'message', 'data', 'current_page', 'per_page', 'total', 'last_page'];
    foreach ($requiredFields as $field) {
        if (isset($result['body'][$field])) {
            echo "   ✅ Campo '{$field}' presente: " . (is_array($result['body'][$field]) ? 'array' : $result['body'][$field]) . "\n";
        } else {
            echo "   ❌ Campo '{$field}' NO presente\n";
        }
    }
    
    return $result;
});

// 9. Probar errores esperados
test('Error 404: GET /api/tareas/99999', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/tareas/99999", null, $token);
});

test('Error validación: POST /api/tareas sin datos', function() use ($baseUrl, $token) {
    return makeRequest('POST', "{$baseUrl}/tareas", [], $token);
});

// 10. Verificar que /api/picking redirige correctamente
test('GET /api/picking?estado=EN_PROCESO (deprecado con query params)', function() use ($baseUrl, $token) {
    return makeRequest('GET', "{$baseUrl}/picking?estado=EN_PROCESO", null, $token);
});

echo "\n" . str_repeat("=", 70) . "\n";
echo "✅ PRUEBAS AVANZADAS COMPLETADAS\n";
echo str_repeat("=", 70) . "\n\n";


