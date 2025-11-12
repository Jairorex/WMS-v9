# Script para corregir drivers SQL Server en XAMPP
# Ejecutar como Administrador

Write-Host "🔧 Corrigiendo drivers SQL Server..." -ForegroundColor Cyan

$extDir = "C:\xampp\php\ext"

# Verificar que existe el directorio
if (-not (Test-Path $extDir)) {
    Write-Host "❌ Directorio de extensiones no encontrado: $extDir" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Directorio de extensiones: $extDir" -ForegroundColor Yellow

# Verificar versión de PHP
$phpVersion = php -v | Select-String "PHP (\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
$phpArch = php -i | Select-String "Architecture => (\w+)" | ForEach-Object { $_.Matches.Groups[1].Value }
$phpTS = php -i | Select-String "Thread Safety => (\w+)" | ForEach-Object { $_.Matches.Groups[1].Value }

Write-Host "🐘 PHP Version: $phpVersion" -ForegroundColor Yellow
Write-Host "🏗️  Arquitectura: $phpArch" -ForegroundColor Yellow
Write-Host "🔒 Thread Safety: $phpTS" -ForegroundColor Yellow

# Determinar drivers correctos
$version = $phpVersion -replace '\.', ''
$tsSuffix = if ($phpTS -eq "enabled") { "ts" } else { "nts" }
$archSuffix = if ($phpArch -eq "x64") { "x64" } else { "x86" }

$driverSource = "php_sqlsrv_${version}_${tsSuffix}_${archSuffix}.dll"
$pdoDriverSource = "php_pdo_sqlsrv_${version}_${tsSuffix}_${archSuffix}.dll"

$driverDest = "php_sqlsrv.dll"
$pdoDriverDest = "php_pdo_sqlsrv.dll"

Write-Host "`n📦 Drivers a usar:" -ForegroundColor Yellow
Write-Host "   Source: $driverSource" -ForegroundColor Cyan
Write-Host "   Source: $pdoDriverSource" -ForegroundColor Cyan

# Verificar que los drivers fuente existen
if (-not (Test-Path "$extDir\$driverSource")) {
    Write-Host "❌ Driver fuente no encontrado: $driverSource" -ForegroundColor Red
    Write-Host "   Descarga desde: https://github.com/Microsoft/msphpsql/releases" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "$extDir\$pdoDriverSource")) {
    Write-Host "❌ Driver PDO fuente no encontrado: $pdoDriverSource" -ForegroundColor Red
    Write-Host "   Descarga desde: https://github.com/Microsoft/msphpsql/releases" -ForegroundColor Yellow
    exit 1
}

# Hacer backup de drivers actuales
Write-Host "`n💾 Haciendo backup de drivers actuales..." -ForegroundColor Yellow
$backupDir = "$extDir\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

if (Test-Path "$extDir\$driverDest") {
    Copy-Item "$extDir\$driverDest" "$backupDir\$driverDest" -Force
    Write-Host "   ✅ Backup de $driverDest creado" -ForegroundColor Green
}

if (Test-Path "$extDir\$pdoDriverDest") {
    Copy-Item "$extDir\$pdoDriverDest" "$backupDir\$pdoDriverDest" -Force
    Write-Host "   ✅ Backup de $pdoDriverDest creado" -ForegroundColor Green
}

# Copiar drivers correctos
Write-Host "`n📋 Copiando drivers correctos..." -ForegroundColor Yellow
Copy-Item "$extDir\$driverSource" "$extDir\$driverDest" -Force
Copy-Item "$extDir\$pdoDriverSource" "$extDir\$pdoDriverDest" -Force

Write-Host "   ✅ $driverSource → $driverDest" -ForegroundColor Green
Write-Host "   ✅ $pdoDriverSource → $pdoDriverDest" -ForegroundColor Green

# Verificar php.ini
Write-Host "`n📝 Verificando php.ini..." -ForegroundColor Yellow
$phpIni = php --ini | Select-String "Loaded Configuration File" | ForEach-Object { $_.Line -replace '.*=>\s*', '' }

if (-not $phpIni) {
    Write-Host "   ⚠️  No se pudo encontrar php.ini" -ForegroundColor Yellow
} else {
    Write-Host "   📄 php.ini: $phpIni" -ForegroundColor Cyan
    
    $phpIniContent = Get-Content $phpIni -Raw
    
    # Verificar extensiones
    if ($phpIniContent -match 'extension\s*=\s*php_sqlsrv\.dll') {
        Write-Host "   ✅ extension=php_sqlsrv.dll encontrado" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  extension=php_sqlsrv.dll NO encontrado en php.ini" -ForegroundColor Yellow
        Write-Host "      Agregar manualmente: extension=php_sqlsrv.dll" -ForegroundColor Yellow
    }
    
    if ($phpIniContent -match 'extension\s*=\s*php_pdo_sqlsrv\.dll') {
        Write-Host "   ✅ extension=php_pdo_sqlsrv.dll encontrado" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  extension=php_pdo_sqlsrv.dll NO encontrado en php.ini" -ForegroundColor Yellow
        Write-Host "      Agregar manualmente: extension=php_pdo_sqlsrv.dll" -ForegroundColor Yellow
    }
}

# Verificar Visual C++ Redistributable
Write-Host "`n🔍 Verificando Visual C++ Redistributable..." -ForegroundColor Yellow
$vcRedist = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" -ErrorAction SilentlyContinue

if ($vcRedist) {
    Write-Host "   ✅ Visual C++ Redistributable instalado" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Visual C++ Redistributable NO encontrado" -ForegroundColor Yellow
    Write-Host "      Descargar: https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Yellow
}

Write-Host "`n✅ Corrección completada!" -ForegroundColor Green
Write-Host "`n🔄 Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Reiniciar Apache/XAMPP" -ForegroundColor Yellow
Write-Host "   2. Ejecutar: php -m | findstr sqlsrv" -ForegroundColor Yellow
Write-Host "   3. Debe mostrar: pdo_sqlsrv y sqlsrv" -ForegroundColor Yellow


