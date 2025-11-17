# ⚠️ Corrección de Variables de Entorno en Railway

## 🔴 Problemas Detectados

### 1. `DB_HOST=localhost` ❌

**Problema:** `localhost` en Railway se refiere al contenedor mismo, no a tu servidor SQL Server.

**Solución:** Necesitas la URL/IP real de tu servidor SQL Server.

### 2. `DB_USERNAME` y `DB_PASSWORD` vacíos ❌

**Problema:** Sin credenciales, no podrás conectarte a la base de datos.

**Solución:** Necesitas agregar tus credenciales reales.

---

## ✅ Variables Correctas

### Opción 1: Si tienes SQL Server en Azure

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=
DB_CONNECTION=sqlsrv
DB_HOST=tu-servidor.database.windows.net
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=tu-usuario@tu-servidor
DB_PASSWORD=tu-password-seguro
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

### Opción 2: Si tienes SQL Server en otro servidor (VPS, etc.)

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=
DB_CONNECTION=sqlsrv
DB_HOST=tu-ip-o-dominio.com
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=sa
DB_PASSWORD=tu-password-seguro
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

### Opción 3: Si NO tienes SQL Server accesible desde internet

Necesitas crear uno. Opciones:

1. **Azure SQL Database** (Recomendado)
   - Crear en: https://portal.azure.com
   - Obtener la URL de conexión
   - Configurar firewall para permitir Railway

2. **SQL Server en un VPS**
   - Configurar SQL Server para aceptar conexiones remotas
   - Abrir puerto 1433 en el firewall
   - Obtener la IP pública

---

## 📝 Pasos para Corregir

### 1. Obtener Información de tu SQL Server

**Si tienes SQL Server local:**
- Necesitas hacerlo accesible desde internet
- O usar Azure SQL Database
- O usar un túnel (ngrok, etc.) - NO recomendado para producción

**Si tienes SQL Server en Azure:**
- Ve a Azure Portal
- Busca tu SQL Server
- Copia la URL del servidor (ej: `wms-server.database.windows.net`)
- Copia el usuario y contraseña

**Si NO tienes SQL Server:**
- Crea uno en Azure SQL Database
- O configura uno en un VPS

### 2. Actualizar Variables en Railway

1. **En Railway:**
   - Ve a tu proyecto
   - Click en el servicio (backend)
   - Ve a la pestaña **"Variables"**

2. **Actualizar las siguientes variables:**

   - **`DB_HOST`:** 
     - ❌ `localhost` 
     - ✅ `tu-servidor.database.windows.net` (Azure)
     - ✅ `tu-ip-o-dominio.com` (VPS)
   
   - **`DB_USERNAME`:** 
     - ❌ (vacío)
     - ✅ `tu-usuario@tu-servidor` (Azure)
     - ✅ `sa` o tu usuario (VPS)
   
   - **`DB_PASSWORD`:** 
     - ❌ (vacío)
     - ✅ Tu contraseña real

3. **Agregar `DB_PORT` si no está:**
   ```
   DB_PORT=1433
   ```

### 3. Verificar Configuración

Después de actualizar, Railway reiniciará automáticamente. Verifica:

1. **Logs:**
   - Ve a "Deployments" → "View Logs"
   - Busca errores de conexión a la base de datos
   - Si ves "Database connection failed", verifica las credenciales

2. **Conexión:**
   - Si todo está bien, deberías ver el servidor corriendo sin errores

---

## 🔍 Cómo Obtener la Información Correcta

### Si usas Azure SQL Database:

1. **Ir a Azure Portal:** https://portal.azure.com
2. **Buscar "SQL databases"** o "SQL servers"
3. **Click en tu servidor SQL**
4. **En "Overview":**
   - **Server name:** Es tu `DB_HOST` (ej: `wms-server.database.windows.net`)
   - **Admin username:** Es parte de tu `DB_USERNAME` (ej: `admin@wms-server`)
5. **Para contraseña:**
   - Si no la recuerdas, puedes resetearla en "Reset password"
6. **Configurar firewall:**
   - Ve a "Networking" o "Firewall rules"
   - Agregar regla para permitir conexiones desde Railway
   - O habilitar "Allow Azure services and resources to access this server"

### Si usas SQL Server local/VPS:

1. **Obtener IP pública:**
   - Si es VPS, usa la IP pública del servidor
   - Si es local, necesitas hacer port forwarding o usar un túnel

2. **Configurar SQL Server:**
   - Habilitar TCP/IP en SQL Server Configuration Manager
   - Abrir puerto 1433 en el firewall
   - Configurar autenticación SQL Server

3. **Probar conexión:**
   - Desde tu máquina local, prueba conectarte con la IP pública
   - Si funciona, Railway también podrá conectarse

---

## 🆘 Si NO Tienes SQL Server Accesible

### Opción 1: Crear Azure SQL Database (Recomendado)

1. **Ir a:** https://portal.azure.com
2. **Crear recurso** → Buscar "SQL Database"
3. **Configurar:**
   - Resource group: Crear nuevo o usar existente
   - Database name: `wms`
   - Server: Crear nuevo servidor
   - Authentication: SQL authentication
   - Username y password: Anotar estos valores
4. **Después de crear:**
   - Ir a "Networking"
   - Habilitar "Allow Azure services and resources to access this server"
   - O agregar regla de firewall para Railway
5. **Obtener URL:**
   - En "Overview", copiar el "Server name"
   - Usar como `DB_HOST`

### Opción 2: Usar Railway PostgreSQL (Alternativa)

Si prefieres no usar SQL Server, puedes cambiar a PostgreSQL:

1. **En Railway:**
   - Crear nuevo servicio → "Database" → "PostgreSQL"
   - Railway generará las variables automáticamente

2. **Actualizar variables:**
   ```env
   DB_CONNECTION=pgsql
   DB_HOST=${{Postgres.PGHOST}}
   DB_PORT=${{Postgres.PGPORT}}
   DB_DATABASE=${{Postgres.PGDATABASE}}
   DB_USERNAME=${{Postgres.PGUSER}}
   DB_PASSWORD=${{Postgres.PGPASSWORD}}
   ```

**⚠️ Nota:** Esto requeriría cambiar el backend de SQL Server a PostgreSQL, lo cual implica cambios en el código.

---

## ✅ Checklist

- [ ] `DB_HOST` actualizado (NO `localhost`)
- [ ] `DB_USERNAME` configurado
- [ ] `DB_PASSWORD` configurado
- [ ] `DB_PORT=1433` agregado
- [ ] SQL Server accesible desde internet
- [ ] Firewall configurado (si es necesario)
- [ ] Railway reiniciado
- [ ] Logs sin errores de conexión

---

## 📞 ¿Qué Información Necesitas?

Para ayudarte mejor, dime:

1. **¿Tienes SQL Server en Azure?** → Te ayudo a obtener la URL
2. **¿Tienes SQL Server en un VPS?** → Te ayudo a configurarlo
3. **¿NO tienes SQL Server accesible?** → Te ayudo a crear uno en Azure

**Dime tu situación y te guío paso a paso.**

