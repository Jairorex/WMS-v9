# 🚀 Guía Paso a Paso - Despliegue en Vercel

## 📋 Pre-requisitos

- ✅ Repositorio en GitHub
- ✅ Cuenta en Vercel (gratis)
- ✅ Cuenta en Railway o Render (para backend)

---

## PASO 1: Desplegar Backend (Railway) ⚙️

### 1.1 Crear cuenta en Railway

1. Ir a: **https://railway.app**
2. Click en **"Login"** o **"Start a New Project"**
3. Iniciar sesión con **GitHub**
4. Autorizar Railway para acceder a tus repositorios

### 1.2 Crear nuevo proyecto

1. Click en **"New Project"**
2. Seleccionar **"Deploy from GitHub repo"**
3. Buscar y seleccionar tu repositorio: **`WMS-v9`**
4. Click en **"Deploy Now"**

### 1.3 Configurar el servicio

1. Railway detectará automáticamente el proyecto
2. Click en el servicio creado
3. Ir a la pestaña **"Settings"**
4. Configurar:
   - **Root Directory:** `backend`
   - **Build Command:** `composer install --no-dev --optimize-autoloader`
   - **Start Command:** `php artisan serve --host=0.0.0.0 --port=$PORT`

### 1.4 Agregar variables de entorno

1. En la pestaña **"Variables"**
2. Click en **"New Variable"**
3. Agregar las siguientes variables:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=
DB_CONNECTION=sqlsrv
DB_HOST=tu-sql-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=tu-usuario
DB_PASSWORD=tu-password
SESSION_DRIVER=database
SESSION_LIFETIME=120
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app/
```

**⚠️ IMPORTANTE:**
- `APP_KEY`: Se generará automáticamente al iniciar
- `DB_HOST`: Tu servidor SQL Server (Azure, local, etc.)
- `CORS_ALLOWED_ORIGINS`: Se actualizará después con la URL de Vercel

### 1.5 Generar APP_KEY

1. En Railway, ir a la pestaña **"Deployments"**
2. Click en el deployment más reciente
3. Click en **"View Logs"**
4. Buscar la línea que dice: `Application key [base64:...] generated successfully`
5. Copiar el `APP_KEY` generado
6. Volver a **"Variables"** y actualizar `APP_KEY` con el valor copiado
7. Railway reiniciará automáticamente

### 1.6 Obtener URL del backend

1. En Railway, ir a la pestaña **"Settings"**
2. Scroll hasta **"Domains"**
3. Click en **"Generate Domain"**
4. Copiar la URL generada (ej: `wms-backend-production.up.railway.app`)
5. **Anotar esta URL** - la necesitarás para el frontend

---

## PASO 2: Desplegar Frontend (Vercel) 🎨

### 2.1 Crear cuenta en Vercel

1. Ir a: **https://vercel.com**
2. Click en **"Sign Up"**
3. Iniciar sesión con **GitHub**
4. Autorizar Vercel para acceder a tus repositorios

### 2.2 Importar proyecto

1. En el dashboard de Vercel, click en **"Add New Project"**
2. Seleccionar tu repositorio: **`WMS-v9`**
3. Click en **"Import"**

### 2.3 Configurar proyecto

Vercel detectará automáticamente que es un proyecto Vite, pero debemos ajustar:

1. **Framework Preset:** `Vite` (debe estar seleccionado)
2. **Root Directory:** `frontend` ⚠️ **IMPORTANTE**
3. **Build Command:** `npm run build` (ya configurado)
4. **Output Directory:** `dist` (ya configurado)
5. **Install Command:** `npm install` (ya configurado)

### 2.4 Agregar variable de entorno

1. Antes de hacer deploy, expandir **"Environment Variables"**
2. Click en **"Add"**
3. Agregar:
   - **Name:** `VITE_API_URL`
   - **Value:** `https://tu-backend-url.railway.app/api`
   - **Environment:** Seleccionar todas (Production, Preview, Development)

**⚠️ IMPORTANTE:** Reemplazar `tu-backend-url.railway.app` con la URL real de Railway del Paso 1.6

### 2.5 Desplegar

1. Click en **"Deploy"**
2. Esperar a que termine el build (2-3 minutos)
3. Una vez completado, verás la URL de tu aplicación (ej: `wms-v9.vercel.app`)

### 2.6 Obtener URL del frontend

1. En el dashboard de Vercel, verás tu proyecto
2. La URL será algo como: `wms-v9-xxxxx.vercel.app`
3. **Anotar esta URL** - la necesitarás para configurar CORS

---

## PASO 3: Configurar CORS 🔒

### 3.1 Actualizar CORS en Railway

1. Volver a Railway
2. Ir a **"Variables"**
3. Buscar `CORS_ALLOWED_ORIGINS`
4. Actualizar el valor con la URL de Vercel:
   ```
   CORS_ALLOWED_ORIGINS=https://wms-v9-xxxxx.vercel.app
   ```
5. Railway reiniciará automáticamente

### 3.2 Verificar configuración

1. En Railway, verificar que el servicio esté corriendo
2. Probar la URL del backend directamente:
   ```
   https://tu-backend-url.railway.app/api/health
   ```
   (o cualquier endpoint de la API)

---

## PASO 4: Probar la Aplicación ✅

### 4.1 Abrir la aplicación

1. Ir a la URL de Vercel: `https://tu-app.vercel.app`
2. Deberías ver la página de login

### 4.2 Probar login

1. Intentar iniciar sesión con credenciales válidas
2. Si hay errores, revisar la consola del navegador (F12)

### 4.3 Verificar funcionalidades

- ✅ Login funciona
- ✅ Dashboard carga
- ✅ Navegación funciona
- ✅ API responde correctamente

---

## 🆘 Troubleshooting

### Error: "Failed to fetch" en el frontend

**Causa:** CORS o URL incorrecta

**Solución:**
1. Verificar `VITE_API_URL` en Vercel (NO debe terminar en `/api`)
2. Verificar `CORS_ALLOWED_ORIGINS` en Railway (debe incluir la URL del frontend)
3. La URL del backend NO debe terminar en `/api` porque el frontend ya lo agrega

### Error: Build falla en Vercel

**Causa:** Configuración incorrecta

**Solución:**
1. Verificar que **Root Directory** sea `frontend`
2. Verificar que `package.json` esté en `frontend/`
3. Revisar logs de build en Vercel

### Error: Backend no responde

**Causa:** Servicio no iniciado o variables incorrectas

**Solución:**
1. Verificar logs en Railway
2. Verificar que `APP_KEY` esté configurado
3. Verificar conexión a base de datos

### Página en blanco

**Causa:** Problema con rutas o build

**Solución:**
1. Verificar que `vercel.json` esté en `frontend/`
2. Verificar logs de build
3. Probar en modo preview

---

## 📝 Checklist Final

- [ ] Backend desplegado en Railway
- [ ] URL del backend anotada
- [ ] `APP_KEY` generado y configurado
- [ ] Frontend desplegado en Vercel
- [ ] `VITE_API_URL` configurada en Vercel
- [ ] `CORS_ALLOWED_ORIGINS` configurado en Railway
- [ ] Aplicación accesible en Vercel
- [ ] Login funciona correctamente
- [ ] API responde correctamente

---

## 🎉 ¡Listo!

Tu aplicación WMS está desplegada y funcionando en:
- **Frontend:** https://tu-app.vercel.app
- **Backend:** https://tu-backend.railway.app

---

## 🔄 Actualizaciones Futuras

Cada vez que hagas `git push` a `main`:
- **Vercel** desplegará automáticamente el frontend
- **Railway** desplegará automáticamente el backend

---

**¿Necesitas ayuda? Revisa los logs en Vercel y Railway para más detalles.**

