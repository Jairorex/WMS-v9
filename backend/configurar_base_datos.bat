@echo off
REM ========================================
REM CONFIGURADOR DE BASE DE DATOS SQL SERVER
REM ========================================

echo.
echo ========================================
echo    CONFIGURADOR DE BASE DE DATOS
echo ========================================
echo.

REM Verificar si SQL Server está instalado
echo [INFO] Verificando instalación de SQL Server...
sqlcmd -? >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] SQL Server encontrado
) else (
    echo [ERROR] SQL Server no encontrado
    echo Por favor, instale SQL Server o SQL Server Express
    echo Descarga: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
    pause
    exit /b 1
)

REM Solicitar información de conexión
echo.
echo [INFO] Configuración de conexión a SQL Server
echo.

set /p DB_SERVER="Servidor SQL Server (localhost): "
if "%DB_SERVER%"=="" set DB_SERVER=localhost

set /p DB_PORT="Puerto (1433): "
if "%DB_PORT%"=="" set DB_PORT=1433

set /p DB_USERNAME="Usuario (sa): "
if "%DB_USERNAME%"=="" set DB_USERNAME=sa

set /p DB_PASSWORD="Contraseña: "

set /p DB_NAME="Nombre de la base de datos (wms_escasan): "
if "%DB_NAME%"=="" set DB_NAME=wms_escasan

echo.
echo [INFO] Configuración:
echo - Servidor: %DB_SERVER%
echo - Puerto: %DB_PORT%
echo - Usuario: %DB_USERNAME%
echo - Base de datos: %DB_NAME%
echo.

set /p confirm="¿Continuar con esta configuración? (s/n): "
if /i "%confirm%" neq "s" (
    echo [INFO] Configuración cancelada
    pause
    exit /b 0
)

REM Crear archivo de configuración
echo [INFO] Creando archivo de configuración...
echo DB_CONNECTION=sqlsrv > database_config.env
echo DB_HOST=%DB_SERVER% >> database_config.env
echo DB_PORT=%DB_PORT% >> database_config.env
echo DB_DATABASE=%DB_NAME% >> database_config.env
echo DB_USERNAME=%DB_USERNAME% >> database_config.env
echo DB_PASSWORD=%DB_PASSWORD% >> database_config.env

REM Probar conexión
echo.
echo [INFO] Probando conexión a SQL Server...
sqlcmd -S %DB_SERVER% -U %DB_USERNAME% -P %DB_PASSWORD% -Q "SELECT @@VERSION" >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Conexión exitosa
) else (
    echo [ERROR] No se pudo conectar a SQL Server
    echo Verifique las credenciales y que el servicio esté ejecutándose
    pause
    exit /b 1
)

REM Crear base de datos
echo.
echo [INFO] Creando base de datos...
sqlcmd -S %DB_SERVER% -U %DB_USERNAME% -P %DB_PASSWORD% -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '%DB_NAME%') CREATE DATABASE [%DB_NAME%]"
if %errorLevel% == 0 (
    echo [OK] Base de datos creada o ya existe
) else (
    echo [ERROR] Error al crear la base de datos
    pause
    exit /b 1
)

REM Ejecutar scripts de instalación
echo.
echo [INFO] Ejecutando scripts de instalación...

REM Script 1: Crear tablas básicas
echo [INFO] Ejecutando script de tablas básicas...
sqlcmd -S %DB_SERVER% -U %DB_USERNAME% -P %DB_PASSWORD% -d %DB_NAME% -i "database\crear_tablas_basicas.sql"
if %errorLevel% == 0 (
    echo [OK] Tablas básicas creadas
) else (
    echo [ERROR] Error al crear tablas básicas
)

REM Script 2: Instalar módulos
echo [INFO] Ejecutando script de módulos...
sqlcmd -S %DB_SERVER% -U %DB_USERNAME% -P %DB_PASSWORD% -d %DB_NAME% -i "database\instalar_modulos.sql"
if %errorLevel% == 0 (
    echo [OK] Módulos instalados
) else (
    echo [ERROR] Error al instalar módulos
)

REM Script 3: Insertar datos iniciales
echo [INFO] Ejecutando script de datos iniciales...
sqlcmd -S %DB_SERVER% -U %DB_USERNAME% -P %DB_PASSWORD% -d %DB_NAME% -i "database\datos_iniciales.sql"
if %errorLevel% == 0 (
    echo [OK] Datos iniciales insertados
) else (
    echo [ERROR] Error al insertar datos iniciales
)

REM Script 4: Verificar instalación
echo [INFO] Verificando instalación...
sqlcmd -S %DB_SERVER% -U %DB_USERNAME% -P %DB_PASSWORD% -d %DB_NAME% -i "database\verificar_instalacion.sql"

REM Actualizar archivo .env del backend
echo.
echo [INFO] Actualizando configuración del backend...
if exist "backend\.env" (
    copy "backend\.env" "backend\.env.backup"
    echo [OK] Backup de .env creado
)

REM Crear nuevo .env
echo APP_NAME="WMS Escasan" > backend\.env
echo APP_ENV=production >> backend\.env
echo APP_KEY= >> backend\.env
echo APP_DEBUG=false >> backend\.env
echo APP_URL=http://localhost:5174 >> backend\.env
echo. >> backend\.env
echo DB_CONNECTION=sqlsrv >> backend\.env
echo DB_HOST=%DB_SERVER% >> backend\.env
echo DB_PORT=%DB_PORT% >> backend\.env
echo DB_DATABASE=%DB_NAME% >> backend\.env
echo DB_USERNAME=%DB_USERNAME% >> backend\.env
echo DB_PASSWORD=%DB_PASSWORD% >> backend\.env
echo. >> backend\.env
echo BROADCAST_DRIVER=log >> backend\.env
echo CACHE_DRIVER=file >> backend\.env
echo FILESYSTEM_DISK=local >> backend\.env
echo QUEUE_CONNECTION=sync >> backend\.env
echo SESSION_DRIVER=file >> backend\.env
echo SESSION_LIFETIME=120 >> backend\.env
echo. >> backend\.env
echo MEMCACHED_HOST=127.0.0.1 >> backend\.env
echo. >> backend\.env
echo REDIS_HOST=127.0.0.1 >> backend\.env
echo REDIS_PASSWORD=null >> backend\.env
echo REDIS_PORT=6379 >> backend\.env
echo. >> backend\.env
echo MAIL_MAILER=smtp >> backend\.env
echo MAIL_HOST=mailpit >> backend\.env
echo MAIL_PORT=1025 >> backend\.env
echo MAIL_USERNAME=null >> backend\.env
echo MAIL_PASSWORD=null >> backend\.env
echo MAIL_ENCRYPTION=null >> backend\.env
echo MAIL_FROM_ADDRESS="hello@example.com" >> backend\.env
echo MAIL_FROM_NAME="${APP_NAME}" >> backend\.env
echo. >> backend\.env
echo AWS_ACCESS_KEY_ID= >> backend\.env
echo AWS_SECRET_ACCESS_KEY= >> backend\.env
echo AWS_DEFAULT_REGION=us-east-1 >> backend\.env
echo AWS_BUCKET= >> backend\.env
echo AWS_USE_PATH_STYLE_ENDPOINT=false >> backend\.env
echo. >> backend\.env
echo PUSHER_APP_ID= >> backend\.env
echo PUSHER_APP_KEY= >> backend\.env
echo PUSHER_APP_SECRET= >> backend\.env
echo PUSHER_HOST= >> backend\.env
echo PUSHER_PORT=443 >> backend\.env
echo PUSHER_SCHEME=https >> backend\.env
echo PUSHER_APP_CLUSTER=mt1 >> backend\.env
echo. >> backend\.env
echo VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}" >> backend\.env
echo VITE_PUSHER_HOST="${PUSHER_HOST}" >> backend\.env
echo VITE_PUSHER_PORT="${PUSHER_PORT}" >> backend\.env
echo VITE_PUSHER_SCHEME="${PUSHER_SCHEME}" >> backend\.env
echo VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}" >> backend\.env

echo [OK] Archivo .env actualizado

REM Generar clave de aplicación
echo [INFO] Generando clave de aplicación...
cd backend
php artisan key:generate
cd ..

echo.
echo ========================================
echo    CONFIGURACIÓN COMPLETADA
echo ========================================
echo.
echo [OK] Base de datos configurada exitosamente
echo.
echo [INFO] Configuración aplicada:
echo - Servidor: %DB_SERVER%
echo - Base de datos: %DB_NAME%
echo - Usuario: %DB_USERNAME%
echo.
echo [INFO] Próximos pasos:
echo 1. Ejecutar iniciar_servicios.bat
echo 2. Acceder a http://localhost:5174
echo 3. Login con admin/admin123
echo.

REM Limpiar archivos temporales
del database_config.env >nul 2>&1

echo Presione cualquier tecla para cerrar...
pause >nul

