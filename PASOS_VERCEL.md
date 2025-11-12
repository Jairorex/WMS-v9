# 🚀 Pasos para Desplegar en Vercel

## ⚡ Resumen Rápido

### 1️⃣ Desplegar Backend (Railway - 5 minutos)

1. Ir a https://railway.app
2. Crear cuenta con GitHub
3. "New Project" → "Deploy from GitHub repo"
4. Seleccionar tu repositorio
5. Configurar:
   - **Root Directory:** `backend`
   - **Build Command:** `composer install --no-dev --optimize-autoloader`
   - **Start Command:** `php artisan serve --host=0.0.0.0 --port=$PORT`
6. Agregar variables de entorno:
   ```
   APP_ENV=production
   APP_DEBUG=false
   APP_KEY=(generar con: php artisan key:generate)
   DB_CONNECTION=sqlsrv
   DB_HOST=tu-sql-server
   DB_DATABASE=wms
   DB_USERNAME=sa
   DB_PASSWORD=tu-password
   CORS_ALLOWED_ORIGINS=https://tu-app.vercel.app
   ```
7. **Anotar la URL del backend** (ej: `https://wms-backend.railway.app`)

### 2️⃣ Desplegar Frontend (Vercel - 3 minutos)

**Opción A: Desde la Web (Más Fácil)**

1. Ir a https://vercel.com
2. Iniciar sesión con GitHub
3. "Add New Project"
4. Seleccionar tu repositorio
5. Configurar:
   - **Framework Preset:** Vite
   - **Root Directory:** `frontend`
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`
6. Agregar variable de entorno:
   - **Name:** `VITE_API_URL`
   - **Value:** `https://tu-backend-url.railway.app/api`
7. Click "Deploy"

**Opción B: Desde CLI**

```bash
cd frontend
npm i -g vercel
vercel login
vercel --prod
# Cuando pregunte por VITE_API_URL, ingresar: https://tu-backend-url.railway.app/api
```

### 3️⃣ Configurar CORS

En Railway (backend), agregar/actualizar:
```
CORS_ALLOWED_ORIGINS=https://tu-app.vercel.app
```

### 4️⃣ Probar

- Abrir: `https://tu-app.vercel.app`
- Probar login
- Verificar que todo funcione

---

## ✅ Checklist

- [ ] Backend desplegado en Railway
- [ ] URL del backend anotada
- [ ] Frontend desplegado en Vercel
- [ ] Variable `VITE_API_URL` configurada
- [ ] CORS configurado en backend
- [ ] Aplicación funcionando

---

## 📚 Documentación Completa

- **Guía completa:** `DESPLIEGUE_VERCEL.md`
- **Inicio rápido:** `VERCEL_QUICK_START.md`

---

## 🆘 Problemas Comunes

### Error: "Failed to fetch"
- Verificar `VITE_API_URL` en Vercel
- Verificar `CORS_ALLOWED_ORIGINS` en Railway

### Error: Build falla
- Verificar que `package.json` esté en `frontend/`
- Revisar logs en Vercel

### Página en blanco
- Verificar que `vercel.json` esté en `frontend/`
- Verificar rutas en el router

---

**🎉 ¡Listo! Tu aplicación está en producción.**

