@echo off
REM ========================================
REM DESINSTALADOR WMS ESCASAN
REM ========================================

echo.
echo ========================================
echo    DESINSTALADOR WMS ESCASAN v1.0
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

REM Definir directorio de instalación
set INSTALL_DIR=C:\WMS-Escasan
set DESKTOP=%USERPROFILE%\Desktop
set START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs

echo [WARNING] Esta acción eliminará completamente WMS Escasan del sistema.
echo.
echo Archivos que serán eliminados:
echo - Directorio: %INSTALL_DIR%
echo - Acceso directo: %DESKTOP%\WMS Escasan.url
echo - Menú inicio: %START_MENU%\WMS Escasan\
echo.

set /p confirm="¿Está seguro de que desea desinstalar WMS Escasan? (s/n): "
if /i "%confirm%"=="s" (
    echo.
    echo [INFO] Desinstalando WMS Escasan...
    
    REM Detener servicios si están ejecutándose
    echo [INFO] Deteniendo servicios...
    taskkill /f /im php.exe >nul 2>&1
    taskkill /f /im node.exe >nul 2>&1
    
    REM Eliminar directorio principal
    if exist "%INSTALL_DIR%" (
        echo [INFO] Eliminando directorio principal...
        rmdir /s /q "%INSTALL_DIR%"
        if exist "%INSTALL_DIR%" (
            echo [ERROR] No se pudo eliminar el directorio principal
            echo Algunos archivos pueden estar en uso
        ) else (
            echo [OK] Directorio principal eliminado
        )
    ) else (
        echo [INFO] Directorio principal no encontrado
    )
    
    REM Eliminar acceso directo del escritorio
    if exist "%DESKTOP%\WMS Escasan.url" (
        echo [INFO] Eliminando acceso directo del escritorio...
        del "%DESKTOP%\WMS Escasan.url"
        echo [OK] Acceso directo eliminado
    )
    
    REM Eliminar entrada del menú inicio
    if exist "%START_MENU%\WMS Escasan" (
        echo [INFO] Eliminando entrada del menú inicio...
        rmdir /s /q "%START_MENU%\WMS Escasan"
        echo [OK] Entrada del menú inicio eliminada
    )
    
    REM Limpiar registros de Windows (opcional)
    echo.
    set /p clean_registry="¿Desea limpiar registros de Windows? (s/n): "
    if /i "%clean_registry%"=="s" (
        echo [INFO] Limpiando registros de Windows...
        reg delete "HKEY_CURRENT_USER\Software\WMS-Escasan" /f >nul 2>&1
        echo [OK] Registros limpiados
    )
    
    echo.
    echo ========================================
    echo    DESINSTALACIÓN COMPLETADA
    echo ========================================
    echo.
    echo [OK] WMS Escasan ha sido desinstalado completamente
    echo.
    echo [INFO] Archivos eliminados:
    echo - Directorio: %INSTALL_DIR%
    echo - Acceso directo: %DESKTOP%\WMS Escasan.url
    echo - Menú inicio: %START_MENU%\WMS Escasan\
    echo.
    echo [INFO] Nota: Las dependencias del sistema (PHP, Node.js, Composer)
    echo no fueron eliminadas para evitar afectar otras aplicaciones.
    echo.
    
) else (
    echo.
    echo [INFO] Desinstalación cancelada por el usuario
    echo WMS Escasan permanece instalado en el sistema
)

echo.
echo Presione cualquier tecla para cerrar...
pause >nul

