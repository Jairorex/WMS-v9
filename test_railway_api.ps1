# Script para probar la API de Railway

$apiUrl = "https://wms-v9-production.up.railway.app"

Write-Host "Probando endpoint de health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/up" -Method GET -UseBasicParsing
    Write-Host "✓ Health check: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Health check falló: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nProbando endpoint de login (POST)..." -ForegroundColor Yellow
try {
    $body = @{
        usuario = "admin"
        password = "password"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "$apiUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -UseBasicParsing `
        -ErrorAction Stop

    Write-Host "✓ Login endpoint responde: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Respuesta: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Login endpoint falló: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
        Write-Host "  Status Code: $statusCode" -ForegroundColor Red
    }
}

Write-Host "`nProbando endpoint de roles (GET)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/api/roles" -Method GET -UseBasicParsing
    Write-Host "✓ Roles endpoint responde: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Roles endpoint falló: $($_.Exception.Message)" -ForegroundColor Red
}

