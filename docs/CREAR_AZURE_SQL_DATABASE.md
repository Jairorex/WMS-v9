# 🗄️ Guía: Crear Base de Datos SQL Server en Azure

## 📋 Pre-requisitos

- Cuenta de Microsoft Azure (puedes crear una gratis)
- Tarjeta de crédito (para verificación, pero hay tier gratuito)

---

## 🚀 Paso a Paso: Crear Azure SQL Database

### Paso 1: Acceder a Azure Portal

1. **Ir a:** https://portal.azure.com
2. **Iniciar sesión** con tu cuenta Microsoft
3. Si no tienes cuenta, crear una (tiene tier gratuito con $200 de crédito)

### Paso 2: Crear SQL Database

1. **En Azure Portal:**
   - Click en **"Create a resource"** (Crear un recurso) - botón verde en la esquina superior izquierda
   - O buscar en la barra superior: **"SQL Database"**

2. **Seleccionar "SQL Database":**
   - Aparecerá un formulario de configuración

### Paso 3: Configurar la Base de Datos

#### Pestaña "Basics" (Básicos)

1. **Subscription (Suscripción):**
   - Seleccionar tu suscripción
   - Si no tienes, crear una (gratis)

2. **Resource Group (Grupo de recursos):**
   - Click en **"Create new"**
   - Nombre: `wms-escasan-rg` (o el que prefieras)
   - Click **"OK"**

3. **Database name (Nombre de la base de datos):**
   - Nombre: `wms`
   - O el nombre que prefieras

4. **Server (Servidor):**
   - Click en **"Create new"** (Crear nuevo)
   - Se abrirá un formulario:

   **Configuración del Servidor:**
   - **Server name:** `wms-escasan-server` (debe ser único globalmente)
   - **Location:** Seleccionar la región más cercana (ej: `East US`, `West Europe`)
   - **Authentication method:** `Use SQL authentication`
   - **Server admin login:** `wmsadmin` (o el nombre que prefieras)
   - **Password:** Crear una contraseña segura (anotarla, la necesitarás)
   - **Confirm password:** Repetir la contraseña
   - Click **"OK"**

5. **Want to use SQL elastic pool? (¿Usar grupo elástico SQL?):**
   - Seleccionar **"No"**

6. **Compute + storage (Computación y almacenamiento):**
   - Click en **"Configure database"**
   - Seleccionar **"Basic"** o **"Serverless"** (más económico)
   - Para desarrollo/pruebas: **"Basic"** ($5/mes aprox)
   - Para producción: **"S0"** o superior
   - Click **"Apply"**

7. **Backup storage redundancy (Redundancia de almacenamiento de respaldo):**
   - Dejar por defecto: **"Geo-redundant backup storage"**

8. **Click en "Next: Networking"** (Siguiente: Redes)

### Paso 4: Configurar Redes (IMPORTANTE)

#### Pestaña "Networking"

1. **Network connectivity (Conectividad de red):**
   - Seleccionar **"Public endpoint"** (Punto de conexión público)

2. **Firewall rules (Reglas de firewall):**
   - **Allow Azure services and resources to access this server:**
     - ✅ **Marcar "Yes"** (SÍ) - Esto permite que Railway se conecte
   
   - **Add current client IP address:**
     - ✅ **Marcar** - Esto permite que te conectes desde tu máquina
   
   - **Add firewall rule:**
     - Puedes agregar IPs específicas si lo necesitas
     - Por ahora, con las dos opciones anteriores es suficiente

3. **Click en "Next: Security"** (Siguiente: Seguridad)

### Paso 5: Configurar Seguridad

#### Pestaña "Security"

1. **Microsoft Defender for SQL:**
   - Puedes dejarlo deshabilitado por ahora (se puede habilitar después)
   - O habilitarlo si quieres protección adicional

2. **Click en "Next: Additional settings"** (Siguiente: Configuración adicional)

### Paso 6: Configuración Adicional

#### Pestaña "Additional settings"

1. **Data source (Fuente de datos):**
   - Seleccionar **"None"** (Ninguna) - Crear base de datos vacía

2. **Database collation (Intercalación de base de datos):**
   - Dejar por defecto: `SQL_Latin1_General_CP1_CI_AS`

3. **Click en "Review + create"** (Revisar y crear)

### Paso 7: Revisar y Crear

1. **Azure validará** la configuración
2. **Revisar** todos los detalles
3. **Click en "Create"** (Crear)
4. **Esperar** a que se cree (2-5 minutos)
5. Verás una notificación: **"Your deployment is complete"**

---

## 📝 Obtener Información de Conexión

### Paso 8: Obtener URL del Servidor

1. **En Azure Portal:**
   - Click en **"Go to resource"** (Ir al recurso)
   - O buscar en "All resources" (Todos los recursos)

2. **En la página de la base de datos:**
   - En la sección **"Essentials"** (Información esencial)
   - Buscar **"Server name"**
   - Copiar el nombre completo (ej: `wms-escasan-server.database.windows.net`)
   - **Esta es tu `DB_HOST`**

### Paso 9: Obtener Credenciales

1. **Server admin login:**
   - Es el que configuraste (ej: `wmsadmin`)
   - **Esta es tu `DB_USERNAME`**

2. **Password:**
   - Es la que configuraste al crear el servidor
   - **Esta es tu `DB_PASSWORD`**

3. **Formato completo del usuario:**
   - Para Azure SQL, el formato es: `usuario@servidor`
   - Ejemplo: `wmsadmin@wms-escasan-server`
   - **Este es el valor completo para `DB_USERNAME`**

---

## ⚙️ Configurar Variables en Railway

### Paso 10: Actualizar Variables en Railway

1. **En Railway:**
   - Ve a tu proyecto
   - Click en el servicio (backend)
   - Ve a la pestaña **"Variables"**

2. **Actualizar las siguientes variables:**

```env
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=wmsadmin@wms-escasan-server
DB_PASSWORD=tu-password-aqui
```

**⚠️ IMPORTANTE:**
- Reemplazar `wms-escasan-server.database.windows.net` con tu servidor real
- Reemplazar `wmsadmin@wms-escasan-server` con tu usuario@servidor
- Reemplazar `tu-password-aqui` con tu contraseña real

3. **Guardar** - Railway reiniciará automáticamente

---

## 🔒 Configurar Firewall Adicional (Si es Necesario)

### Si Railway no puede conectarse:

1. **En Azure Portal:**
   - Ir a tu **SQL Server** (no la base de datos)
   - En el menú izquierdo, buscar **"Networking"** (Redes)
   - O buscar **"Firewall rules"** (Reglas de firewall)

2. **Agregar regla para Railway:**
   - Click en **"Add client IP"** (Agregar IP de cliente)
   - O agregar manualmente:
     - **Rule name:** `Railway`
     - **Start IP address:** `0.0.0.0`
     - **End IP address:** `255.255.255.255`
     - ⚠️ **Nota:** Esto permite todas las IPs (solo para desarrollo)
   
   - **Para producción:**
     - Obtener la IP de Railway (puede variar)
     - O usar **"Allow Azure services"** que ya está habilitado

3. **Click en "Save"** (Guardar)

---

## ✅ Verificar Conexión

### Paso 11: Probar Conexión

1. **En Railway:**
   - Ve a **"Deployments"** → **"View Logs"**
   - Buscar errores de conexión
   - Si no hay errores, la conexión está funcionando

2. **Probar desde tu máquina (opcional):**
   - Puedes usar Azure Data Studio o SQL Server Management Studio
   - Conectar con:
     - **Server:** `wms-escasan-server.database.windows.net`
     - **Authentication:** SQL Server Authentication
     - **Login:** `wmsadmin@wms-escasan-server`
     - **Password:** Tu contraseña

---

## 💰 Costos

### Tier Básico (Recomendado para empezar)

- **Basic:** ~$5 USD/mes
- **S0:** ~$15 USD/mes
- **Serverless:** Pago por uso (muy económico para desarrollo)

### Tier Gratuito

- Azure ofrece **12 meses gratis** para nuevos usuarios
- Incluye $200 de crédito
- Puedes usar tier básico sin costo durante el período de prueba

---

## 📋 Resumen de Información Necesaria

Después de crear la base de datos, necesitas:

1. **DB_HOST:** `tu-servidor.database.windows.net`
2. **DB_USERNAME:** `tu-usuario@tu-servidor`
3. **DB_PASSWORD:** `tu-password`
4. **DB_DATABASE:** `wms` (o el nombre que elegiste)
5. **DB_PORT:** `1433`

---

## 🆘 Troubleshooting

### Error: "Server name already exists"

**Solución:** El nombre del servidor debe ser único globalmente. Prueba con otro nombre:
- `wms-escasan-server-123`
- `wms-escasan-2024`
- Agregar números o caracteres únicos

### Error: "Cannot connect to server"

**Solución:**
1. Verificar que "Allow Azure services" esté habilitado
2. Verificar reglas de firewall
3. Verificar credenciales

### Error: "Login failed for user"

**Solución:**
1. Verificar formato del usuario: `usuario@servidor`
2. Verificar contraseña
3. Verificar que el usuario tenga permisos

---

## ✅ Checklist

- [ ] Cuenta de Azure creada
- [ ] SQL Server creado en Azure
- [ ] Base de datos creada
- [ ] Firewall configurado (Allow Azure services = Yes)
- [ ] URL del servidor anotada
- [ ] Credenciales anotadas
- [ ] Variables actualizadas en Railway
- [ ] Railway reiniciado
- [ ] Conexión verificada (sin errores en logs)

---

## 🎯 Siguiente Paso

Una vez que tengas la base de datos creada y las variables configuradas en Railway:

1. **Verificar logs** en Railway
2. **Probar el backend** directamente
3. **Continuar con el despliegue del frontend** en Vercel

---

**¿Necesitas ayuda con algún paso específico? Dime en qué paso estás y te guío.**


