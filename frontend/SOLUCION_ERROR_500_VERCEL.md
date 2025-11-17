# 🔧 Solución: Error 500 en Vercel

## ❌ Problema

El frontend en Vercel está intentando conectarse a `http://127.0.0.1:8000` (localhost) que no existe en el servidor de Vercel, causando un error 500.

## ✅ Solución

### Opción 1: Configurar Variable de Entorno en Vercel (Recomendado)

1. **Ve a Vercel Dashboard:**
   - https://vercel.com/dashboard
   - Selecciona tu proyecto `WMS-v9`

2. **Configura la Variable de Entorno:**
   - Ve a **Settings** → **Environment Variables**
   - Agrega una nueva variable:
     - **Name:** `VITE_API_URL`
     - **Value:** `https://wms-v9-production.up.railway.app`
     - **Environments:** Selecciona ✅ Production, ✅ Preview, ✅ Development

3. **Redesplegar:**
   - Ve a **Deployments**
   - Haz clic en los **3 puntos** del deployment más reciente
   - Selecciona **Redeploy**

### Opción 2: El Código Ya Tiene Fallback

El código ahora tiene un fallback que usa la URL de Railway en producción si `VITE_API_URL` no está configurada. Sin embargo, **es mejor configurar la variable de entorno** para tener control total.

## 🔍 Verificar la Configuración

Después de redesplegar:

1. **Abre la consola del navegador** (F12) en tu sitio de Vercel
2. **Intenta hacer login**
3. **Revisa la pestaña Network:**
   - La petición debería ir a: `https://wms-v9-production.up.railway.app/api/auth/login`
   - NO debería ir a: `http://127.0.0.1:8000`

## 📋 Checklist

- [ ] Variable `VITE_API_URL` configurada en Vercel
- [ ] Valor: `https://wms-v9-production.up.railway.app` (sin `/` al final)
- [ ] Habilitada para Production, Preview y Development
- [ ] Deployment redesplegado después de agregar la variable
- [ ] Backend en Railway funcionando correctamente
- [ ] CORS configurado en Railway para permitir el dominio de Vercel

## 🚨 Si el Error Persiste

1. **Verifica los logs de Railway:**
   - Ve a Railway Dashboard
   - Revisa los logs para ver si hay errores del servidor

2. **Verifica CORS en Railway:**
   - Asegúrate de que `CORS_ALLOWED_ORIGINS` incluya tu dominio de Vercel
   - Ejemplo: `https://wms-v9.vercel.app,https://*.vercel.app`

3. **Verifica que el backend responda:**
   ```bash
   curl https://wms-v9-production.up.railway.app/api/auth/login \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"usuario":"admin","password":"admin123"}'
   ```

## 💡 Nota

El código ahora detecta automáticamente si está en producción y usa la URL de Railway por defecto si no hay `VITE_API_URL` configurada. Sin embargo, **siempre es mejor configurar la variable de entorno explícitamente** para tener control total sobre la configuración.

