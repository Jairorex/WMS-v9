# 🔧 Solución: Error 500 en el Backend

## 🔴 Problema

El frontend está intentando conectarse al backend pero recibe un error 500 (Internal Server Error).

Esto generalmente significa que hay un problema en el backend de Railway.

---

## 🔍 Diagnóstico

### 1. Verificar Logs en Railway

1. **En Railway Dashboard:**
   - Ve a tu proyecto
   - Click en el servicio (backend)
   - Ve a la pestaña **"Deployments"**
   - Click en el deployment más reciente
   - Click en **"View Logs"**

2. **Buscar errores:**
   - Busca líneas en rojo o con "ERROR"
   - Busca mensajes como:
     - `Database connection failed`
     - `APP_KEY not set`
     - `Class not found`
     - `SQLSTATE`

### 2. Errores Comunes y Soluciones

#### Error: "Database connection failed" o "SQLSTATE"

**Causa:** Problema con la conexión a la base de datos.

**Solución:**
1. Verificar que `DB_HOST` NO sea `localhost`
2. Verificar que `DB_USERNAME` y `DB_PASSWORD` estén configurados
3. Verificar que el servidor SQL Server sea accesible desde internet

**Variables correctas:**
```env
DB_HOST=tu-servidor.database.windows.net  # NO localhost
DB_USERNAME=tu-usuario
DB_PASSWORD=tu-password
DB_PORT=1433
```

#### Error: "APP_KEY not set" o "No application encryption key"

**Causa:** `APP_KEY` no está configurado.

**Solución:**
1. En Railway, ve a **"Variables"**
2. Buscar `APP_KEY`
3. Si está vacío:
   - Ve a **"Deployments"** → **"View Logs"**
   - Buscar línea: `Application key [base64:...] generated successfully`
   - Copiar el valor completo
   - Actualizar `APP_KEY` en Variables
   - Railway reiniciará automáticamente

#### Error: "Class not found" o errores de Composer

**Causa:** Dependencias no instaladas correctamente.

**Solución:**
1. Verificar que el Build Command sea correcto:
   ```
   composer install --no-dev --optimize-autoloader
   ```
2. En Railway, ir a **"Settings"**
3. Verificar **"Build Command"**
4. Si está incorrecto, corregirlo y hacer redeploy

#### Error: "Route not found" o 404

**Causa:** Rutas no configuradas correctamente.

**Solución:**
1. Verificar que las rutas estén en `routes/api.php`
2. Verificar que el prefijo `/api` esté configurado
3. Probar directamente: `https://tu-backend.railway.app/api`

---

## ✅ Pasos para Resolver

### Paso 1: Verificar Variables de Entorno

1. **En Railway:**
   - Ve a **"Variables"**
   - Verificar que todas estén configuradas:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... (debe tener un valor)
DB_CONNECTION=sqlsrv
DB_HOST=tu-servidor.database.windows.net  # ⚠️ NO localhost
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=tu-usuario  # ⚠️ NO vacío
DB_PASSWORD=tu-password  # ⚠️ NO vacío
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

### Paso 2: Corregir DB_HOST

**Si tienes `DB_HOST=localhost`, debes cambiarlo:**

1. **Obtener la URL real de tu SQL Server:**
   - Si es Azure: `tu-servidor.database.windows.net`
   - Si es VPS: `tu-ip-o-dominio.com`

2. **Actualizar en Railway:**
   - Variables → `DB_HOST` → Cambiar a la URL real
   - Guardar
   - Railway reiniciará

### Paso 3: Verificar APP_KEY

1. **En Railway:**
   - Variables → Buscar `APP_KEY`
   - Si está vacío o no existe:
     - Deployments → View Logs
     - Buscar: `Application key [base64:...]`
     - Copiar el valor
     - Actualizar en Variables

### Paso 4: Verificar Logs Después de Cambios

1. **Esperar** a que Railway reinicie (1-2 minutos)
2. **Ver logs** nuevamente
3. **Buscar** errores
4. **Si no hay errores**, el servidor debería estar funcionando

### Paso 5: Probar el Backend Directamente

1. **Obtener URL del backend** (Settings → Domains)
2. **Abrir en navegador:**
   ```
   https://tu-backend.railway.app/api
   ```
3. **Deberías ver:**
   - Una respuesta JSON
   - O un error de autenticación (eso está bien)
   - **NO** un error 500

---

## 🆘 Si el Problema Persiste

### Opción 1: Habilitar Debug Temporalmente

1. **En Railway Variables:**
   ```
   APP_DEBUG=true
   ```
2. **Ver logs** - verás más detalles del error
3. **Una vez resuelto, cambiar a:**
   ```
   APP_DEBUG=false
   ```

### Opción 2: Verificar que el Servicio Esté Activo

1. **En Railway:**
   - Verificar que el deployment esté en estado **"Active"**
   - Si está en "Failed", hacer click en **"Redeploy"**

### Opción 3: Probar Endpoint Específico

1. **Probar endpoint de health (si existe):**
   ```
   https://tu-backend.railway.app/api/health
   ```

2. **Probar endpoint de login:**
   ```
   https://tu-backend.railway.app/api/auth/login
   ```
   (Debería dar error 422 por falta de datos, no 500)

---

## 📋 Checklist de Verificación

- [ ] Logs revisados en Railway
- [ ] `DB_HOST` NO es `localhost`
- [ ] `DB_USERNAME` configurado (NO vacío)
- [ ] `DB_PASSWORD` configurado (NO vacío)
- [ ] `APP_KEY` configurado (NO vacío)
- [ ] Railway reiniciado después de cambios
- [ ] Backend responde en la URL (probar en navegador)
- [ ] No hay errores 500 en los logs

---

## 🔍 ¿Qué Error Ves en los Logs?

**Copia el error exacto que ves en los logs de Railway y te ayudo a resolverlo específicamente.**

Los errores más comunes son:
- `SQLSTATE[08001]` → Problema de conexión a DB
- `APP_KEY not set` → APP_KEY no configurado
- `Class 'X' not found` → Problema con Composer
- `Route [X] not defined` → Problema con rutas

**Dime qué error específico ves y te doy la solución exacta.**

