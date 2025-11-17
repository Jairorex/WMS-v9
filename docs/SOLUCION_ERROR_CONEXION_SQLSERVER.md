# 🔧 Solución: Error de Conexión a SQL Server

## 🔴 Error

```
SQLSTATE[08001]: [Microsoft][ODBC Driver 17 for SQL Server]
Proveedor de TCP: No se puede establecer una conexión ya que el equipo 
de destino denegó expresamente dicha conexión.
```

**Significado:** PHP puede encontrar los drivers, pero no puede conectarse al servidor SQL Server.

---

## ✅ Solución Paso a Paso

### Paso 1: Verificar que SQL Server está Corriendo

**Windows:**
```powershell
# Verificar servicio SQL Server
Get-Service | Where-Object {$_.Name -like "*SQL*"}

# Debe mostrar servicios como:
# MSSQLSERVER (Running)
# SQLSERVERAGENT (Running)
```

**O desde Servicios:**
1. Presiona `Win + R`
2. Escribe `services.msc`
3. Busca "SQL Server (MSSQLSERVER)"
4. Debe estar en estado "En ejecución"

**Si NO está corriendo:**
```powershell
# Iniciar servicio
Start-Service MSSQLSERVER
```

### Paso 2: Verificar Configuración en `.env`

**Abrir `backend/.env` y verificar:**

```env
DB_CONNECTION=sqlsrv
DB_HOST=localhost        # ← Verificar este valor
DB_PORT=1433            # ← Verificar este puerto
DB_DATABASE=wms_escasan
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password
```

**Valores comunes para DB_HOST:**
- `localhost` - Si SQL Server está en la misma máquina
- `127.0.0.1` - Alternativa a localhost
- `.\SQLEXPRESS` - Si es SQL Server Express con instancia nombrada
- `TU_PC\SQLEXPRESS` - Nombre de instancia específica
- `192.168.1.100` - Si es servidor remoto

### Paso 3: Verificar que SQL Server Acepta Conexiones TCP/IP

**Abrir SQL Server Configuration Manager:**

1. Presiona `Win + R`
2. Escribe `SQLServerManager*.msc` (reemplaza * con tu versión)
3. O buscar en menú inicio: "SQL Server Configuration Manager"

**Configurar TCP/IP:**

1. Expande "SQL Server Network Configuration"
2. Click en "Protocols for MSSQLSERVER" (o tu instancia)
3. Click derecho en "TCP/IP" → "Enable"
4. Click derecho en "TCP/IP" → "Properties"
5. Ir a pestaña "IP Addresses"
6. Scroll hasta "IPAll"
7. Verificar:
   - **TCP Dynamic Ports:** (puede estar vacío o tener un número)
   - **TCP Port:** `1433` (o el puerto que quieras usar)
8. Click "OK"
9. **Reiniciar servicio SQL Server**

**Reiniciar SQL Server:**
```powershell
Restart-Service MSSQLSERVER
```

### Paso 4: Verificar Firewall

**Permitir puerto 1433 en Firewall:**

```powershell
# Permitir SQL Server en firewall
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
```

**O desde Firewall de Windows:**
1. Abrir "Firewall de Windows"
2. "Configuración avanzada"
3. "Reglas de entrada"
4. "Nueva regla"
5. Puerto → TCP → 1433
6. Permitir conexión
7. Aplicar a todos los perfiles

### Paso 5: Verificar Autenticación SQL Server

**Abrir SQL Server Management Studio (SSMS):**

1. Conectar a `localhost` o `.\SQLEXPRESS`
2. Click derecho en servidor → "Properties"
3. Ir a "Security"
4. Verificar que esté habilitado:
   - **"SQL Server and Windows Authentication mode"**

**Si solo está "Windows Authentication":**
- Cambiar a "SQL Server and Windows Authentication mode"
- Click "OK"
- **Reiniciar SQL Server**

### Paso 6: Crear Usuario SQL (si no existe)

**En SSMS, ejecutar:**

```sql
-- Crear login
CREATE LOGIN wms_user WITH PASSWORD = 'TuPasswordSeguro123!';

-- Usar base de datos
USE wms_escasan;
GO

-- Crear usuario
CREATE USER wms_user FOR LOGIN wms_user;
GO

-- Dar permisos
ALTER ROLE db_owner ADD MEMBER wms_user;
GO
```

**Actualizar `.env`:**
```env
DB_USERNAME=wms_user
DB_PASSWORD=TuPasswordSeguro123!
```

### Paso 7: Verificar Conexión desde PHP

**Probar conexión:**

```powershell
cd backend
php artisan tinker
```

Luego ejecuta:
```php
try {
    $pdo = DB::connection()->getPdo();
    echo "✅ Conexión exitosa!";
    echo "\nBase de datos: " . DB::connection()->getDatabaseName();
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage();
}
```

### Paso 8: Verificar Instancia de SQL Server

**Si usas SQL Server Express con instancia nombrada:**

```env
# En lugar de:
DB_HOST=localhost

# Usar:
DB_HOST=localhost\SQLEXPRESS
# O
DB_HOST=.\SQLEXPRESS
# O
DB_HOST=TU_PC\SQLEXPRESS
```

**Para encontrar el nombre de tu instancia:**

```powershell
# Ver todas las instancias de SQL Server
Get-Service | Where-Object {$_.Name -like "*SQL*"} | Select-Object Name, DisplayName
```

---

## 🔍 Diagnóstico Avanzado

### Verificar Puerto SQL Server

```powershell
# Ver qué puerto está usando SQL Server
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\*\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" | Select-Object TcpPort, TcpDynamicPorts
```

### Probar Conexión con sqlcmd

```powershell
# Instalar sqlcmd si no lo tienes
# O usar desde SSMS

# Probar conexión
sqlcmd -S localhost -U tu_usuario -P tu_password -Q "SELECT @@VERSION"
```

**Si funciona:** El problema está en la configuración de Laravel.
**Si NO funciona:** El problema está en SQL Server.

### Verificar Logs de SQL Server

**Ubicación de logs:**
```
C:\Program Files\Microsoft SQL Server\MSSQL*.MSSQLSERVER\MSSQL\Log\ERRORLOG
```

**Buscar errores relacionados con conexiones TCP/IP.**

---

## 🚨 Soluciones por Escenario

### Escenario 1: SQL Server Express Local

**Configuración `.env`:**
```env
DB_HOST=localhost\SQLEXPRESS
DB_PORT=1433
```

**O si el puerto es dinámico:**
```env
DB_HOST=localhost\SQLEXPRESS
DB_PORT=  # Dejar vacío
```

### Escenario 2: SQL Server en Servidor Remoto

**Configuración `.env`:**
```env
DB_HOST=192.168.1.100
DB_PORT=1433
DB_USERNAME=usuario
DB_PASSWORD=password
```

**Verificar:**
1. SQL Server permite conexiones remotas
2. Firewall permite puerto 1433
3. SQL Server Browser está corriendo (si es necesario)

### Escenario 3: Azure SQL Database

**Configuración `.env`:**
```env
DB_HOST=tu-servidor.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=usuario@tu-servidor
DB_PASSWORD=password
```

**Verificar:**
1. Firewall de Azure permite tu IP
2. Credenciales son correctas

---

## 📋 Checklist de Diagnóstico

- [ ] SQL Server está corriendo (verificar servicios)
- [ ] TCP/IP está habilitado en SQL Server Configuration Manager
- [ ] Puerto 1433 está configurado y abierto
- [ ] Firewall permite conexiones en puerto 1433
- [ ] Autenticación SQL está habilitada
- [ ] Usuario y contraseña son correctos en `.env`
- [ ] `DB_HOST` es correcto (localhost, localhost\SQLEXPRESS, IP, etc.)
- [ ] `DB_PORT` es correcto (1433 o el puerto configurado)
- [ ] Base de datos `wms_escasan` existe
- [ ] Usuario tiene permisos en la base de datos

---

## 🎯 Comandos Rápidos de Verificación

```powershell
# 1. Verificar servicios SQL Server
Get-Service | Where-Object {$_.Name -like "*SQL*"}

# 2. Verificar puerto
netstat -an | findstr 1433

# 3. Probar conexión desde PHP
cd backend
php artisan tinker
# Luego: DB::connection()->getPdo();

# 4. Verificar configuración actual
php artisan config:show database.connections.sqlsrv
```

---

## ✅ Solución Rápida (Resumen)

1. **Verificar SQL Server está corriendo**
2. **Habilitar TCP/IP en SQL Server Configuration Manager**
3. **Configurar puerto 1433 (o el que uses)**
4. **Reiniciar SQL Server**
5. **Permitir puerto en Firewall**
6. **Verificar `.env` tiene configuración correcta**
7. **Probar conexión con `php artisan tinker`**

---

**Si el problema persiste después de estos pasos, el error puede estar en:**
- Credenciales incorrectas
- Base de datos no existe
- Usuario no tiene permisos
- SQL Server no acepta conexiones remotas (si es remoto)

