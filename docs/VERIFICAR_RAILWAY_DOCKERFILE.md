# 🔍 Verificar que Railway Use el Dockerfile

## ❌ Problemas Actuales

1. **APP_KEY no configurado** - Se perdió después del nuevo deployment
2. **could not find driver** - Railway no está usando el Dockerfile

## ✅ Solución

### Paso 1: Verificar Configuración de Railway

1. **Ve a Railway Dashboard → Tu Proyecto → Settings**

2. **Verifica "Source":**
   - Debe apuntar a tu repositorio de GitHub
   - Debe estar en la rama `main`

3. **Verifica "Build":**
   - **Build Command:** Debe estar **VACÍO** (Railway usará el Dockerfile automáticamente)
   - **Start Command:** Debe ser: `php artisan serve --host=0.0.0.0 --port=$PORT`

4. **Si hay un Build Command configurado:**
   - **BÓRRALO** - Déjalo vacío
   - Railway detectará el Dockerfile automáticamente

### Paso 2: Configurar Railway para Usar Dockerfile

Si Railway no detecta el Dockerfile automáticamente:

1. **Ve a Settings → Build**
2. **En "Build Command", bórralo completamente** (déjalo vacío)
3. **En "Start Command", asegúrate de que sea:**
   ```
   php artisan serve --host=0.0.0.0 --port=$PORT
   ```
4. **Guarda los cambios**

### Paso 3: Agregar APP_KEY Nuevamente

Después del nuevo deployment, el `APP_KEY` se perdió. Agrégalo nuevamente:

1. **Ve a Railway Dashboard → Variables**
2. **Busca `APP_KEY`** o crea una nueva variable
3. **Name:** `APP_KEY`
4. **Value:** 
   ```
   base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
   ```
5. **Guarda**

### Paso 4: Redesplegar Manualmente

1. **Ve a Railway Dashboard → Deployments**
2. **Haz clic en "Redeploy"** en el deployment más reciente
3. **O crea un nuevo deployment:**
   - Ve a Settings → Deploy
   - Haz clic en "Redeploy"

### Paso 5: Verificar el Build

Durante el build, en los logs deberías ver:

1. **Instalación de Microsoft ODBC Driver:**
   ```
   Installing msodbcsql18...
   ```

2. **Instalación de extensiones PHP:**
   ```
   Installing sqlsrv...
   Installing pdo_sqlsrv...
   ```

3. **Si NO ves esto**, Railway no está usando el Dockerfile

## 🔧 Si Railway No Usa el Dockerfile

### Opción 1: Verificar Ubicación del Dockerfile

El Dockerfile debe estar en:
```
backend/Dockerfile
```

**NO** en la raíz del proyecto.

### Opción 2: Especificar Ruta del Dockerfile

Si Railway no lo detecta automáticamente:

1. Ve a Settings → Build
2. En "Dockerfile Path", especifica: `backend/Dockerfile`
3. O mueve el Dockerfile a la raíz del proyecto (no recomendado)

### Opción 3: Usar Build Command Manual

Si el Dockerfile no funciona, puedes usar un build command:

```bash
cd backend && composer install --no-dev --optimize-autoloader && php artisan config:cache
```

Pero esto **NO instalará las extensiones PHP**, así que no funcionará.

## 📋 Checklist

Antes de redesplegar, verifica:

- [ ] Dockerfile está en `backend/Dockerfile`
- [ ] Build Command está **VACÍO** en Railway
- [ ] Start Command es: `php artisan serve --host=0.0.0.0 --port=$PORT`
- [ ] `APP_KEY` está configurado en Railway Variables
- [ ] Todas las variables de entorno están configuradas
- [ ] Railway está conectado a la rama `main` de GitHub

## 🚨 Errores Comunes

### Error: "Dockerfile not found"
**Solución:** Verifica que el Dockerfile esté en `backend/Dockerfile`

### Error: "Build Command failed"
**Solución:** Borra el Build Command y deja que Railway use el Dockerfile

### Error: "could not find driver" después del build
**Solución:** 
1. Verifica los logs del build - ¿se instalaron las extensiones?
2. Si no, Railway no está usando el Dockerfile
3. Verifica la configuración de Build en Settings

## 📝 Notas

- **Railway debería detectar el Dockerfile automáticamente** si está en `backend/Dockerfile`
- **El Build Command debe estar VACÍO** para que Railway use el Dockerfile
- **Después de cada deployment, verifica que APP_KEY esté configurado**

