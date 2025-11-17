@echo off
REM ========================================
REM CREAR PAQUETE ZIP WMS ESCASAN
REM Versión sin requerir permisos de administrador
REM ========================================

echo.
echo ========================================
echo    CREANDO PAQUETE ZIP WMS ESCASAN
echo ========================================
echo.

REM Obtener ruta del directorio del script
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
cd ..

REM Verificar que estamos en el directorio correcto
if not exist "backend" (
    echo [ERROR] No se encontró la carpeta backend
    echo Por favor, ejecuta este script desde la carpeta backend
    pause
    exit /b 1
)

REM Crear directorio temporal para el paquete
set "PACKAGE_DIR=WMS-Escasan-Package"
set "PACKAGE_NAME=WMS-Escasan-Installer-v1.0"

echo [INFO] Preparando paquete en: %PACKAGE_DIR%

REM Limpiar directorio si existe
if exist "%PACKAGE_DIR%" (
    echo [INFO] Limpiando directorio existente...
    rmdir /s /q "%PACKAGE_DIR%"
)

REM Crear estructura de directorios
echo [INFO] Creando estructura de directorios...
mkdir "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%\backend"
mkdir "%PACKAGE_DIR%\frontend"
mkdir "%PACKAGE_DIR%\database"
mkdir "%PACKAGE_DIR%\scripts"
mkdir "%PACKAGE_DIR%\docs"

REM Copiar backend (excluyendo node_modules y vendor)
echo [INFO] Copiando backend...
xcopy /E /I /Y /EXCLUDE:exclude_backend.txt backend "%PACKAGE_DIR%\backend" 2>nul
if %errorLevel% neq 0 (
    echo [INFO] Copiando backend (método alternativo)...
    robocopy backend "%PACKAGE_DIR%\backend" /E /XD node_modules vendor storage\framework\cache storage\framework\sessions storage\framework\views storage\logs .git /XF .env .gitignore 2>nul
)

REM Copiar frontend (excluyendo node_modules y dist)
echo [INFO] Copiando frontend...
xcopy /E /I /Y /EXCLUDE:exclude_frontend.txt frontend "%PACKAGE_DIR%\frontend" 2>nul
if %errorLevel% neq 0 (
    echo [INFO] Copiando frontend (método alternativo)...
    robocopy frontend "%PACKAGE_DIR%\frontend" /E /XD node_modules dist .git /XF .env.local .gitignore 2>nul
)

REM Copiar scripts de base de datos
echo [INFO] Copiando scripts de base de datos...
if exist "backend\database" (
    xcopy /E /I /Y "backend\database\*.sql" "%PACKAGE_DIR%\database\" 2>nul
    copy "backend\instalar_modulos_completos.sql" "%PACKAGE_DIR%\database\" 2>nul
)

REM Copiar scripts de instalación
echo [INFO] Copiando scripts de instalación...
copy "backend\INSTALAR.bat" "%PACKAGE_DIR%\" 2>nul
copy "backend\DESINSTALAR.bat" "%PACKAGE_DIR%\" 2>nul
copy "backend\configurar_base_datos.bat" "%PACKAGE_DIR%\scripts\" 2>nul

REM Crear script de inicio mejorado
echo [INFO] Creando script de inicio...
(
echo @echo off
echo REM Iniciar servicios WMS Escasan
echo echo Iniciando servicios WMS Escasan...
echo start "Backend WMS" cmd /k "cd /d %%~dp0backend && php artisan serve --host=127.0.0.1 --port=8000"
echo timeout /t 3 /nobreak ^>nul
echo start "Frontend WMS" cmd /k "cd /d %%~dp0frontend && npm run dev"
echo echo.
echo echo Servicios iniciados:
echo echo - Backend: http://127.0.0.1:8000
echo echo - Frontend: http://localhost:5174
echo echo.
echo pause
) > "%PACKAGE_DIR%\iniciar_servicios.bat"

REM Crear script de instalación sin admin
echo [INFO] Creando script de instalación sin administrador...
(
echo @echo off
echo REM Instalación WMS Escasan - Sin permisos de administrador
echo echo.
echo echo ========================================
echo    INSTALADOR WMS ESCASAN v1.0
echo ========================================
echo.
echo [INFO] Este instalador NO requiere permisos de administrador
echo.
echo [INFO] Verificando requisitos...
echo.
REM Verificar PHP
php --version ^>nul 2^>^&1
if %errorLevel% == 0 (
    echo [OK] PHP encontrado
) else (
    echo [ERROR] PHP no encontrado
    echo Por favor, instala PHP 8.1+ desde https://windows.php.net/download/
    pause
    exit /b 1
)
REM Verificar Node.js
node --version ^>nul 2^>^&1
if %errorLevel% == 0 (
    echo [OK] Node.js encontrado
) else (
    echo [ERROR] Node.js no encontrado
    echo Por favor, instala Node.js 18+ desde https://nodejs.org/
    pause
    exit /b 1
)
REM Verificar Composer
composer --version ^>nul 2^>^&1
if %errorLevel% == 0 (
    echo [OK] Composer encontrado
) else (
    echo [ERROR] Composer no encontrado
    echo Por favor, instala Composer desde https://getcomposer.org/
    pause
    exit /b 1
)
echo.
echo [INFO] Instalando dependencias del backend...
cd /d "%%~dp0backend"
composer install --no-dev --optimize-autoloader
if not exist ".env" (
    copy ".env.example" ".env"
    echo [INFO] Archivo .env creado. Por favor, configúralo con tus datos de base de datos.
)
php artisan key:generate
php artisan config:clear
php artisan route:clear
php artisan cache:clear
echo.
echo [INFO] Instalando dependencias del frontend...
cd /d "%%~dp0frontend"
npm install
echo.
echo ========================================
echo    INSTALACIÓN COMPLETADA
echo ========================================
echo.
echo [INFO] Próximos pasos:
echo 1. Configurar base de datos SQL Server
echo 2. Ejecutar scripts SQL en database/
echo 3. Ejecutar iniciar_servicios.bat
echo.
pause
) > "%PACKAGE_DIR%\INSTALAR_SIN_ADMIN.bat"

REM Copiar documentación
echo [INFO] Copiando documentación...
if exist "backend\README.md" copy "backend\README.md" "%PACKAGE_DIR%\README.md" 2>nul
if exist "backend\GUIA_DESPLIEGUE.md" copy "backend\GUIA_DESPLIEGUE.md" "%PACKAGE_DIR%\docs\GUIA_DESPLIEGUE.md" 2>nul
if exist "backend\PAQUETE_INSTALACION_WMS.md" copy "backend\PAQUETE_INSTALACION_WMS.md" "%PACKAGE_DIR%\docs\MANUAL_INSTALACION.md" 2>nul

REM Crear README rápido
echo [INFO] Creando README rápido...
(
echo WMS ESCASAN - Sistema de Gestión de Almacén
echo ============================================
echo.
echo INSTALACIÓN RÁPIDA:
echo 1. Ejecutar INSTALAR_SIN_ADMIN.bat
echo 2. Configurar base de datos SQL Server
echo 3. Ejecutar scripts SQL en carpeta database/
echo 4. Ejecutar iniciar_servicios.bat
echo.
echo ACCESO:
echo - Frontend: http://localhost:5174
echo - Backend: http://127.0.0.1:8000
echo.
echo CREDENCIALES POR DEFECTO:
echo - Usuario: admin@escasan.com
echo - Contraseña: admin123
echo.
echo Para más información, consulta docs/MANUAL_INSTALACION.md
) > "%PACKAGE_DIR%\README.txt"

REM Limpiar archivos temporales del backend
echo [INFO] Limpiando archivos temporales...
if exist "%PACKAGE_DIR%\backend\storage\logs\*.log" del /q "%PACKAGE_DIR%\backend\storage\logs\*.log" 2>nul
if exist "%PACKAGE_DIR%\backend\storage\framework\cache\*" rmdir /s /q "%PACKAGE_DIR%\backend\storage\framework\cache" 2>nul && mkdir "%PACKAGE_DIR%\backend\storage\framework\cache" 2>nul

REM Crear ZIP usando PowerShell (no requiere herramientas externas)
echo.
echo [INFO] Creando archivo ZIP...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%PACKAGE_NAME%.zip' -Force"

if %errorLevel% == 0 (
    echo [OK] Archivo ZIP creado: %PACKAGE_NAME%.zip
    
    REM Mostrar tamaño del archivo
    for %%A in ("%PACKAGE_NAME%.zip") do (
        set /a size_mb=%%~zA/1024/1024
        echo [INFO] Tamaño del paquete: !size_mb! MB
    )
) else (
    echo [ERROR] Error al crear el archivo ZIP
    echo El paquete está en la carpeta: %PACKAGE_DIR%
)

REM Mostrar información final
echo.
echo ========================================
echo    PAQUETE CREADO EXITOSAMENTE
echo ========================================
echo.
echo [OK] Carpeta del paquete: %PACKAGE_DIR%
echo [OK] Archivo ZIP: %PACKAGE_NAME%.zip
echo.
echo [INFO] Contenido del paquete:
dir /b "%PACKAGE_DIR%"
echo.
echo [INFO] Próximos pasos:
echo 1. Probar extracción del ZIP
echo 2. Verificar que todos los archivos estén presentes
echo 3. Distribuir el archivo ZIP
echo.

REM Preguntar si abrir la carpeta
set /p open_folder="¿Desea abrir la carpeta del paquete? (s/n): "
if /i "%open_folder%"=="s" (
    explorer "%PACKAGE_DIR%"
)

echo.
echo [INFO] Proceso completado!
pause
