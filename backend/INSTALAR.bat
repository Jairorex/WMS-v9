@echo off
REM ========================================
REM INSTALADOR AUTOMÁTICO WMS ESCASAN
REM ========================================

echo.
echo ========================================
echo    INSTALADOR WMS ESCASAN v1.0
echo ========================================
echo.

REM Verificar si se ejecuta como administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Ejecutando como administrador...
) else (
    echo [ERROR] Este script debe ejecutarse como administrador
    echo Por favor, haga clic derecho y seleccione "Ejecutar como administrador"
    pause
    exit /b 1
)

REM Crear directorio de instalación
set INSTALL_DIR=C:\WMS-Escasan
echo [INFO] Creando directorio de instalación: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Verificar requisitos del sistema
echo.
echo [INFO] Verificando requisitos del sistema...

REM Verificar PHP
php --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] PHP encontrado
) else (
    echo [ERROR] PHP no encontrado. Instalando PHP...
    call scripts\instalar_php.bat
)

REM Verificar Node.js
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js encontrado
) else (
    echo [ERROR] Node.js no encontrado. Instalando Node.js...
    call scripts\instalar_nodejs.bat
)

REM Verificar Composer
composer --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Composer encontrado
) else (
    echo [ERROR] Composer no encontrado. Instalando Composer...
    call scripts\instalar_composer.bat
)

REM Copiar archivos del sistema
echo.
echo [INFO] Copiando archivos del sistema...
xcopy /E /I /Y backend "%INSTALL_DIR%\backend"
xcopy /E /I /Y frontend "%INSTALL_DIR%\frontend"
xcopy /E /I /Y database "%INSTALL_DIR%\database"
xcopy /E /I /Y docs "%INSTALL_DIR%\docs"

REM Configurar backend
echo.
echo [INFO] Configurando backend Laravel...
cd /d "%INSTALL_DIR%\backend"

REM Crear archivo .env
if not exist ".env" (
    copy ".env.example" ".env"
    echo [OK] Archivo .env creado
)

REM Instalar dependencias PHP
echo [INFO] Instalando dependencias PHP...
composer install --no-dev --optimize-autoloader

REM Generar clave de aplicación
echo [INFO] Generando clave de aplicación...
php artisan key:generate

REM Limpiar caché
echo [INFO] Limpiando caché...
php artisan config:clear
php artisan route:clear
php artisan cache:clear

REM Configurar frontend
echo.
echo [INFO] Configurando frontend React...
cd /d "%INSTALL_DIR%\frontend"

REM Instalar dependencias Node.js
echo [INFO] Instalando dependencias Node.js...
npm install

REM Construir aplicación
echo [INFO] Construyendo aplicación...
npm run build

REM Crear scripts de inicio
echo.
echo [INFO] Creando scripts de inicio...
cd /d "%INSTALL_DIR%"

REM Script para iniciar backend
echo @echo off > iniciar_backend.bat
echo echo Iniciando servidor backend... >> iniciar_backend.bat
echo cd /d "%INSTALL_DIR%\backend" >> iniciar_backend.bat
echo php artisan serve --host=127.0.0.1 --port=8000 >> iniciar_backend.bat

REM Script para iniciar frontend
echo @echo off > iniciar_frontend.bat
echo echo Iniciando servidor frontend... >> iniciar_frontend.bat
echo cd /d "%INSTALL_DIR%\frontend" >> iniciar_frontend.bat
echo npm run dev >> iniciar_frontend.bat

REM Script para iniciar ambos servicios
echo @echo off > iniciar_servicios.bat
echo echo Iniciando servicios WMS Escasan... >> iniciar_servicios.bat
echo start "Backend" cmd /k "cd /d %INSTALL_DIR%\backend && php artisan serve --host=127.0.0.1 --port=8000" >> iniciar_servicios.bat
echo timeout /t 3 /nobreak >> iniciar_servicios.bat
echo start "Frontend" cmd /k "cd /d %INSTALL_DIR%\frontend && npm run dev" >> iniciar_servicios.bat
echo echo. >> iniciar_servicios.bat
echo echo Servicios iniciados: >> iniciar_servicios.bat
echo echo - Backend: http://127.0.0.1:8000 >> iniciar_servicios.bat
echo echo - Frontend: http://localhost:5174 >> iniciar_servicios.bat
echo echo. >> iniciar_servicios.bat
echo echo Presione cualquier tecla para cerrar... >> iniciar_servicios.bat
echo pause >> iniciar_servicios.bat

REM Crear acceso directo en escritorio
echo.
echo [INFO] Creando acceso directo en escritorio...
set DESKTOP=%USERPROFILE%\Desktop
echo [InternetShortcut] > "%DESKTOP%\WMS Escasan.url"
echo URL=http://localhost:5174 >> "%DESKTOP%\WMS Escasan.url"
echo IconFile=%INSTALL_DIR%\frontend\public\favicon.ico >> "%DESKTOP%\WMS Escasan.url"
echo IconIndex=0 >> "%DESKTOP%\WMS Escasan.url"

REM Crear entrada en el menú inicio
echo.
echo [INFO] Creando entrada en el menú inicio...
set START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs
if not exist "%START_MENU%\WMS Escasan" mkdir "%START_MENU%\WMS Escasan"

echo [InternetShortcut] > "%START_MENU%\WMS Escasan\WMS Escasan.url"
echo URL=http://localhost:5174 >> "%START_MENU%\WMS Escasan\WMS Escasan.url"
echo IconFile=%INSTALL_DIR%\frontend\public\favicon.ico >> "%START_MENU%\WMS Escasan\WMS Escasan.url"
echo IconIndex=0 >> "%START_MENU%\WMS Escasan\WMS Escasan.url"

REM Crear script de desinstalación
echo.
echo [INFO] Creando script de desinstalación...
echo @echo off > DESINSTALAR.bat
echo echo Desinstalando WMS Escasan... >> DESINSTALAR.bat
echo set /p confirm="¿Está seguro de que desea desinstalar? (s/n): " >> DESINSTALAR.bat
echo if /i "%%confirm%%"=="s" ( >> DESINSTALAR.bat
echo     echo Eliminando archivos... >> DESINSTALAR.bat
echo     rmdir /s /q "%INSTALL_DIR%" >> DESINSTALAR.bat
echo     del "%DESKTOP%\WMS Escasan.url" >> DESINSTALAR.bat
echo     rmdir /s /q "%START_MENU%\WMS Escasan" >> DESINSTALAR.bat
echo     echo WMS Escasan desinstalado correctamente. >> DESINSTALAR.bat
echo ^) else ( >> DESINSTALAR.bat
echo     echo Desinstalación cancelada. >> DESINSTALAR.bat
echo ^) >> DESINSTALAR.bat
echo pause >> DESINSTALAR.bat

REM Mostrar información de instalación
echo.
echo ========================================
echo    INSTALACIÓN COMPLETADA
echo ========================================
echo.
echo [OK] WMS Escasan instalado en: %INSTALL_DIR%
echo.
echo [INFO] Próximos pasos:
echo 1. Configurar base de datos SQL Server
echo 2. Ejecutar scripts SQL en database/
echo 3. Ejecutar iniciar_servicios.bat
echo.
echo [INFO] URLs de acceso:
echo - Frontend: http://localhost:5174
echo - Backend: http://127.0.0.1:8000
echo.
echo [INFO] Credenciales por defecto:
echo - Usuario: admin
echo - Contraseña: admin123
echo.
echo [INFO] Documentación disponible en: %INSTALL_DIR%\docs\
echo.

REM Preguntar si iniciar servicios
set /p start_services="¿Desea iniciar los servicios ahora? (s/n): "
if /i "%start_services%"=="s" (
    echo.
    echo [INFO] Iniciando servicios...
    call iniciar_servicios.bat
) else (
    echo.
    echo [INFO] Para iniciar los servicios más tarde, ejecute: iniciar_servicios.bat
)

echo.
echo [INFO] Instalación completada exitosamente!
echo Presione cualquier tecla para cerrar...
pause >nul

