# ✅ Backend Iniciando en Railway - Próximos Pasos

## 🎉 Estado Actual

Tu backend está iniciando en Railway. El mensaje que ves:
```
Server running on [http://0.0.0.0:8080]
```
Significa que Laravel está corriendo correctamente.

---

## 📝 Pasos Inmediatos

### 1. Esperar a que el Deployment Complete

1. **En Railway Dashboard:**
   - Ve a tu proyecto
   - En la pestaña **"Deployments"**
   - Espera a que el deployment cambie a estado **"Active"** o **"Success"**
   - Esto puede tomar 1-2 minutos

### 2. Obtener la URL del Backend

1. **En Railway:**
   - Ve a la pestaña **"Settings"**
   - Scroll hasta la sección **"Domains"**
   - Click en **"Generate Domain"** (si no hay uno)
   - Copia la URL generada (ej: `wms-backend-production.up.railway.app`)
   - **Anota esta URL** - la necesitarás para Vercel

### 3. Verificar que el Backend Funciona

1. **Abre una nueva pestaña** en tu navegador
2. **Prueba la URL:**
   ```
   https://tu-url-railway.railway.app/api
   ```
   O si tienes un endpoint de health:
   ```
   https://tu-url-railway.railway.app/api/health
   ```
3. **Deberías ver** una respuesta JSON o un error de autenticación (eso está bien, significa que el servidor responde)

---

## ⚙️ Configurar Variables de Entorno

### 4. Agregar Variables de Entorno en Railway

1. **En Railway Dashboard:**
   - Ve a tu proyecto
   - Click en el servicio (backend)
   - Ve a la pestaña **"Variables"**

2. **Agregar las siguientes variables:**

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=
DB_CONNECTION=sqlsrv
DB_HOST=tu-sql-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms
DB_USERNAME=tu-usuario
DB_PASSWORD=tu-password
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

**⚠️ IMPORTANTE:**
- Reemplaza `tu-sql-server.database.windows.net` con tu servidor SQL Server real
- Reemplaza `tu-usuario` y `tu-password` con tus credenciales reales
- Deja `APP_KEY` vacío por ahora (se generará automáticamente)

### 5. Generar APP_KEY

1. **En Railway:**
   - Después de agregar las variables, Railway reiniciará automáticamente
   - Ve a la pestaña **"Deployments"**
   - Click en el deployment más reciente
   - Click en **"View Logs"**

2. **Buscar APP_KEY en los logs:**
   - Busca una línea que diga: `Application key [base64:...] generated successfully`
   - O busca: `APP_KEY=base64:...`
   - Copia el valor completo (incluyendo `base64:`)

3. **Actualizar APP_KEY:**
   - Ve a **"Variables"**
   - Busca `APP_KEY`
   - Click en el ícono de editar
   - Pega el valor copiado
   - Guarda
   - Railway reiniciará automáticamente

---

## 🔍 Verificar Logs

### 6. Revisar Logs para Errores

1. **En Railway:**
   - Ve a **"Deployments"**
   - Click en el deployment más reciente
   - Click en **"View Logs"**

2. **Buscar errores comunes:**
   - ❌ `Database connection failed` → Verificar credenciales de DB
   - ❌ `APP_KEY not set` → Verificar que APP_KEY esté configurado
   - ❌ `Class not found` → Problema con composer
   - ✅ `Server running on [http://0.0.0.0:8080]` → Todo bien

---

## 📋 Checklist

- [ ] Deployment completado (estado "Active")
- [ ] URL del backend generada y anotada
- [ ] Variables de entorno agregadas
- [ ] APP_KEY generado y configurado
- [ ] Backend responde en la URL (probar en navegador)
- [ ] Logs sin errores críticos

---

## 🚀 Siguiente Paso: Desplegar Frontend en Vercel

Una vez que tengas:
- ✅ Backend funcionando en Railway
- ✅ URL del backend anotada
- ✅ APP_KEY configurado

**Continúa con el despliegue del frontend en Vercel** según `GUIA_DESPLIEGUE_PASO_A_PASO.md`

---

## 🆘 Si Hay Problemas

### Error: "Database connection failed"

**Solución:**
1. Verificar que `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` sean correctos
2. Verificar que el servidor SQL Server permita conexiones externas
3. Verificar firewall/reglas de red

### Error: "APP_KEY not set"

**Solución:**
1. Verificar que `APP_KEY` esté en las variables de entorno
2. Si está vacío, esperar a que se genere automáticamente
3. Revisar logs para ver el valor generado

### El servidor no responde

**Solución:**
1. Verificar que el deployment esté "Active"
2. Verificar logs para errores
3. Verificar que la URL sea correcta

---

**¿Necesitas ayuda con algún paso específico? Dime qué ves en Railway y te ayudo.**

