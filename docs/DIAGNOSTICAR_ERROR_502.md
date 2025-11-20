# 🔍 Diagnosticar Error 502 en Railway

## ❌ Problema

```
GET /sanctum/csrf-cookie 502 (Bad Gateway)
POST /api/auth/login 499
```

El backend está devolviendo error 502, lo que significa que el servidor no está respondiendo.

## 🔍 Pasos para Diagnosticar

### 1. Ver Logs de Railway (CRÍTICO)

**Este es el paso más importante.** Necesitamos ver los logs completos.

1. Ve a Railway Dashboard → Tu Proyecto
2. Haz clic en **Logs** o **Deployments**
3. Busca los logs más recientes
4. **Copia los logs completos** (últimas 50-100 líneas)

**Busca específicamente:**
- `Server running on [http://0.0.0.0:...]` - ¿El servidor inició?
- `Unsupported operand types` - Error de tipo en el puerto
- `No application encryption key` - APP_KEY faltante
- `could not find driver` - Extensiones PHP faltantes
- Cualquier error de PHP o Laravel
- Mensajes de crash o reinicio del contenedor

### 2. Verificar que el Servidor Esté Iniciando

En los logs deberías ver:
```
Server running on [http://0.0.0.0:8080]
Press Ctrl+C to stop the server
```

Si **NO** ves esto, el servidor no está iniciando correctamente.

### 3. Verificar Variables de Entorno

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

### 4. Verificar que el Build se Completó

1. Ve a Railway Dashboard → Deployments
2. Verifica que el último deployment esté **completado** (no fallido)
3. Si falló, revisa los logs del build

### 5. Verificar Start Command en Railway

1. Ve a Railway Dashboard → Settings → Deploy
2. Verifica que **Start Command** sea:
   ```
   php artisan serve --host=0.0.0.0 --port=$PORT
   ```
   O déjalo vacío para que use el CMD del Dockerfile

## 🚨 Errores Comunes y Soluciones

### Error: "Unsupported operand types: string + int"
**Causa:** La variable `PORT` viene como string pero Laravel espera un entero
**Solución:** He creado `backend/start.sh` que maneja esto correctamente

### Error: "No application encryption key"
**Causa:** `APP_KEY` no está configurado
**Solución:** Agrega `APP_KEY` en Railway Variables

### Error: "could not find driver"
**Causa:** Extensiones PHP no instaladas
**Solución:** Verifica que el Dockerfile se haya usado correctamente

### Error: El servidor no inicia
**Causa:** Error en el código o configuración
**Solución:** Revisa los logs completos de Railway

## 📋 Checklist de Verificación

- [ ] Logs de Railway revisados - ¿Qué error aparece?
- [ ] `APP_KEY` configurado en Railway Variables
- [ ] Todas las variables de entorno configuradas
- [ ] Build completado exitosamente
- [ ] Servidor iniciando correctamente (ver logs)
- [ ] No hay errores de PHP en los logs
- [ ] Start Command configurado correctamente

## 🔧 Solución Implementada

He creado `backend/start.sh` que:
- Maneja correctamente la variable `PORT`
- Usa un valor por defecto si `PORT` no está disponible
- Inicia el servidor Laravel correctamente

El Dockerfile ahora usa este script para iniciar el servidor.

## 📝 Información Necesaria

Para diagnosticar mejor, necesito:

1. **Logs completos de Railway** (últimas 50-100 líneas)
2. **Estado del deployment** (¿completado o fallido?)
3. **¿El servidor está iniciando?** (busca "Server running" en los logs)
4. **Variables de entorno** verificadas (sin valores sensibles)

## 💡 Nota

El error 502 generalmente significa que:
- El servidor no está corriendo
- El servidor está crasheando al iniciar
- Hay un error en el código que impide que el servidor responda

Los logs de Railway nos dirán exactamente qué está pasando.

