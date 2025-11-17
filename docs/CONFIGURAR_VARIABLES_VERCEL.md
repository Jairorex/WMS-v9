# Configurar Variables de Entorno en Vercel

## ⚠️ Problema Común: Error 405 o URL Mal Formada

Si ves errores como:
```
POST https://wms-v9.vercel.app/wms-v9-production.up.railway.app/api/auth/login 405
```

Esto significa que la variable `VITE_API_URL` está mal configurada en Vercel.

## ✅ Solución Correcta

### Paso 1: Ir a la Configuración de Vercel

1. Ve a tu proyecto en [Vercel Dashboard](https://vercel.com/dashboard)
2. Selecciona tu proyecto `WMS-v9` (o el nombre que le hayas dado)
3. Ve a **Settings** → **Environment Variables**

### Paso 2: Configurar `VITE_API_URL`

**IMPORTANTE**: La URL debe ser **completa y absoluta**, incluyendo el protocolo `https://`

#### ✅ Configuración CORRECTA:
```
VITE_API_URL=https://wms-v9-production.up.railway.app
```

#### ❌ Configuraciones INCORRECTAS (NO usar):
```
VITE_API_URL=wms-v9-production.up.railway.app          # ❌ Falta https://
VITE_API_URL=https://wms-v9-production.up.railway.app/ # ❌ Tiene / al final
VITE_API_URL=/api                                      # ❌ Es una ruta relativa
VITE_API_URL=api                                       # ❌ Es una ruta relativa
```

### Paso 3: Seleccionar Ambientes

Asegúrate de que la variable esté habilitada para:
- ✅ **Production**
- ✅ **Preview** (opcional, pero recomendado)
- ✅ **Development** (opcional)

### Paso 4: Guardar y Redesplegar

1. Haz clic en **Save**
2. Ve a la pestaña **Deployments**
3. Haz clic en los **3 puntos** del deployment más reciente
4. Selecciona **Redeploy**

## 🔍 Verificar la Configuración

Después de redesplegar, puedes verificar que la variable esté correctamente configurada:

1. Abre la consola del navegador (F12)
2. Ve a la pestaña **Console**
3. Deberías ver un mensaje si la URL no tiene protocolo (gracias a la validación agregada)
4. Abre la pestaña **Network**
5. Intenta hacer login
6. Verifica que la petición vaya a: `https://wms-v9-production.up.railway.app/api/auth/login`

## 📝 Ejemplo de Configuración Completa

Para un proyecto desplegado en:
- **Frontend**: Vercel (`https://wms-v9.vercel.app`)
- **Backend**: Railway (`https://wms-v9-production.up.railway.app`)

### Variables en Vercel:
```
VITE_API_URL=https://wms-v9-production.up.railway.app
```

### Variables en Railway:
```
APP_URL=https://wms-v9-production.up.railway.app
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app
```

## 🚨 Troubleshooting

### Error: "Failed to fetch"
- Verifica que `VITE_API_URL` tenga `https://` al inicio
- Verifica que no tenga `/` al final
- Verifica que Railway esté funcionando: `https://wms-v9-production.up.railway.app/up`

### Error: "CORS policy"
- Verifica que `CORS_ALLOWED_ORIGINS` en Railway incluya la URL de Vercel
- Asegúrate de que la URL en Railway sea exactamente la misma que aparece en Vercel (sin trailing slash)

### Error: "405 Method Not Allowed"
- Verifica que la URL sea absoluta (con `https://`)
- Verifica que Railway esté respondiendo correctamente
- Revisa los logs de Railway para ver si hay errores del servidor

