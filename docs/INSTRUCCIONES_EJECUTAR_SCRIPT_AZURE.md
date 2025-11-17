# 📋 Instrucciones: Ejecutar Script SQL en Azure SQL Database

## 🎯 Objetivo
Ejecutar el script `SCRIPT_AZURE_SQL_DATABASE.sql` en tu base de datos de Azure SQL para replicar toda la estructura.

---

## 🔧 Método 1: Azure Portal (Query Editor)

### Paso 1: Acceder a Query Editor
1. **Ir a Azure Portal:** https://portal.azure.com
2. **Buscar tu SQL Database** en "All resources"
3. **Click en tu base de datos**
4. **En el menú izquierdo**, buscar **"Query editor (preview)"**
5. **Iniciar sesión** con:
   - **Server admin login:** Tu usuario (ej: `wmsadmin`)
   - **Password:** Tu contraseña

### Paso 2: Ejecutar el Script
1. **Abrir el archivo** `SCRIPT_AZURE_SQL_DATABASE.sql` en tu editor de texto
2. **Copiar todo el contenido** (Ctrl+A, Ctrl+C)
3. **Pegar en el Query Editor** de Azure
4. **Click en "Run"** (Ejecutar)
5. **Esperar** a que termine (puede tardar 1-2 minutos)
6. **Verificar** que no haya errores

### Paso 3: Verificar Resultado
- Deberías ver mensajes como:
  - `✅ Tabla wms.roles creada`
  - `✅ Tabla wms.usuarios creada`
  - `✅ Datos iniciales insertados`
  - `✅ BASE DE DATOS WMS ESCASAN CREADA EXITOSAMENTE`

---

## 🔧 Método 2: Azure Data Studio (Recomendado)

### Paso 1: Instalar Azure Data Studio
1. **Descargar:** https://aka.ms/azuredatastudio
2. **Instalar** la aplicación

### Paso 2: Conectar a Azure SQL
1. **Abrir Azure Data Studio**
2. **Click en "New Connection"** (Nueva conexión)
3. **Configurar:**
   - **Server:** `tu-servidor.database.windows.net`
   - **Authentication type:** SQL Login
   - **User name:** `wmsadmin@tu-servidor`
   - **Password:** Tu contraseña
   - **Database:** `wms` (o el nombre de tu base de datos)
   - **Encrypt:** True
4. **Click en "Connect"**

### Paso 3: Ejecutar el Script
1. **Abrir el archivo** `SCRIPT_AZURE_SQL_DATABASE.sql`
2. **Click derecho** en el editor → **"Run"** o presionar **F5**
3. **Esperar** a que termine
4. **Verificar** resultados en la pestaña "Messages"

---

## 🔧 Método 3: SQL Server Management Studio (SSMS)

### Paso 1: Instalar SSMS
1. **Descargar:** https://aka.ms/ssmsfullsetup
2. **Instalar** la aplicación

### Paso 2: Conectar a Azure SQL
1. **Abrir SSMS**
2. **En "Connect to Server":**
   - **Server name:** `tu-servidor.database.windows.net`
   - **Authentication:** SQL Server Authentication
   - **Login:** `wmsadmin@tu-servidor`
   - **Password:** Tu contraseña
3. **Click en "Options"** → **"Connection Properties"**
   - **Connect to database:** Seleccionar tu base de datos (`wms`)
4. **Click en "Connect"**

### Paso 3: Ejecutar el Script
1. **Abrir el archivo** `SCRIPT_AZURE_SQL_DATABASE.sql`
2. **Verificar** que estés conectado a la base de datos correcta
3. **Click en "Execute"** (F5)
4. **Esperar** a que termine
5. **Verificar** resultados en "Messages"

---

## 🔧 Método 4: Azure CLI (Línea de Comandos)

### Paso 1: Instalar Azure CLI
1. **Descargar:** https://aka.ms/installazurecliwindows
2. **Instalar** y reiniciar terminal

### Paso 2: Conectar y Ejecutar
```bash
# Iniciar sesión en Azure
az login

# Ejecutar script SQL
az sql db execute \
  --resource-group wms-escasan-rg \
  --server tu-servidor \
  --database wms \
  --file-path SCRIPT_AZURE_SQL_DATABASE.sql
```

---

## ⚠️ Notas Importantes

### 1. Conexión Directa
- **El script NO crea la base de datos** (ya debe existir)
- **Debes conectarte directamente a tu base de datos** antes de ejecutar

### 2. Permisos
- Necesitas permisos de **db_owner** o **db_ddladmin**
- El usuario administrador del servidor tiene estos permisos por defecto

### 3. Ejecución Segura
- El script usa `IF NOT EXISTS` para evitar errores si las tablas ya existen
- Puedes ejecutarlo múltiples veces sin problemas
- Solo creará lo que no existe

### 4. Tiempo de Ejecución
- **Tiempo estimado:** 1-3 minutos
- Depende del tier de Azure SQL que tengas

---

## ✅ Verificación Post-Ejecución

### Verificar Tablas Creadas
```sql
-- Ver todas las tablas del esquema wms
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'wms'
ORDER BY TABLE_NAME;

-- Deberías ver 18 tablas:
-- roles, usuarios, estados_producto, productos, ubicaciones,
-- inventario, tipos_tarea, estados_tarea, tareas, tarea_usuario,
-- tarea_detalle, tareas_log, incidencias, notificaciones,
-- picking, picking_det, orden_salida, orden_salida_det
```

### Verificar Datos Iniciales
```sql
-- Verificar roles
SELECT * FROM wms.roles;

-- Verificar usuario admin
SELECT id_usuario, nombre, usuario, email FROM wms.usuarios WHERE usuario = 'admin';

-- Verificar tipos de tareas
SELECT * FROM wms.tipos_tarea;

-- Verificar estados de tareas
SELECT * FROM wms.estados_tarea;
```

### Verificar Tablas de Laravel
```sql
-- Ver tablas de Laravel
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME IN ('sessions', 'migrations', 'password_reset_tokens', 'personal_access_tokens')
ORDER BY TABLE_NAME;
```

---

## 🆘 Troubleshooting

### Error: "Cannot open database"
**Solución:** Asegúrate de estar conectado a la base de datos correcta antes de ejecutar el script.

### Error: "Permission denied"
**Solución:** Usa el usuario administrador del servidor o un usuario con permisos `db_owner`.

### Error: "Table already exists"
**Solución:** Esto es normal. El script usa `IF NOT EXISTS` y solo crea lo que no existe. Puedes ignorar estos mensajes.

### Error: "Foreign key constraint"
**Solución:** El script crea las tablas en el orden correcto. Si hay un error, verifica que no haya tablas huérfanas de ejecuciones anteriores.

### Error: "Timeout"
**Solución:** 
- Aumenta el timeout en tu cliente SQL
- O ejecuta el script en partes (separar por secciones)

---

## 📋 Checklist

- [ ] Base de datos creada en Azure
- [ ] Firewall configurado (Allow Azure services = Yes)
- [ ] Credenciales de acceso disponibles
- [ ] Script `SCRIPT_AZURE_SQL_DATABASE.sql` descargado
- [ ] Cliente SQL instalado (Azure Data Studio, SSMS, o Azure Portal)
- [ ] Conectado a la base de datos correcta
- [ ] Script ejecutado sin errores críticos
- [ ] Tablas verificadas (18 tablas en esquema wms)
- [ ] Datos iniciales verificados
- [ ] Usuario admin verificado

---

## 🎯 Siguiente Paso

Una vez que el script se ejecute correctamente:

1. **Actualizar variables en Railway** con la información de Azure SQL
2. **Reiniciar el servicio** en Railway
3. **Verificar logs** para confirmar conexión
4. **Probar el backend** desde el frontend

---

**¿Necesitas ayuda? Dime qué método prefieres usar y te guío paso a paso.**

