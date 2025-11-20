# 🔍 Diagnosticar Error 502 Bad Gateway

## ❌ Error

```
GET https://wms-v9-production.up.railway.app/sanctum/csrf-cookie net::ERR_FAILED 502 (Bad Gateway)
```

## 🔍 Causa

El error `502 Bad Gateway` indica que:
1. **El backend no está respondiendo** - El servidor podría estar crasheando
2. **El servidor no está iniciando** - Podría haber un error al iniciar
3. **El servidor está caído** - El proceso podría haberse detenido

## ✅ Solución Implementada

He simplificado el middleware CORS para:
1. **Reducir la complejidad** - Menos código = menos posibilidades de error
2. **Priorizar Vercel** - La verificación de Vercel es lo primero
3. **Manejar errores mejor** - Código más simple es más fácil de depurar

## 🚀 Próximos Pasos

### 1. Verificar Logs de Railway (CRÍTICO)

**Este es el paso más importante.** Necesitamos ver qué está pasando con el servidor.

1. Ve a Railway Dashboard → Tu Proyecto
2. Haz clic en **Logs** (no Deployments)
3. Busca los logs más recientes
4. **Copia los logs completos** desde que el contenedor inicia

**Busca específicamente:**
- `🚀 Iniciando servidor Laravel en puerto ...` - ¿Aparece este mensaje?
- `✅ Iniciando servidor...` - ¿Aparece este mensaje?
- `Server running on [http://0.0.0.0:...]` - ¿El servidor inició?
- `❌ Error:` - ¿Hay algún error?
- `Fatal error` - ¿Hay errores fatales de PHP?
- `Unsupported operand types` - ¿Error de tipo?
- `No application encryption key` - ¿APP_KEY faltante?
- `could not find driver` - ¿Extensiones PHP faltantes?
- Cualquier mensaje de crash o reinicio

### 2. Verificar Estado del Deployment

1. Ve a Railway Dashboard → Deployments
2. Verifica el estado del último deployment:
   - ✅ **Active** - El deployment está activo
   - ⏳ **Building** - Todavía está construyendo
   - ❌ **Failed** - El build falló
   - ⚠️ **Stopped** - El servicio está detenido

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
PORT=8080
```

### 4. Verificar que el Servidor Esté Funcionando

Después de verificar los logs:

1. **Si el servidor está funcionando:**
   - El error 502 debería desaparecer
   - El login debería funcionar

2. **Si el servidor NO está funcionando:**
   - Revisa los logs para encontrar el error
   - Comparte los logs completos para diagnosticar

## 📋 Checklist de Verificación

- [ ] Logs de Railway revisados - ¿Qué error aparece?
- [ ] Estado del deployment verificado - ¿Está activo?
- [ ] `APP_KEY` configurado en Railway Variables
- [ ] Todas las variables de entorno configuradas
- [ ] Build completado exitosamente
- [ ] Script de inicio ejecutándose (ver logs)
- [ ] Extensiones PHP instaladas (ver logs)
- [ ] Servidor iniciando correctamente (ver logs)

## 🚨 Errores Comunes y Soluciones

### Error: "No application encryption key"
**Causa:** `APP_KEY` no está configurado
**Solución:** Agrega `APP_KEY` en Railway Variables

### Error: "could not find driver"
**Causa:** Extensiones PHP no instaladas
**Solución:** Verifica que el Dockerfile se haya usado correctamente

### Error: "Unsupported operand types"
**Causa:** Error de tipo en el puerto
**Solución:** Ya corregido en el script de inicio

### Error: El servidor inicia pero crashea inmediatamente
**Causa:** Error en el código o configuración
**Solución:** Revisa los logs completos de Railway

## 📝 Información Necesaria

Para diagnosticar mejor, necesito:

1. **Logs completos de Railway** desde que el contenedor inicia (últimas 50-100 líneas)
2. **Estado del deployment** - ¿Está activo o falló?
3. **¿Aparecen los mensajes del script de inicio?** (🚀, 📋, ✅)
4. **¿El servidor inicia?** (busca "Server running")
5. **¿Hay errores de PHP?** (cualquier mensaje de error)

## 💡 Nota

El middleware CORS ahora está simplificado para:
- Reducir la complejidad
- Priorizar dominios de Vercel
- Manejar errores mejor

Esto debería ayudar a evitar errores que causen que el servidor crashee.

