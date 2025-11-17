# 🔧 Solución: DLL Incompatible - php_sqlsrv.dll

## 🔴 Error

```
Unable to load dynamic library 'php_sqlsrv.dll' 
(%1 no es una aplicación Win32 válida)
```

**Causa:** El DLL descargado no es compatible con tu versión de PHP.

---

## ✅ Solución Paso a Paso

### Paso 1: Identificar Versión Exacta de PHP

```powershell
php -v
```

**Ejemplo de salida:**
```
PHP 8.2.12 (cli) (built: Oct 24 2023 21:15:15) (ZTS Visual C++ 2019 x64)
```

**Información importante:**
- **Versión:** 8.2.12 → Necesitas drivers para **8.2**
- **ZTS** → **Thread Safe (TS)** → Necesitas drivers con `_ts_`
- **x64** → **64 bits** → Necesitas drivers con `_x64`

**Por lo tanto necesitas:**
- `php_sqlsrv_82_ts_x64.dll`
- `php_pdo_sqlsrv_82_ts_x64.dll`

### Paso 2: Descargar Drivers Correctos

**Opción 1: Descargar desde GitHub (Recomendado)**

1. Ir a: https://github.com/Microsoft/msphpsql/releases
2. Descargar la última versión (ej: `8.2.0` o superior)
3. Descargar el archivo ZIP: `php_sqlsrv_82_ts_x64.zip` (para PHP 8.2 Thread Safe x64)

**O directamente:**
```powershell
# Descargar drivers para PHP 8.2 TS x64
# Ir a: https://github.com/Microsoft/msphpsql/releases/latest
# Buscar: php_sqlsrv_82_ts_x64.zip
```

**Opción 2: Descargar desde Microsoft**

1. Ir a: https://docs.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
2. Descargar drivers para PHP 8.2

### Paso 3: Instalar Visual C++ Redistributable (REQUERIDO)

**Los drivers SQL Server requieren Visual C++ Redistributable:**

1. **Descargar Visual C++ 2019 Redistributable:**
   - **x64:** https://aka.ms/vs/17/release/vc_redist.x64.exe
   - **x86:** https://aka.ms/vs/17/release/vc_redist.x86.exe

2. **Ejecutar el instalador**
3. **Reiniciar** el servidor (Apache/XAMPP)

**⚠️ IMPORTANTE:** Sin esto, los drivers NO funcionarán.

### Paso 4: Extraer y Copiar Drivers

1. **Descomprimir** el ZIP descargado
2. **Buscar estos archivos:**
   - `php_sqlsrv_82_ts_x64.dll`
   - `php_pdo_sqlsrv_82_ts_x64.dll`

3. **Copiar a carpeta de extensiones PHP:**
   ```powershell
   # Verificar carpeta de extensiones
   php -i | findstr "extension_dir"
   # Ejemplo: C:\xampp\php\ext
   ```

4. **Copiar y renombrar:**
   - `php_sqlsrv_82_ts_x64.dll` → Copiar a `C:\xampp\php\ext\php_sqlsrv.dll`
   - `php_pdo_sqlsrv_82_ts_x64.dll` → Copiar a `C:\xampp\php\ext\php_pdo_sqlsrv.dll`

   **⚠️ IMPORTANTE:** Renombrar sin el número de versión.

### Paso 5: Verificar php.ini

**Encontrar php.ini:**
```powershell
php --ini
```

**Editar php.ini y verificar:**
```ini
; SQL Server Drivers
extension=php_sqlsrv.dll
extension=php_pdo_sqlsrv.dll
```

**⚠️ IMPORTANTE:**
- No debe tener números de versión: `extension=php_sqlsrv_82_ts_x64.dll` ❌
- Debe ser: `extension=php_sqlsrv.dll` ✅

### Paso 6: Verificar que los Archivos Existen

```powershell
# Verificar que los archivos existen
dir C:\xampp\php\ext\php_sqlsrv.dll
dir C:\xampp\php\ext\php_pdo_sqlsrv.dll
```

**Si no existen, copiarlos de nuevo.**

### Paso 7: Reiniciar Servidor

**Si usas XAMPP:**
1. Abrir Panel de Control de XAMPP
2. Detener Apache
3. Iniciar Apache

**O desde PowerShell:**
```powershell
# Detener Apache
Stop-Service Apache2.4

# Iniciar Apache
Start-Service Apache2.4
```

### Paso 8: Verificar Instalación

```powershell
php -m | findstr sqlsrv
```

**Debe mostrar:**
```
pdo_sqlsrv
sqlsrv
```

**Si sigue dando error, verificar:**

1. **Arquitectura correcta:**
   ```powershell
   php -i | findstr "Architecture"
   # Debe coincidir: x64 con x64, x86 con x86
   ```

2. **Thread Safety correcto:**
   ```powershell
   php -i | findstr "Thread Safety"
   # Debe ser: enabled (TS) o disabled (NTS)
   # Y usar drivers correspondientes
   ```

---

## 🔍 Tabla de Compatibilidad

| PHP Versión | Thread Safety | Arquitectura | Driver Necesario |
|------------|---------------|--------------|-----------------|
| 8.2 | TS | x64 | `php_sqlsrv_82_ts_x64.dll` |
| 8.2 | TS | x86 | `php_sqlsrv_82_ts_x86.dll` |
| 8.2 | NTS | x64 | `php_sqlsrv_82_nts_x64.dll` |
| 8.2 | NTS | x86 | `php_sqlsrv_82_nts_x86.dll` |
| 8.1 | TS | x64 | `php_sqlsrv_81_ts_x64.dll` |
| 8.0 | TS | x64 | `php_sqlsrv_80_ts_x64.dll` |

---

## 🚨 Solución de Problemas

### Error: "%1 no es una aplicación Win32 válida"

**Causas:**
1. DLL de arquitectura incorrecta (x86 vs x64)
2. DLL de versión incorrecta de PHP
3. DLL de Thread Safety incorrecto
4. Falta Visual C++ Redistributable

**Solución:**
1. Verificar versión exacta de PHP
2. Descargar drivers correctos
3. Instalar Visual C++ Redistributable
4. Reiniciar servidor

### Error: "No se puede encontrar el módulo especificado"

**Causa:** Falta Visual C++ Redistributable o dependencias.

**Solución:**
1. Instalar Visual C++ 2019 Redistributable
2. Reiniciar servidor

### Error: "The specified procedure could not be found"

**Causa:** Versión del driver incompatible con PHP.

**Solución:**
1. Descargar drivers específicos para tu versión de PHP
2. Verificar compatibilidad

---

## 📋 Checklist Rápido

- [ ] Identificada versión exacta de PHP (8.2.x)
- [ ] Identificado Thread Safety (TS o NTS)
- [ ] Identificada arquitectura (x64 o x86)
- [ ] Descargados drivers correctos
- [ ] Instalado Visual C++ 2019 Redistributable
- [ ] Drivers copiados a carpeta `ext`
- [ ] Drivers renombrados (sin números de versión)
- [ ] Extensiones agregadas en `php.ini`
- [ ] Servidor reiniciado
- [ ] Verificado con `php -m`

---

## 🎯 Comandos de Verificación

```powershell
# 1. Ver versión de PHP
php -v

# 2. Ver arquitectura
php -i | findstr "Architecture"

# 3. Ver Thread Safety
php -i | findstr "Thread Safety"

# 4. Ver carpeta de extensiones
php -i | findstr "extension_dir"

# 5. Verificar drivers cargados
php -m | findstr sqlsrv

# 6. Verificar archivos DLL
dir C:\xampp\php\ext\php_sqlsrv*.dll
```

---

## ✅ Solución Rápida (Resumen)

1. **Verificar PHP:** `php -v` → Anotar versión, TS/NTS, x64/x86
2. **Descargar drivers correctos** para tu versión exacta
3. **Instalar Visual C++ 2019 Redistributable** (x64)
4. **Copiar DLLs** a `C:\xampp\php\ext\`
5. **Renombrar** sin números: `php_sqlsrv.dll`, `php_pdo_sqlsrv.dll`
6. **Agregar en php.ini:** `extension=php_sqlsrv.dll`
7. **Reiniciar Apache/XAMPP**
8. **Verificar:** `php -m | findstr sqlsrv`

---

## 🔗 Enlaces Directos

- **Drivers SQL Server:** https://github.com/Microsoft/msphpsql/releases/latest
- **Visual C++ 2019 Redistributable x64:** https://aka.ms/vs/17/release/vc_redist.x64.exe
- **Visual C++ 2019 Redistributable x86:** https://aka.ms/vs/17/release/vc_redist.x86.exe

---

**✅ Después de seguir estos pasos, el error del DLL debería desaparecer.**


