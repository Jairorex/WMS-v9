# 🚀 Guía de Despliegue en Vercel - WMS Escasan

## 📋 Tabla de Contenidos

1. [Requisitos](#requisitos)
2. [Despliegue del Frontend](#despliegue-del-frontend)
3. [Despliegue del Backend](#despliegue-del-backend)
4. [Configuración](#configuración)
5. [Variables de Entorno](#variables-de-entorno)
6. [Troubleshooting](#troubleshooting)

---

## 📦 Requisitos

- Cuenta en [Vercel](https://vercel.com)
- Cuenta en un servicio para el backend (Railway, Render, Fly.io, etc.)
- Git (para conectar el repositorio)
- Node.js instalado localmente (opcional, para pruebas)

---

## 🎨 Despliegue del Frontend

### Opción 1: Desde la Interfaz de Vercel (Recomendado)

1. **Crear cuenta en Vercel:**
   - Ir a https://vercel.com
   - Iniciar sesión con GitHub/GitLab/Bitbucket

2. **Importar proyecto:**
   - Click en "Add New Project"
   - Seleccionar tu repositorio de GitHub
   - Configurar:
     - **Framework Preset:** Vite
     - **Root Directory:** `frontend`
     - **Build Command:** `npm run build`
     - **Output Directory:** `dist`
     - **Install Command:** `npm install`

3. **Configurar Variables de Entorno:**
   - En la configuración del proyecto, ir a "Environment Variables"
   - Agregar:
     ```
     VITE_API_URL=https://tu-backend-url.com/api
     ```

4. **Desplegar:**
   - Click en "Deploy"
   - Esperar a que termine el build

### Opción 2: Desde la CLI

```bash
# 1. Instalar Vercel CLI
npm i -g vercel

# 2. Navegar al directorio del frontend
cd frontend

# 3. Iniciar sesión
vercel login

# 4. Desplegar
vercel

# 5. Para producción
vercel --prod
```

### Opción 3: Con GitHub Actions (CI/CD)

Crear `.github/workflows/deploy-vercel.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: Install Vercel CLI
        run: npm i -g vercel
      
      - name: Deploy to Vercel
        run: vercel --prod --token ${{ secrets.VERCEL_TOKEN }}
        working-directory: ./frontend
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

## 🔧 Despliegue del Backend

Vercel **NO soporta PHP/Laravel directamente**. Necesitas desplegar el backend en otro servicio:

### Opción 1: Railway (Recomendado)

1. **Crear cuenta:** https://railway.app
2. **Nuevo proyecto desde GitHub**
3. **Agregar servicio:**
   - Seleccionar "New" → "GitHub Repo"
   - Seleccionar tu repositorio
   - Root Directory: `backend`
4. **Configurar:**
   - **Build Command:** `composer install --no-dev --optimize-autoloader`
   - **Start Command:** `php artisan serve --host=0.0.0.0 --port=$PORT`
5. **Variables de entorno:**
   ```
   APP_ENV=production
   APP_DEBUG=false
   DB_CONNECTION=sqlsrv
   DB_HOST=tu-sql-server
   DB_DATABASE=wms
   DB_USERNAME=sa
   DB_PASSWORD=tu-password
   ```

### Opción 2: Render

1. **Crear cuenta:** https://render.com
2. **Nuevo Web Service**
3. **Configurar:**
   - Build Command: `composer install --no-dev`
   - Start Command: `php artisan serve --host=0.0.0.0 --port=$PORT`
4. **Agregar variables de entorno**

### Opción 3: Fly.io

```bash
# Instalar Fly CLI
curl -L https://fly.io/install.sh | sh

# Iniciar sesión
fly auth login

# Crear app
fly launch

# Desplegar
fly deploy
```

### Opción 4: Usar Docker en un VPS

Si prefieres mantener todo en Docker, puedes usar:
- DigitalOcean App Platform
- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances

---

## ⚙️ Configuración

### Variables de Entorno en Vercel (Frontend)

En el dashboard de Vercel → Settings → Environment Variables:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `VITE_API_URL` | `https://tu-backend-url.com/api` | URL de la API backend |

### Configuración de CORS en el Backend

Asegúrate de que tu backend permita el origen de Vercel:

```env
CORS_ALLOWED_ORIGINS=https://tu-app.vercel.app,https://tu-dominio.com
```

### Configuración de Dominio Personalizado

1. En Vercel → Settings → Domains
2. Agregar tu dominio
3. Configurar DNS según las instrucciones
4. Esperar propagación (puede tardar hasta 48 horas)

---

## 🔐 Variables de Entorno

### Frontend (Vercel)

```env
VITE_API_URL=https://tu-backend-url.com/api
```

### Backend (Railway/Render/etc.)

```env
APP_NAME=WMS
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:tu-clave-generada
APP_URL=https://tu-backend-url.com

DB_CONNECTION=sqlsrv
DB_HOST=tu-sql-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=tu-usuario
DB_PASSWORD=tu-password

SESSION_DRIVER=database
SESSION_LIFETIME=120

CORS_ALLOWED_ORIGINS=https://tu-app.vercel.app,https://tu-dominio.com
```

---

## 📝 Pasos Completos de Despliegue

### 1. Preparar Backend

```bash
# En tu máquina local
cd backend

# Generar APP_KEY
php artisan key:generate

# Copiar la clave generada para usarla en producción
```

### 2. Desplegar Backend

- Elegir servicio (Railway, Render, etc.)
- Conectar repositorio
- Configurar variables de entorno
- Desplegar
- Anotar la URL del backend

### 3. Desplegar Frontend en Vercel

- Conectar repositorio en Vercel
- Configurar:
  - Root Directory: `frontend`
  - Build Command: `npm run build`
  - Output Directory: `dist`
- Agregar variable de entorno:
  - `VITE_API_URL=https://tu-backend-url.com/api`
- Desplegar

### 4. Configurar CORS

En el backend, actualizar:
```env
CORS_ALLOWED_ORIGINS=https://tu-app.vercel.app
```

### 5. Probar

- Abrir https://tu-app.vercel.app
- Verificar que el frontend carga
- Probar login y funcionalidades

---

## 🔧 Troubleshooting

### Error: "Failed to fetch" en el frontend

**Causa:** CORS o URL incorrecta de la API

**Solución:**
1. Verificar `VITE_API_URL` en Vercel
2. Verificar `CORS_ALLOWED_ORIGINS` en el backend
3. Verificar que el backend esté accesible

### Error: Build falla en Vercel

**Causa:** Dependencias o configuración incorrecta

**Solución:**
1. Verificar que `package.json` esté en `frontend/`
2. Verificar que `vite.config.ts` esté correcto
3. Revisar logs de build en Vercel

### Error: Página en blanco

**Causa:** Ruta incorrecta o problema con el router

**Solución:**
1. Verificar `vercel.json` en `frontend/`
2. Asegurar que las rutas estén configuradas correctamente
3. Verificar que `index.html` esté en `dist/`

### Error: API no responde

**Causa:** Backend no está corriendo o URL incorrecta

**Solución:**
1. Verificar que el backend esté desplegado y corriendo
2. Probar la URL del backend directamente
3. Verificar logs del backend

---

## 📚 Archivos de Configuración

### `frontend/vercel.json`

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### Variables de Entorno por Entorno

En Vercel puedes configurar variables diferentes para:
- **Production:** Producción
- **Preview:** Pull requests
- **Development:** Desarrollo local

---

## ✅ Checklist de Despliegue

- [ ] Backend desplegado y funcionando
- [ ] URL del backend anotada
- [ ] CORS configurado en el backend
- [ ] Frontend conectado a Vercel
- [ ] Variable `VITE_API_URL` configurada en Vercel
- [ ] Build exitoso en Vercel
- [ ] Frontend accesible en la URL de Vercel
- [ ] Login funciona correctamente
- [ ] API responde correctamente
- [ ] Dominio personalizado configurado (opcional)

---

## 🎯 Próximos Pasos

1. **Configurar dominio personalizado**
2. **Configurar SSL/HTTPS** (automático en Vercel)
3. **Configurar monitoreo** (Vercel Analytics)
4. **Configurar CI/CD** para despliegues automáticos
5. **Optimizar rendimiento** (imágenes, caching, etc.)

---

## 🔗 Enlaces Útiles

- [Documentación de Vercel](https://vercel.com/docs)
- [Vercel CLI](https://vercel.com/docs/cli)
- [Railway](https://railway.app)
- [Render](https://render.com)
- [Fly.io](https://fly.io)

---

**✅ ¡Despliegue completado! Tu aplicación WMS está en Vercel.**

