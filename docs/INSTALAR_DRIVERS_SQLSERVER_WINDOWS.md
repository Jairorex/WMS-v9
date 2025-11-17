# 🔧 Instalar Drivers SQL Server para PHP en Windows

## 🔴 Error

```
could not find driver (Connection: sqlsrv, SQL: select...)
```

**Causa:** PHP no tiene los drivers de SQL Server instalados o habilitados.

---

## ✅ Solución Paso a Paso

### Paso 1: Descargar Drivers SQL Server

**Descargar desde Microsoft:**
- **Enlace:** https://github.com/Microsoft/msphpsql/releases
- **Versión:** Descargar la última versión (ej: `8.2.0` o superior)
- **Archivo:** `php_pdo_sqlsrv_82_ts_x64.dll` y `php_sqlsrv_82_ts_x64.dll`

**O descargar directamente:**
```powershell
# Para PHP 8.2 Thread Safe (TS) x64
# Descargar desde: https://github.com/Microsoft/msphpsql/releases/latest
```

### Paso 2: Identificar Versión de PHP

```powershell
php -v
# Ver: PHP 8.2.x (ts) o (nts)

php -i | findstr "Thread Safety"
# Ver: Thread Safety => enabled (TS) o disabled (NTS)
```

**Importante:** 
- **TS** = Thread Safe (usa `_ts_` en el nombre del driver)
- **NTS** = Non Thread Safe (usa `_nts_` en el nombre del driver)

### Paso 3: Encontrar Directorio de Extensiones PHP

```powershell
php -i | findstr "extension_dir"
# Ejemplo: extension_dir => C:\php\ext => C:\php\ext
```

O buscar en `php.ini`:
```powershell
php --ini
# Mostrará la ruta del php.ini
```

### Paso 4: Copiar Drivers a Carpeta de Extensiones

1. **Descomprimir** los archivos descargados
2. **Copiar** estos archivos a la carpeta `ext` de PHP:
   - `php_pdo_sqlsrv_82_ts_x64.dll` → `C:\php\ext\php_pdo_sqlsrv.dll`
   - `php_sqlsrv_82_ts_x64.dll` → `C:\php\ext\php_sqlsrv.dll`

**Renombrar a nombres simples:**
- `php_pdo_sqlsrv_82_ts_x64.dll` → `php_pdo_sqlsrv.dll`
- `php_sqlsrv_82_ts_x64.dll` → `php_sqlsrv.dll`

### Paso 5: Habilitar Extensiones en php.ini

**Encontrar php.ini:**
```powershell
php --ini
```

**Editar php.ini** y agregar estas líneas:

```ini
; SQL Server Drivers
extension=php_sqlsrv.dll
extension=php_pdo_sqlsrv.dll
```

**Ubicación:** Agregar después de otras extensiones, por ejemplo:

```ini
extension=curl
extension=fileinfo
extension=mbstring
extension=openssl
extension=xml
extension=zip

; SQL Server Drivers
extension=php_sqlsrv.dll
extension=php_pdo_sqlsrv.dll
```

### Paso 6: Instalar ODBC Driver 17

**Descargar e instalar:**
- **Enlace:** https://aka.ms/downloadmsodbcsql
- Ejecutar el instalador
- Aceptar términos y condiciones

### Paso 7: Verificar Instalación

```powershell
php -m | findstr sqlsrv
```

**Debe mostrar:**
```
pdo_sqlsrv
sqlsrv
```

**Si no aparece, verificar:**
1. Archivos DLL están en la carpeta `ext`
2. Nombres están correctos en `php.ini`
3. PHP puede leer los archivos (permisos)

### Paso 8: Reiniciar Servidor

```powershell
# Si usas XAMPP/WAMP
# Reiniciar Apache desde el panel de control

# Si usas php artisan serve
# Detener (Ctrl+C) y reiniciar
php artisan serve
```

---

## 🔍 Verificación Completa

### Verificar Extensiones

```powershell
php -m
```

**Debe incluir:**
- `pdo`
- `pdo_sqlsrv`
- `sqlsrv`

### Verificar Conexión

```powershell
php artisan tinker
```

Luego ejecuta:
```php
DB::connection()->getPdo();
```

**Si funciona:** Debe mostrar información del PDO sin errores.

---

## 🚨 Solución de Problemas

### Error: "Unable to load dynamic library"

**Causa:** Versión incorrecta del driver o falta ODBC Driver.

**Solución:**
1. Verificar que la versión del driver coincide con PHP (8.2)
2. Verificar que es TS o NTS según tu PHP
3. Instalar ODBC Driver 17

### Error: "Call to undefined function sqlsrv_connect()"

**Causa:** Extensión no está cargada.

**Solución:**
```powershell
# Verificar que está en php.ini
php -i | findstr "sqlsrv"
```

### Error: "ODBC Driver 17 for SQL Server not found"

**Causa:** ODBC Driver no está instalado.

**Solución:**
1. Descargar: https://aka.ms/downloadmsodbcsql
2. Instalar
3. Reiniciar servidor

---

## 📋 Checklist Rápido

- [ ] Descargados drivers SQL Server (versión correcta para PHP 8.2)
- [ ] Drivers copiados a carpeta `ext` de PHP
- [ ] Drivers renombrados a `php_sqlsrv.dll` y `php_pdo_sqlsrv.dll`
- [ ] Extensiones agregadas en `php.ini`
- [ ] ODBC Driver 17 instalado
- [ ] PHP reiniciado
- [ ] Verificado con `php -m`
- [ ] Verificado con `php artisan tinker`

---

## 🎯 Script Automático (PowerShell)

```powershell
# Verificar PHP
$phpVersion = php -v | Select-String "PHP (\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
Write-Host "PHP Version: $phpVersion"

# Verificar extensiones
$extensions = php -m
if ($extensions -match "sqlsrv") {
    Write-Host "✅ Drivers SQL Server instalados"
} else {
    Write-Host "❌ Drivers SQL Server NO instalados"
    Write-Host "Sigue los pasos manuales arriba"
}

# Verificar ODBC
$odbcDrivers = odbcinst -q -d
if ($odbcDrivers -match "ODBC Driver 17") {
    Write-Host "✅ ODBC Driver 17 instalado"
} else {
    Write-Host "❌ ODBC Driver 17 NO instalado"
    Write-Host "Descargar: https://aka.ms/downloadmsodbcsql"
}
```

---

## 📝 Notas Importantes

1. **Versión del Driver:** Debe coincidir con la versión de PHP (8.2)
2. **Thread Safety:** TS o NTS según tu instalación de PHP
3. **Arquitectura:** x64 o x86 según tu sistema
4. **ODBC Driver:** Requerido para que funcionen los drivers PHP

---

## 🔗 Enlaces Útiles

- **Drivers SQL Server:** https://github.com/Microsoft/msphpsql/releases
- **ODBC Driver 17:** https://aka.ms/downloadmsodbcsql
- **Documentación:** https://docs.microsoft.com/en-us/sql/connect/php/

---

**✅ Después de seguir estos pasos, el error "could not find driver" debería desaparecer.**

