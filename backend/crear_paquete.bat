@echo off
REM ========================================
REM CREAR PAQUETE DE INSTALACIÓN WMS ESCASAN
REM ========================================

echo.
echo ========================================
echo    CREANDO PAQUETE DE INSTALACIÓN
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

REM Crear directorio del paquete
set PACKAGE_DIR=C:\WMS-Escasan-Package
set PACKAGE_NAME=WMS-Escasan-Installer-v1.0

echo [INFO] Creando directorio del paquete: %PACKAGE_DIR%
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"

REM Crear estructura de directorios
echo [INFO] Creando estructura de directorios...
mkdir "%PACKAGE_DIR%\backend"
mkdir "%PACKAGE_DIR%\frontend"
mkdir "%PACKAGE_DIR%\database"
mkdir "%PACKAGE_DIR%\scripts"
mkdir "%PACKAGE_DIR%\docs"

REM Copiar archivos del backend
echo [INFO] Copiando archivos del backend...
xcopy /E /I /Y backend "%PACKAGE_DIR%\backend"

REM Copiar archivos del frontend
echo [INFO] Copiando archivos del frontend...
xcopy /E /I /Y frontend "%PACKAGE_DIR%\frontend"

REM Copiar scripts de base de datos
echo [INFO] Copiando scripts de base de datos...
copy "database\crear_base_datos.sql" "%PACKAGE_DIR%\database\"
copy "database\crear_tablas_basicas.sql" "%PACKAGE_DIR%\database\"
copy "database\instalar_modulos.sql" "%PACKAGE_DIR%\database\"
copy "database\datos_iniciales.sql" "%PACKAGE_DIR%\database\"
copy "database\verificar_instalacion.sql" "%PACKAGE_DIR%\database\"
copy "instalar_modulos_completos.sql" "%PACKAGE_DIR%\database\"

REM Copiar scripts de instalación
echo [INFO] Copiando scripts de instalación...
copy "INSTALAR.bat" "%PACKAGE_DIR%\"
copy "DESINSTALAR.bat" "%PACKAGE_DIR%\"
copy "configurar_base_datos.bat" "%PACKAGE_DIR%\scripts\"

REM Crear script de inicio de servicios
echo [INFO] Creando script de inicio de servicios...
echo @echo off > "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo Iniciando servicios WMS Escasan... >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo start "Backend" cmd /k "cd /d %PACKAGE_DIR%\backend && php artisan serve --host=127.0.0.1 --port=8000" >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo timeout /t 3 /nobreak >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo start "Frontend" cmd /k "cd /d %PACKAGE_DIR%\frontend && npm run dev" >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo. >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo Servicios iniciados: >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo - Backend: http://127.0.0.1:8000 >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo - Frontend: http://localhost:5174 >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo. >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo echo Presione cualquier tecla para cerrar... >> "%PACKAGE_DIR%\iniciar_servicios.bat"
echo pause >> "%PACKAGE_DIR%\iniciar_servicios.bat"

REM Copiar documentación
echo [INFO] Copiando documentación...
copy "README.md" "%PACKAGE_DIR%\"
copy "PAQUETE_INSTALACION_WMS.md" "%PACKAGE_DIR%\docs\MANUAL_INSTALACION.md"

REM Crear manual de usuario
echo [INFO] Creando manual de usuario...
echo # Manual de Usuario WMS Escasan > "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo. >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo ## Acceso al Sistema >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo. >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **URL**: http://localhost:5174 >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Usuario**: admin@escasan.com >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Contraseña**: admin123 >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo. >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo ## Módulos Disponibles >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo. >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Dashboard**: Panel principal con KPIs >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Productos**: Gestión de catálogo >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Ubicaciones**: Gestión de ubicaciones >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Inventario**: Control de stock >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Tareas**: Gestión de tareas >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Incidencias**: Sistema de incidencias >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Lotes**: Gestión de lotes y trazabilidad >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Notificaciones**: Sistema de notificaciones >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"
echo - **Reportes**: Generación de reportes >> "%PACKAGE_DIR%\docs\MANUAL_USUARIO.md"

REM Crear manual de solución de problemas
echo [INFO] Creando manual de solución de problemas...
echo # Solución de Problemas WMS Escasan > "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo ## Problemas Comunes >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo ### Error de Conexión a Base de Datos >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 1. Verificar que SQL Server esté ejecutándose >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 2. Verificar credenciales en .env >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 3. Verificar que la base de datos exista >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo ### Error de CORS >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 1. Limpiar caché de Laravel >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 2. Verificar configuración de CORS >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo ### Error de Dependencias >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo. >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 1. Reinstalar dependencias PHP >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"
echo 2. Reinstalar dependencias Node.js >> "%PACKAGE_DIR%\docs\TROUBLESHOOTING.md"

REM Crear manual de requisitos del sistema
echo [INFO] Creando manual de requisitos del sistema...
echo # Requisitos del Sistema WMS Escasan > "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo. >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo ## Requisitos Mínimos >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo. >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **Sistema Operativo**: Windows 10/11 (64-bit) >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **Memoria RAM**: 4 GB mínimo, 8 GB recomendado >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **Espacio en Disco**: 2 GB libres >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **Procesador**: Intel Core i3 o equivalente >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo. >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo ## Software Requerido >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo. >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **SQL Server 2019+** o **SQL Server Express** >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **PHP 8.1+** con extensiones necesarias >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **Node.js 18+** y npm >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"
echo - **Composer** (gestor de dependencias PHP) >> "%PACKAGE_DIR%\docs\REQUISITOS_SISTEMA.md"

REM Crear archivo de información del paquete
echo [INFO] Creando archivo de información del paquete...
echo WMS Escasan - Sistema de Gestión de Almacén > "%PACKAGE_DIR%\INFO.txt"
echo ========================================== >> "%PACKAGE_DIR%\INFO.txt"
echo. >> "%PACKAGE_DIR%\INFO.txt"
echo Versión: 1.0.0 >> "%PACKAGE_DIR%\INFO.txt"
echo Fecha: Octubre 2024 >> "%PACKAGE_DIR%\INFO.txt"
echo Desarrollado por: Equipo de Desarrollo Escasan >> "%PACKAGE_DIR%\INFO.txt"
echo. >> "%PACKAGE_DIR%\INFO.txt"
echo Módulos incluidos: >> "%PACKAGE_DIR%\INFO.txt"
echo - Gestión de usuarios y roles >> "%PACKAGE_DIR%\INFO.txt"
echo - Catálogo de productos >> "%PACKAGE_DIR%\INFO.txt"
echo - Gestión de ubicaciones >> "%PACKAGE_DIR%\INFO.txt"
echo - Control de inventario >> "%PACKAGE_DIR%\INFO.txt"
echo - Gestión de tareas >> "%PACKAGE_DIR%\INFO.txt"
echo - Sistema de incidencias >> "%PACKAGE_DIR%\INFO.txt"
echo - Gestión de lotes y trazabilidad >> "%PACKAGE_DIR%\INFO.txt"
echo - Sistema de notificaciones >> "%PACKAGE_DIR%\INFO.txt"
echo - Dashboard con KPIs >> "%PACKAGE_DIR%\INFO.txt"
echo - Generación de reportes >> "%PACKAGE_DIR%\INFO.txt"
echo. >> "%PACKAGE_DIR%\INFO.txt"
echo Instalación: >> "%PACKAGE_DIR%\INFO.txt"
echo 1. Ejecutar INSTALAR.bat >> "%PACKAGE_DIR%\INFO.txt"
echo 2. Configurar base de datos >> "%PACKAGE_DIR%\INFO.txt"
echo 3. Ejecutar iniciar_servicios.bat >> "%PACKAGE_DIR%\INFO.txt"
echo. >> "%PACKAGE_DIR%\INFO.txt"
echo Acceso: >> "%PACKAGE_DIR%\INFO.txt"
echo - URL: http://localhost:5174 >> "%PACKAGE_DIR%\INFO.txt"
echo - Usuario: admin@escasan.com >> "%PACKAGE_DIR%\INFO.txt"
echo - Contraseña: admin123 >> "%PACKAGE_DIR%\INFO.txt"

REM Crear archivo de licencia
echo [INFO] Creando archivo de licencia...
echo Licencia de Uso WMS Escasan > "%PACKAGE_DIR%\LICENCIA.txt"
echo ========================== >> "%PACKAGE_DIR%\LICENCIA.txt"
echo. >> "%PACKAGE_DIR%\LICENCIA.txt"
echo Copyright (c) 2024 Escasan >> "%PACKAGE_DIR%\LICENCIA.txt"
echo. >> "%PACKAGE_DIR%\INFO.txt"
echo Todos los derechos reservados. >> "%PACKAGE_DIR%\LICENCIA.txt"
echo. >> "%PACKAGE_DIR%\LICENCIA.txt"
echo Este software está protegido por derechos de autor. >> "%PACKAGE_DIR%\LICENCIA.txt"
echo El uso no autorizado está prohibido. >> "%PACKAGE_DIR%\LICENCIA.txt"

REM Crear archivo de cambios
echo [INFO] Creando archivo de cambios...
echo Historial de Cambios WMS Escasan > "%PACKAGE_DIR%\CHANGELOG.txt"
echo ================================ >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo. >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo Versión 1.0.0 - Octubre 2024 >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo ============================== >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo. >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Lanzamiento inicial del sistema >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Implementación de módulos básicos >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Implementación de módulos avanzados >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Sistema de lotes y trazabilidad >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Sistema de notificaciones multi-canal >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Dashboard con KPIs en tiempo real >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Generación de reportes avanzados >> "%PACKAGE_DIR%\CHANGELOG.txt"
echo - Instalación automatizada >> "%PACKAGE_DIR%\CHANGELOG.txt"

REM Limpiar archivos temporales
echo [INFO] Limpiando archivos temporales...
cd /d "%PACKAGE_DIR%\backend"
if exist "storage\logs\*.log" del "storage\logs\*.log"
if exist "storage\framework\cache\*" del /q "storage\framework\cache\*"
if exist "storage\framework\sessions\*" del /q "storage\framework\sessions\*"
if exist "storage\framework\views\*" del /q "storage\framework\views\*"

REM Limpiar node_modules del frontend
echo [INFO] Limpiando node_modules del frontend...
cd /d "%PACKAGE_DIR%\frontend"
if exist "node_modules" rmdir /s /q "node_modules"
if exist "dist" rmdir /s /q "dist"

REM Crear archivo ZIP del paquete
echo [INFO] Creando archivo ZIP del paquete...
cd /d "C:\"
powershell -command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%PACKAGE_NAME%.zip' -Force"

REM Mostrar información del paquete creado
echo.
echo ========================================
echo    PAQUETE CREADO EXITOSAMENTE
echo ========================================
echo.
echo [OK] Paquete creado en: %PACKAGE_DIR%
echo [OK] Archivo ZIP: %PACKAGE_NAME%.zip
echo.
echo [INFO] Contenido del paquete:
echo - Backend Laravel completo
echo - Frontend React completo
echo - Scripts de base de datos
echo - Scripts de instalación
echo - Documentación completa
echo - Datos de prueba
echo.
echo [INFO] Tamaño del paquete:
for %%A in ("%PACKAGE_NAME%.zip") do echo - Archivo ZIP: %%~zA bytes
echo.
echo [INFO] Próximos pasos:
echo 1. Distribuir el archivo %PACKAGE_NAME%.zip
echo 2. En la PC destino, extraer el ZIP
echo 3. Ejecutar INSTALAR.bat
echo 4. Configurar base de datos
echo 5. Ejecutar iniciar_servicios.bat
echo.

REM Preguntar si abrir la carpeta del paquete
set /p open_folder="¿Desea abrir la carpeta del paquete? (s/n): "
if /i "%open_folder%"=="s" (
    explorer "%PACKAGE_DIR%"
)

echo.
echo [INFO] Paquete de instalación creado exitosamente!
echo Presione cualquier tecla para cerrar...
pause >nul

