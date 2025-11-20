# 🔧 Solución: Error 500 en Railway Backend

## ❌ Problema

El backend en Railway está devolviendo error 500 en:
- `GET /sanctum/csrf-cookie` → 500
- `POST /api/auth/login` → 500

## 🔍 Causas Comunes

### 1. **APP_KEY Faltante o Incorrecto** ⚠️ MÁS COMÚN
El error 500 puede ser causado por `APP_KEY` no configurado.

**🔑 NUEVO APP_KEY GENERADO:**
```
base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
```

**Solución:**
1. Ve a Railway Dashboard → Variables
2. Busca `APP_KEY` o crea una nueva variable
3. **Name:** `APP_KEY`
4. **Value:** Pega este valor exacto (sin espacios, sin comillas):
   ```
   base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
   ```
5. Guarda y espera a que Railway redesplegue automáticamente

**📖 Ver guía completa:** `docs/AGREGAR_APP_KEY_RAILWAY_PASO_A_PASO.md`

### 2. **Problema de Conexión a Base de Datos**
Azure SQL Database puede no estar accesible o las credenciales pueden ser incorrectas.

**Solución:**
1. Verifica las variables de entorno en Railway:
   ```
   DB_CONNECTION=sqlsrv
   DB_HOST=wms-escasan-server.database.windows.net
   DB_PORT=1433
   DB_DATABASE=wms_escasan
   DB_USERNAME=wmsadmin
   DB_PASSWORD=Escasan123
   ```

2. Verifica que Azure SQL Database permita conexiones desde Railway
3. Revisa los logs de Railway para errores de conexión SQL

### 3. **Tabla Sessions No Existe**
Si `SESSION_DRIVER=database`, necesitas la tabla `sessions`.

**Solución:**
- Opción A: Crear la tabla `sessions` en Azure SQL
- Opción B: Cambiar `SESSION_DRIVER=file` en Railway

### 4. **Dependencias PHP Faltantes**
Railway puede no tener todas las extensiones PHP necesarias.

**Solución:**
Verifica que el `Dockerfile` o configuración de Railway incluya:
- `pdo_sqlsrv`
- `sqlsrv`
- Otras extensiones necesarias

## 📋 Pasos para Diagnosticar

### Paso 1: Ver Logs de Railway

1. Ve a [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu proyecto
3. Ve a la pestaña **Deployments** o **Logs**
4. Busca errores que contengan:
   - `ERROR`
   - `Exception`
   - `SQLSTATE`
   - `APP_KEY`
   - `Class not found`

### Paso 2: Verificar Variables de Entorno

Asegúrate de que estas variables estén configuradas en Railway:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... (DEBE ESTAR CONFIGURADO)
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
SESSION_DRIVER=database
SESSION_LIFETIME=120
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app
```

### Paso 3: Probar Endpoints Directamente

```bash
# Probar CSRF cookie
curl https://wms-v9-production.up.railway.app/sanctum/csrf-cookie

# Probar login
curl -X POST https://wms-v9-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'
```

### Paso 4: Verificar Respuesta del Error

En los logs de Railway, busca el mensaje de error exacto. Los más comunes son:

- `No application encryption key has been specified` → Falta `APP_KEY`
- `SQLSTATE[08001]` → Problema de conexión a base de datos
- `Table 'sessions' doesn't exist` → Falta tabla sessions
- `Class 'PDO' not found` → Extensión PHP faltante

## ✅ Soluciones Rápidas

### Solución 1: Cambiar SESSION_DRIVER

Si el problema es la tabla `sessions`, cambia temporalmente en Railway:

```
SESSION_DRIVER=file
```

Esto no requiere la tabla `sessions` en la base de datos.

### Solución 2: Verificar APP_KEY

1. Genera un nuevo `APP_KEY`:
   ```bash
   cd backend
   php artisan key:generate --show
   ```

2. Copia el valor (ej: `base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=`)

3. Agrégalo en Railway como variable de entorno `APP_KEY`

4. Redesplega el servicio

### Solución 3: Verificar Conexión a Base de Datos

1. Verifica que Azure SQL Database esté accesible
2. Prueba la conexión desde Railway usando las credenciales
3. Verifica que el firewall de Azure permita conexiones desde Railway

## 🔧 Comandos Útiles

### Verificar APP_KEY en Railway
```bash
# En Railway, ve a Variables y busca APP_KEY
# Debe tener un valor como: base64:...
```

### Generar Nuevo APP_KEY
```bash
cd backend
php artisan key:generate --show
```

### Probar Conexión a Base de Datos
```bash
# Desde Railway, puedes ejecutar:
php artisan tinker
# Luego en tinker:
DB::connection()->getPdo();
```

## 📝 Información Necesaria

Para diagnosticar mejor, comparte:
1. **Logs de Railway** (últimas 50-100 líneas)
2. **Variables de entorno** (sin valores sensibles como passwords)
3. **Respuesta del curl** (si lo probaste)
4. **Mensaje de error exacto** de los logs

## 🚨 Si Nada Funciona

1. **Redesplegar el servicio completo:**
   - En Railway, ve a Deployments
   - Selecciona "Redeploy" en el deployment más reciente

2. **Verificar que el código esté actualizado:**
   - Asegúrate de que Railway esté usando el código más reciente de GitHub

3. **Contactar soporte de Railway:**
   - Si el problema persiste, puede ser un problema de la plataforma

