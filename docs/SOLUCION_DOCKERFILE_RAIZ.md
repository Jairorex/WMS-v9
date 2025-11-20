# 🔧 Solución: Dockerfile en la Raíz del Proyecto

## ❌ Error

```
Build Failed: failed to read dockerfile: open /backend/Dockerfile: no such file or directory
```

## 🔍 Causa

Railway busca el Dockerfile en la **raíz del proyecto**, no en subdirectorios como `backend/`.

## ✅ Solución

He movido el Dockerfile a la **raíz del proyecto** (`/Dockerfile`) y ajustado las rutas para que apunten a `backend/`.

### Cambios Realizados

1. **Dockerfile movido a la raíz:**
   - Antes: `backend/Dockerfile`
   - Ahora: `Dockerfile` (en la raíz)

2. **Rutas ajustadas en el Dockerfile:**
   - `COPY backend/composer.json backend/composer.lock ./`
   - `COPY backend/ .`

3. **`.dockerignore` creado en la raíz:**
   - Ignora archivos innecesarios como `frontend/`, `Movil/`, `docs/`, etc.

## 🚀 Próximos Pasos

### 1. Railway Debería Detectar el Dockerfile Automáticamente

Railway ahora debería:
- Detectar el Dockerfile en la raíz
- Iniciar un nuevo build automáticamente
- Instalar las extensiones PHP necesarias

### 2. Verificar el Build

1. Ve a **Railway Dashboard → Deployments**
2. Deberías ver un nuevo deployment en progreso
3. Haz clic en el deployment para ver los logs

### 3. En los Logs Deberías Ver

- Instalación de Microsoft ODBC Driver
- Instalación de extensiones PHP (`sqlsrv`, `pdo_sqlsrv`)
- Instalación de dependencias de Composer
- Build completado exitosamente

### 4. Agregar APP_KEY

**IMPORTANTE:** Después del nuevo deployment, agrega `APP_KEY` nuevamente:

1. Ve a **Railway Dashboard → Variables**
2. Busca o crea `APP_KEY`
3. Valor:
   ```
   base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
   ```
4. **Guarda**

### 5. Verificar Configuración de Build

1. Ve a **Railway Dashboard → Settings → Build**
2. **Build Command:** Debe estar **VACÍO**
3. **Start Command:** Debe ser:
   ```
   php artisan serve --host=0.0.0.0 --port=$PORT
   ```

## 📋 Estructura del Proyecto

```
WMS-v9/
├── Dockerfile          ← Ahora aquí (raíz)
├── .dockerignore       ← Ahora aquí (raíz)
├── backend/            ← Código del backend
│   ├── app/
│   ├── config/
│   ├── composer.json
│   └── ...
├── frontend/
├── Movil/
└── ...
```

## ✅ Verificación

Después del build:

1. **Espera 10-15 minutos** para que termine el build
2. **Verifica los logs** - No debe aparecer "could not find driver"
3. **Agrega APP_KEY** si no está configurado
4. **Prueba el login** - Debería funcionar

## 🚨 Si Hay Errores

### Error: "Dockerfile not found"
**Solución:** Verifica que el Dockerfile esté en la raíz del proyecto (no en `backend/`)

### Error: "could not find driver"
**Solución:** 
1. Verifica los logs del build - ¿se instalaron las extensiones?
2. Si no, Railway no está usando el Dockerfile correctamente

### Error: "APP_KEY not found"
**Solución:** Agrega `APP_KEY` en Railway Variables después del deployment

## 📝 Notas

- El Dockerfile ahora está en la **raíz del proyecto**
- Las rutas dentro del Dockerfile apuntan a `backend/`
- Railway debería detectarlo automáticamente
- Después de cada deployment, verifica que `APP_KEY` esté configurado

