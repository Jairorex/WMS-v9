# 🔍 Verificar Logs de Railway para Diagnosticar Crash

## ❌ Problema

El build se completa exitosamente, pero el backend sigue crasheando después de iniciar.

## 🔍 Pasos para Diagnosticar

### 1. Ver Logs de Railway (CRÍTICO)

**Este es el paso más importante.** Necesitamos ver los logs completos del contenedor en ejecución.

1. Ve a Railway Dashboard → Tu Proyecto
2. Haz clic en **Logs** (no Deployments, sino los logs en tiempo real)
3. Busca los logs más recientes
4. **Copia los logs completos** desde que el contenedor inicia

**Busca específicamente:**
- `🚀 Iniciando servidor Laravel en puerto ...` - ¿Aparece este mensaje?
- `✅ Iniciando servidor...` - ¿Aparece este mensaje?
- `Server running on [http://0.0.0.0:...]` - ¿El servidor inició?
- `❌ Error:` - ¿Hay algún error?
- `⚠️ Advertencia:` - ¿Hay advertencias sobre extensiones?
- `Unsupported operand types` - Error de tipo en el puerto
- `No application encryption key` - APP_KEY faltante
- `could not find driver` - Extensiones PHP faltantes
- Cualquier error de PHP o Laravel
- Mensajes de crash o reinicio del contenedor

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

### 3. Verificar que el Script de Inicio se Ejecute

En los logs deberías ver:
```
🚀 Iniciando servidor Laravel en puerto 8080
📋 Verificando extensiones PHP...
✅ Iniciando servidor...
Server running on [http://0.0.0.0:8080]
```

Si **NO** ves estos mensajes, el script no se está ejecutando.

### 4. Verificar Extensiones PHP

En los logs deberías ver:
- `sqlsrv` en la lista de extensiones
- `pdo_sqlsrv` en la lista de extensiones

Si ves advertencias sobre extensiones faltantes, el Dockerfile no se ejecutó correctamente.

## 🚨 Errores Comunes y Soluciones

### Error: "archivo artisan no encontrado"
**Causa:** Los archivos no se copiaron correctamente
**Solución:** Verifica que el Dockerfile copie todos los archivos

### Error: "No application encryption key"
**Causa:** `APP_KEY` no está configurado
**Solución:** Agrega `APP_KEY` en Railway Variables

### Error: "could not find driver"
**Causa:** Extensiones PHP no instaladas
**Solución:** Verifica que el Dockerfile se haya usado correctamente

### Error: El servidor inicia pero crashea inmediatamente
**Causa:** Error en el código o configuración
**Solución:** Revisa los logs completos de Railway

## 📋 Checklist de Verificación

- [ ] Logs de Railway revisados - ¿Qué error aparece?
- [ ] `APP_KEY` configurado en Railway Variables
- [ ] Todas las variables de entorno configuradas
- [ ] Build completado exitosamente
- [ ] Script de inicio ejecutándose (ver logs)
- [ ] Extensiones PHP instaladas (ver logs)
- [ ] Servidor iniciando correctamente (ver logs)

## 📝 Información Necesaria

Para diagnosticar mejor, necesito:

1. **Logs completos de Railway** desde que el contenedor inicia (últimas 50-100 líneas)
2. **¿Aparecen los mensajes del script de inicio?** (🚀, 📋, ✅)
3. **¿El servidor inicia?** (busca "Server running")
4. **¿Hay errores de PHP?** (cualquier mensaje de error)
5. **Variables de entorno** verificadas (sin valores sensibles)

## 💡 Nota

El script de inicio ahora incluye:
- Logs de debug para ver qué está pasando
- Verificación de que `artisan` existe
- Verificación de extensiones PHP
- Manejo correcto del puerto

Estos logs nos ayudarán a identificar exactamente dónde está fallando.

