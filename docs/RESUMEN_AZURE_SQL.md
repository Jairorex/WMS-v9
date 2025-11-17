# ⚡ Resumen Rápido: Crear Azure SQL Database

## 🎯 Pasos Esenciales

### 1. Ir a Azure Portal
- https://portal.azure.com
- Iniciar sesión

### 2. Crear SQL Database
- "Create a resource" → "SQL Database"
- Configurar:
  - **Resource Group:** Crear nuevo
  - **Database name:** `wms`
  - **Server:** Crear nuevo
    - **Server name:** `wms-escasan-server` (único)
    - **Admin:** `wmsadmin`
    - **Password:** (anotar)
  - **Compute:** Basic o Serverless

### 3. Configurar Redes (IMPORTANTE)
- **Networking** → **Public endpoint**
- **Firewall:**
  - ✅ **Allow Azure services:** YES
  - ✅ **Add current client IP:** YES

### 4. Crear
- "Review + create" → "Create"
- Esperar 2-5 minutos

### 5. Obtener Información
- **DB_HOST:** `wms-escasan-server.database.windows.net`
- **DB_USERNAME:** `wmsadmin@wms-escasan-server`
- **DB_PASSWORD:** (la que configuraste)
- **DB_DATABASE:** `wms`

### 6. Configurar en Railway
```env
DB_HOST=wms-escasan-server.database.windows.net
DB_USERNAME=wmsadmin@wms-escasan-server
DB_PASSWORD=tu-password
DB_DATABASE=wms
DB_PORT=1433
```

---

## 💰 Costo
- **Basic:** ~$5/mes
- **12 meses gratis** para nuevos usuarios

---

**Ver `CREAR_AZURE_SQL_DATABASE.md` para guía completa detallada.**


