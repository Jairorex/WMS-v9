# 🚀 Inicio Rápido - Despliegue en Vercel

## Pasos Rápidos

### 1. Desplegar Backend (Railway - Recomendado)

```bash
# 1. Ir a https://railway.app
# 2. Crear cuenta con GitHub
# 3. Nuevo proyecto → GitHub Repo
# 4. Seleccionar tu repositorio
# 5. Root Directory: backend
# 6. Agregar variables de entorno (ver DESPLIEGUE_VERCEL.md)
# 7. Anotar la URL del backend
```

### 2. Desplegar Frontend (Vercel)

```bash
# Opción A: Desde la web
# 1. Ir a https://vercel.com
# 2. Importar proyecto desde GitHub
# 3. Configurar:
#    - Root Directory: frontend
#    - Build Command: npm run build
#    - Output Directory: dist
# 4. Agregar variable de entorno:
#    VITE_API_URL=https://tu-backend-url.com/api
# 5. Deploy

# Opción B: Desde CLI
cd frontend
npm i -g vercel
vercel login
vercel --prod
```

### 3. Configurar CORS en Backend

En Railway/Render, agregar variable:
```
CORS_ALLOWED_ORIGINS=https://tu-app.vercel.app
```

## ✅ Listo!

- Frontend: https://tu-app.vercel.app
- Backend: https://tu-backend-url.com

## 📚 Documentación Completa

Ver `DESPLIEGUE_VERCEL.md` para detalles completos.

