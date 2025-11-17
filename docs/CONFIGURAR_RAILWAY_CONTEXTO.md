# 🔧 Configurar Contexto de Build en Railway

## ❌ Problema

Railway busca el Dockerfile en `/backend/Dockerfile` pero no lo encuentra porque el contexto de build está en la raíz del proyecto.

## ✅ Solución

He creado `railway.json` que especifica la ruta del Dockerfile. Pero también necesitas configurar Railway para que use `backend/` como contexto de build.

### Opción 1: Configurar en Railway Dashboard (RECOMENDADO)

1. **Ve a Railway Dashboard → Tu Proyecto → Settings**
2. **Ve a la sección "Build"**
3. **En "Root Directory" o "Build Context", especifica:**
   ```
   backend
   ```
4. **O en "Dockerfile Path", especifica:**
   ```
   Dockerfile
   ```
   (si el contexto es `backend/`)

### Opción 2: Usar railway.json

He creado `railway.json` en la raíz que especifica:
- `dockerfilePath: "backend/Dockerfile"`

Railway debería leer este archivo automáticamente.

### Opción 3: Mover Todo a backend/

Si Railway no puede configurarse, podemos mover el Dockerfile y ajustar las rutas, pero esto es más complejo.

## 🚀 Pasos Inmediatos

1. **Verifica que `railway.json` esté en la raíz del proyecto**
2. **En Railway Dashboard → Settings → Build:**
   - **Root Directory:** `backend`
   - **Dockerfile Path:** `Dockerfile` (o deja vacío si el contexto es `backend/`)
3. **Redesplegar:**
   - Ve a Deployments → Redeploy

## 📋 Verificación

Después de configurar:

1. **Railway debería encontrar el Dockerfile**
2. **El build debería comenzar**
3. **En los logs deberías ver la instalación de extensiones**

## ⚠️ Si Sigue Sin Funcionar

1. **Verifica en Railway Settings que el Root Directory sea `backend`**
2. **O cambia el Root Directory a `.` (raíz) y especifica `backend/Dockerfile` como Dockerfile Path**

