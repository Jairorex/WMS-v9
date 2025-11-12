# Script de Verificación de Dependencias - WMS v9
# Windows PowerShell

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN DE DEPENDENCIAS WMS v9" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$errores = @()
$advertencias = @()

# 1. Verificar PHP
Write-Host "1. PHP:" -ForegroundColor Yellow
try {
    $phpVersion = php -v 2>&1 | Select-String -Pattern "PHP (\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
    if ($phpVersion) {
        $versionNum = [double]$phpVersion
        if ($versionNum -ge 8.2) {
            Write-Host "   ✅ PHP $phpVersion instalado" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  PHP $phpVersion instalado (requiere 8.2+)" -ForegroundColor Yellow
            $advertencias += "PHP versión $phpVersion es menor a la requerida (8.2+)"
        }
    } else {
        Write-Host "   ❌ PHP no encontrado" -ForegroundColor Red
        $errores += "PHP no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "   ❌ Error al verificar PHP" -ForegroundColor Red
    $errores += "No se pudo verificar PHP"
}

# 2. Verificar Extensiones PHP
Write-Host "`n2. Extensiones PHP:" -ForegroundColor Yellow
$requiredExtensions = @("pdo", "pdo_sqlsrv", "sqlsrv", "curl", "mbstring", "openssl", "xml", "bcmath", "fileinfo")
$installedExtensions = php -m 2>&1

foreach ($ext in $requiredExtensions) {
    if ($installedExtensions -match $ext) {
        Write-Host "   ✅ $ext" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $ext (NO INSTALADO)" -ForegroundColor Red
        $errores += "Extensión PHP '$ext' no está instalada"
    }
}

# 3. Verificar Composer
Write-Host "`n3. Composer:" -ForegroundColor Yellow
try {
    $composerVersion = composer --version 2>&1 | Select-String -Pattern "Composer version (\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
    if ($composerVersion) {
        Write-Host "   ✅ Composer $composerVersion instalado" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Composer no encontrado" -ForegroundColor Red
        $errores += "Composer no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "   ❌ Composer no encontrado" -ForegroundColor Red
    $errores += "Composer no está instalado"
}

# 4. Verificar Node.js
Write-Host "`n4. Node.js:" -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    if ($nodeVersion) {
        $nodeVersionNum = [double]($nodeVersion -replace 'v', '' -split '\.')[0]
        if ($nodeVersionNum -ge 18) {
            Write-Host "   ✅ Node.js $nodeVersion instalado" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Node.js $nodeVersion instalado (requiere 18+)" -ForegroundColor Yellow
            $advertencias += "Node.js versión $nodeVersion es menor a la requerida (18+)"
        }
    } else {
        Write-Host "   ❌ Node.js no encontrado" -ForegroundColor Red
        $errores += "Node.js no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "   ❌ Node.js no encontrado" -ForegroundColor Red
    $errores += "Node.js no está instalado"
}

# 5. Verificar npm
Write-Host "`n5. npm:" -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>&1
    if ($npmVersion) {
        Write-Host "   ✅ npm $npmVersion instalado" -ForegroundColor Green
    } else {
        Write-Host "   ❌ npm no encontrado" -ForegroundColor Red
        $errores += "npm no está instalado"
    }
} catch {
    Write-Host "   ❌ npm no encontrado" -ForegroundColor Red
    $errores += "npm no está instalado"
}

# 6. Verificar ODBC Driver
Write-Host "`n6. ODBC Driver 17 for SQL Server:" -ForegroundColor Yellow
try {
    $odbcDrivers = odbcinst -q -d 2>&1
    if ($odbcDrivers -match "ODBC Driver 17 for SQL Server") {
        Write-Host "   ✅ ODBC Driver 17 for SQL Server instalado" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ODBC Driver 17 for SQL Server no encontrado" -ForegroundColor Red
        $errores += "ODBC Driver 17 for SQL Server no está instalado"
        Write-Host "      Descargar desde: https://aka.ms/downloadmsodbcsql" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  No se pudo verificar ODBC Driver" -ForegroundColor Yellow
    $advertencias += "No se pudo verificar ODBC Driver (puede estar instalado)"
}

# 7. Verificar SQL Server (conexión)
Write-Host "`n7. SQL Server:" -ForegroundColor Yellow
$sqlServerRunning = $false
try {
    $service = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Write-Host "   ✅ Servicio SQL Server está corriendo" -ForegroundColor Green
        $sqlServerRunning = $true
    } else {
        Write-Host "   ⚠️  Servicio SQL Server no está corriendo o no está instalado" -ForegroundColor Yellow
        $advertencias += "SQL Server puede no estar corriendo"
    }
} catch {
    Write-Host "   ⚠️  No se pudo verificar servicio SQL Server" -ForegroundColor Yellow
    $advertencias += "No se pudo verificar SQL Server"
}

# 8. Verificar estructura del proyecto
Write-Host "`n8. Estructura del Proyecto:" -ForegroundColor Yellow
$projectFiles = @(
    "backend",
    "frontend",
    "backend\composer.json",
    "frontend\package.json"
)

foreach ($file in $projectFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file (NO ENCONTRADO)" -ForegroundColor Red
        $errores += "Archivo/Carpeta '$file' no encontrado"
    }
}

# Resumen
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($errores.Count -eq 0 -and $advertencias.Count -eq 0) {
    Write-Host "✅ Todas las dependencias están instaladas correctamente!" -ForegroundColor Green
    exit 0
} else {
    if ($errores.Count -gt 0) {
        Write-Host "❌ ERRORES ENCONTRADOS ($($errores.Count)):" -ForegroundColor Red
        foreach ($error in $errores) {
            Write-Host "   - $error" -ForegroundColor Red
        }
    }
    
    if ($advertencias.Count -gt 0) {
        Write-Host "`n⚠️  ADVERTENCIAS ($($advertencias.Count)):" -ForegroundColor Yellow
        foreach ($warning in $advertencias) {
            Write-Host "   - $warning" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n📖 Consulta REQUISITOS_INSTALACION.md para más información" -ForegroundColor Cyan
    exit 1
}

