# 🔧 Verificar Error 502 en Railway

## ❌ Problema

```
GET /sanctum/csrf-cookie 502 (Bad Gateway)
POST /api/auth/login 499
```

El backend está devolviendo error 502, lo que significa que el servidor no está respondiendo o está crasheando.

## 🔍 Causas Posibles

### 1. **Backend No Está Iniciando Correctamente**
El servidor puede estar crasheando al iniciar debido a:
- Error en el manejo del puerto `PORT`
- Extensiones PHP no instaladas correctamente
- Error en el código de Laravel

### 2. **Puerto No Configurado Correctamente**
Railway inyecta `PORT` como variable de entorno, pero puede haber problemas al usarla directamente.

### 3. **APP_KEY No Configurado**
Si `APP_KEY` no está configurado, Laravel no puede iniciar.

## ✅ Solución Implementada

He creado un script de inicio (`backend/start.sh`) que:
- Maneja correctamente la variable `PORT`
- Usa un valor por defecto si `PORT` no está disponible
- Inicia el servidor Laravel correctamente

## 🚀 Próximos Pasos

### 1. Verificar Logs de Railway

**CRÍTICO:** Necesitamos ver los logs completos para identificar el problema.

1. Ve a Railway Dashboard → Tu Proyecto
2. Haz clic en **Logs** o **Deployments**
3. Busca los logs más recientes
4. **Copia los logs completos** (últimas 50-100 líneas)

**Busca específicamente:**
- `Server running on [http://0.0.0.0:...]` - El servidor inició correctamente
- `Unsupported operand types` - Error de tipo en el puerto
- `No application encryption key` - APP_KEY faltante
- `could not find driver` - Extensiones PHP faltantes
- Cualquier error de PHP o Laravel

### 2. Verificar Variables de Entorno

Asegúrate de que estas variables estén configuradas en Railway:

```
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
APP_URL=https://wms-v9-production.up.railway.app
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
SESSION_DRIVER=database
SESSION_LIFETIME=120
CORS_ALLOWED_ORIGINS=https://wms-v9.vercel.app,https://*.vercel.app
SANCTUM_STATEFUL_DOMAINS=wms-v9.vercel.app
```

### 3. Verificar que el Build se Completó

1. Ve a Railway Dashboard → Deployments
2. Verifica que el último deployment esté **completado** (no fallido)
3. Si falló, revisa los logs del build

### 4. Verificar que el Servidor Esté Corriendo

En los logs deberías ver:
```
Server running on [http://0.0.0.0:8080]
```

Si **NO** ves esto, el servidor no está iniciando.

## 🔧 Soluciones Alternativas

### Si el Error Persiste

1. **Verifica los logs completos de Railway** y compártelos
2. **Verifica que APP_KEY esté configurado** en Railway Variables
3. **Verifica que todas las variables de entorno estén correctas**
4. **Prueba cambiar el Start Command en Railway:**
   ```
   php artisan serve --host=0.0.0.0 --port=$PORT
   ```

## 📋 Checklist de Verificación

- [ ] Logs de Railway revisados - ¿Qué error aparece?
- [ ] `APP_KEY` configurado en Railway Variables
- [ ] Todas las variables de entorno configuradas
- [ ] Build completado exitosamente
- [ ] Servidor iniciando correctamente (ver logs)
- [ ] No hay errores de PHP en los logs

## 🚨 Información Necesaria

Para diagnosticar mejor, necesito:

1. **Logs completos de Railway** (últimas 50-100 líneas)
2. **Estado del deployment** (¿completado o fallido?)
3. **Variables de entorno** verificadas (sin valores sensibles)
4. **Mensaje de error exacto** si hay alguno

## 💡 Nota

El error 502 generalmente significa que:
- El servidor no está corriendo
- El servidor está crasheando al iniciar
- Hay un error en el código que impide que el servidor responda

Los logs de Railway nos dirán exactamente qué está pasando.

