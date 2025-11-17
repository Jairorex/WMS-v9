# 🔧 Solución: "could not find driver" en Railway

## ❌ Error

```
could not find driver (Connection: sqlsrv, SQL: select top 1 * from [usuarios]...)
PDOException(code: 0): could not find driver
```

## 🔍 Causa

Railway **NO tiene las extensiones PHP para SQL Server instaladas**. Las extensiones `pdo_sqlsrv` y `sqlsrv` no están disponibles en el contenedor.

## ✅ Solución

### Opción 1: Usar Dockerfile (RECOMENDADO)

He creado un `Dockerfile` en `backend/Dockerfile` que instala todas las extensiones necesarias.

**Pasos:**

1. **Verifica que el Dockerfile existe:**
   - Debe estar en `backend/Dockerfile`
   - Railway lo detectará automáticamente

2. **Railway debería detectar el Dockerfile automáticamente:**
   - Si no lo detecta, ve a Railway Dashboard → Settings
   - En "Build Command", deja vacío (Railway usará el Dockerfile)
   - En "Start Command", deja: `php artisan serve --host=0.0.0.0 --port=$PORT`

3. **Redesplegar:**
   - Ve a Railway Dashboard → Deployments
   - Haz clic en **Redeploy**
   - Espera 5-10 minutos (la primera vez puede tardar más)

### Opción 2: Configurar Railway Buildpack

Si Railway no detecta el Dockerfile:

1. Ve a Railway Dashboard → Settings
2. En "Build Command", agrega:
   ```bash
   apt-get update && apt-get install -y curl gnupg && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 && pecl install sqlsrv pdo_sqlsrv && docker-php-ext-enable sqlsrv pdo_sqlsrv
   ```
3. En "Start Command", deja:
   ```bash
   php artisan serve --host=0.0.0.0 --port=$PORT
   ```

**⚠️ NOTA:** Esta opción es más compleja y puede no funcionar. La Opción 1 (Dockerfile) es más confiable.

### Opción 3: Usar Railway Nixpacks (Alternativa)

Si el Dockerfile no funciona, Railway puede usar Nixpacks automáticamente, pero necesitarás configurar las extensiones manualmente.

## 📋 Verificación

Después de redesplegar, verifica que las extensiones estén instaladas:

1. **En Railway, crea un script de verificación temporal:**
   ```php
   <?php
   // backend/public/check-extensions.php
   phpinfo();
   ```

2. **Accede a:** `https://wms-v9-production.up.railway.app/check-extensions.php`
3. **Busca:** `pdo_sqlsrv` y `sqlsrv` en la lista de extensiones

O verifica en los logs de Railway que no aparezca el error "could not find driver".

## 🔧 Contenido del Dockerfile

El Dockerfile creado incluye:

1. **Imagen base:** `php:8.2-fpm`
2. **Microsoft ODBC Driver 18:** Necesario para conectar a SQL Server
3. **Extensiones PHP:**
   - `sqlsrv` - Driver para SQL Server
   - `pdo_sqlsrv` - PDO driver para SQL Server
   - Otras extensiones necesarias (mbstring, gd, etc.)
4. **Composer:** Para instalar dependencias
5. **Configuración de permisos:** Para Laravel

## 🚀 Pasos Inmediatos

1. **Verifica que `backend/Dockerfile` existe**
2. **En Railway Dashboard:**
   - Ve a Settings
   - Verifica que "Build Command" esté vacío o use el Dockerfile
   - Verifica que "Start Command" sea: `php artisan serve --host=0.0.0.0 --port=$PORT`
3. **Redesplegar:**
   - Ve a Deployments
   - Haz clic en **Redeploy**
   - Espera 5-10 minutos
4. **Probar el login nuevamente**

## ⚠️ Notas Importantes

- **La primera vez puede tardar 10-15 minutos** en construir la imagen
- **Railway debería detectar el Dockerfile automáticamente**
- **Si no funciona, verifica los logs de Railway** durante el build
- **Asegúrate de que el Dockerfile esté en la raíz de `backend/`**

## 🔍 Troubleshooting

### Error: "Dockerfile not found"
**Solución:** Verifica que el archivo esté en `backend/Dockerfile` (no en la raíz del proyecto)

### Error: "Build failed"
**Solución:** 
1. Revisa los logs de Railway durante el build
2. Verifica que todas las dependencias estén correctas
3. Puede ser que Railway necesite más tiempo o recursos

### Error: "Extension still not found"
**Solución:**
1. Verifica que el Dockerfile se haya usado (revisa los logs de build)
2. Verifica que las extensiones estén habilitadas en `php.ini`
3. Puede ser necesario reiniciar el servicio

## 📝 Archivos Creados

- `backend/Dockerfile` - Dockerfile con todas las extensiones necesarias
- `backend/.dockerignore` - Archivos a ignorar en el build

## ✅ Después de Redesplegar

Una vez que Railway redespliegue con el Dockerfile:

1. **Espera 5-10 minutos** para que termine el build
2. **Verifica los logs** - No debe aparecer "could not find driver"
3. **Prueba el login** - Debería funcionar ahora
4. **Si funciona, elimina el script de verificación** (`check-extensions.php`)

