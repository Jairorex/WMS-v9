# 🔍 Verificar Error 500 Después de Agregar APP_KEY

## ❌ Problema

Después de agregar `APP_KEY` y todas las variables de entorno, el error 500 persiste.

## 🔍 Pasos de Diagnóstico

### 1. Verificar Logs de Railway

**CRÍTICO:** Necesitamos ver el error exacto en los logs de Railway.

1. Ve a Railway Dashboard → Tu Proyecto
2. Haz clic en **Logs** o **Deployments**
3. Busca los errores más recientes
4. Copia el mensaje de error completo

**Busca específicamente:**
- `SQLSTATE` - Error de base de datos
- `Table 'personal_access_tokens' doesn't exist` - Tabla faltante
- `Class 'PDO' not found` - Extensión PHP faltante
- `No application encryption key` - APP_KEY no se está leyendo

### 2. Verificar que APP_KEY se Está Leyendo

En Railway, verifica:
1. Ve a **Variables**
2. Busca `APP_KEY`
3. Verifica que el valor sea exactamente:
   ```
   base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
   ```
4. **NO** debe tener espacios antes o después
5. **NO** debe tener comillas

### 3. Verificar Tabla personal_access_tokens

El error 500 puede ser causado por la tabla `personal_access_tokens` faltante.

**Verificar en Azure SQL:**
```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'personal_access_tokens';
```

**Si no existe, crearla:**
Ejecuta el script: `sql/CREAR_TABLA_PERSONAL_ACCESS_TOKENS.sql`

### 4. Verificar Conexión a Base de Datos desde Railway

El error puede ser que Railway no puede conectar a Azure SQL.

**Verificar en Railway:**
1. Ve a **Variables**
2. Verifica estas variables:
   ```
   DB_CONNECTION=sqlsrv
   DB_HOST=wms-escasan-server.database.windows.net
   DB_PORT=1433
   DB_DATABASE=wms_escasan
   DB_USERNAME=wmsadmin
   DB_PASSWORD=Escasan123
   ```

**Verificar Firewall de Azure SQL:**
1. Ve a Azure Portal
2. Abre tu SQL Database
3. Ve a **Networking** o **Firewall rules**
4. Verifica que haya una regla que permita conexiones desde Railway
5. O agrega una regla temporal que permita todas las IPs (0.0.0.0 - 255.255.255.255)

### 5. Verificar Extensiones PHP en Railway

Railway necesita las extensiones PHP para SQL Server.

**Verificar en Railway:**
- El Dockerfile o configuración debe incluir:
  - `pdo_sqlsrv`
  - `sqlsrv`

Si no están instaladas, el error será: `Class 'PDO' not found` o `SQLSTATE[IMSSP]`

### 6. Redesplegar Manualmente

Después de agregar/modificar variables:

1. Ve a Railway Dashboard → **Deployments**
2. Haz clic en **Redeploy** en el deployment más reciente
3. Espera 2-3 minutos
4. Prueba nuevamente

## 🚨 Errores Comunes y Soluciones

### Error: "Table 'personal_access_tokens' doesn't exist"
**Solución:**
1. Ejecuta `sql/CREAR_TABLA_PERSONAL_ACCESS_TOKENS.sql` en Azure SQL
2. O cambia `SESSION_DRIVER=file` temporalmente

### Error: "SQLSTATE[08001]"
**Solución:**
1. Verifica credenciales de Azure SQL en Railway
2. Verifica firewall de Azure SQL
3. Verifica que el servidor esté accesible

### Error: "Class 'PDO' not found"
**Solución:**
1. Verifica que Railway tenga las extensiones PHP instaladas
2. Revisa el Dockerfile de Railway

### Error: "No application encryption key"
**Solución:**
1. Verifica que `APP_KEY` esté en Railway Variables
2. Verifica que no tenga espacios o comillas
3. Redesplega manualmente

## 📋 Checklist de Verificación

- [ ] Logs de Railway revisados - ¿Cuál es el error exacto?
- [ ] `APP_KEY` está en Railway Variables con el valor correcto
- [ ] Tabla `personal_access_tokens` existe en Azure SQL
- [ ] Variables de base de datos son correctas en Railway
- [ ] Firewall de Azure SQL permite conexiones desde Railway
- [ ] Servicio redesplegado manualmente después de cambios
- [ ] Extensiones PHP instaladas en Railway

## 🔧 Solución Rápida: Cambiar SESSION_DRIVER

Si el problema es la tabla `sessions`, cambia temporalmente:

En Railway Variables:
```
SESSION_DRIVER=file
```

Esto no requiere la tabla `sessions` en la base de datos.

## 📝 Información Necesaria

Para diagnosticar mejor, necesito:

1. **Logs de Railway** - El error exacto de los últimos logs
2. **Variables de Railway** - Verifica que todas estén correctas (sin valores sensibles)
3. **Resultado de verificar tabla** - ¿Existe `personal_access_tokens`?
4. **Firewall de Azure SQL** - ¿Permite conexiones desde Railway?

## 🚀 Próximos Pasos

1. **Revisa los logs de Railway** y comparte el error exacto
2. **Verifica la tabla personal_access_tokens** en Azure SQL
3. **Verifica el firewall de Azure SQL**
4. **Redesplega manualmente** el servicio en Railway

