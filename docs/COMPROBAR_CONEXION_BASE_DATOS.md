# 🔍 Comprobar Conexión a Base de Datos

## 📋 Script de Prueba

Se ha creado un script para probar la conexión a la base de datos:
- `backend/test_db_connection.php`

## 🚀 Ejecutar la Prueba

### Opción 1: Desde el Backend Local

```bash
cd backend
php test_db_connection.php
```

### Opción 2: Usando Artisan Tinker

```bash
cd backend
php artisan tinker
```

Luego en tinker:
```php
DB::connection()->getPdo();
DB::select("SELECT @@VERSION AS version, DB_NAME() AS database_name");
```

### Opción 3: Desde Railway (si tienes acceso SSH)

Si Railway permite acceso SSH, puedes ejecutar:
```bash
php test_db_connection.php
```

## ✅ Lo que Verifica el Script

1. **Configuración de conexión:**
   - Connection type (sqlsrv)
   - Host, Port, Database
   - Username (oculto)
   - Password (parcialmente oculto)

2. **Conexión PDO:**
   - Intenta establecer conexión
   - Obtiene información del driver
   - Obtiene versión del servidor

3. **Consulta simple:**
   - Ejecuta `SELECT @@VERSION`
   - Verifica nombre de la base de datos
   - Verifica usuario actual

4. **Tablas importantes:**
   - `usuarios`
   - `personal_access_tokens`
   - `sessions`
   - `productos`
   - `inventario`
   - `tareas`

## 🔍 Verificar Variables de Entorno

Asegúrate de que estas variables estén configuradas:

### En Local (.env):
```env
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
```

### En Railway (Variables):
```
DB_CONNECTION=sqlsrv
DB_HOST=wms-escasan-server.database.windows.net
DB_PORT=1433
DB_DATABASE=wms_escasan
DB_USERNAME=wmsadmin
DB_PASSWORD=Escasan123
```

## ❌ Errores Comunes

### Error: "SQLSTATE[08001]"
**Causa:** No se puede conectar al servidor
**Solución:**
- Verifica que el servidor de Azure SQL esté accesible
- Verifica que el firewall de Azure permita conexiones desde tu IP o Railway
- Verifica que las credenciales sean correctas

### Error: "SQLSTATE[28000]"
**Causa:** Credenciales incorrectas
**Solución:**
- Verifica `DB_USERNAME` y `DB_PASSWORD`
- Asegúrate de que no haya espacios extra

### Error: "Class 'PDO' not found"
**Causa:** Extensión PHP faltante
**Solución:**
- Instala extensiones `pdo_sqlsrv` y `sqlsrv`
- En Railway, verifica que el Dockerfile incluya estas extensiones

### Error: "Database 'wms_escasan' does not exist"
**Causa:** Base de datos no existe o nombre incorrecto
**Solución:**
- Verifica el nombre de la base de datos en Azure SQL
- Asegúrate de que `DB_DATABASE` sea correcto

## 🔧 Verificar desde Azure SQL

También puedes verificar la conexión directamente desde Azure SQL Database:

1. Ve a Azure Portal
2. Abre tu SQL Database
3. Usa el "Query editor"
4. Ejecuta:
   ```sql
   SELECT @@VERSION AS version, 
          DB_NAME() AS database_name, 
          SYSTEM_USER AS current_user;
   ```

## 📊 Resultado Esperado

Si la conexión es exitosa, deberías ver:

```
🔍 Probando conexión a la base de datos...

📋 Configuración:
   Connection: sqlsrv
   Host: wms-escasan-server.database.windows.net
   Port: 1433
   Database: wms_escasan
   Username: wmsadmin
   Password: ***123

🔌 Intentando conectar...
✅ Conexión exitosa!

📊 Información de la conexión:
   Driver: sqlsrv
   Server Version: ...
   Client Version: ...

🔍 Probando consulta simple...
✅ Consulta exitosa!
   Database: wms_escasan
   User: wmsadmin
   SQL Server Version: ...

📋 Verificando tablas importantes...
   ✅ usuarios - Existe
   ✅ personal_access_tokens - Existe
   ✅ sessions - Existe
   ✅ productos - Existe
   ✅ inventario - Existe
   ✅ tareas - Existe

✅ Todas las pruebas completadas exitosamente!
```

## 🚨 Si Hay Errores

1. **Revisa los logs de Railway** para ver errores de conexión
2. **Verifica el firewall de Azure SQL** - debe permitir conexiones desde Railway
3. **Verifica las credenciales** en Railway Variables
4. **Prueba la conexión localmente** primero para aislar el problema

