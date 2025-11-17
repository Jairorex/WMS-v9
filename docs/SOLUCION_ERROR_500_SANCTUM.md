# Solución Error 500 en Sanctum CSRF Cookie

## ⚠️ Problema

Error 500 al intentar obtener el CSRF cookie de Sanctum:
```
GET https://wms-v9-production.up.railway.app/sanctum/csrf-cookie 500 (Internal Server Error)
```

## 🔍 Causas Posibles

1. **Rutas de Sanctum no registradas**: Las rutas de Sanctum no estaban registradas en `routes/web.php`
2. **Base de datos de sesiones no configurada**: Si `SESSION_DRIVER=database`, la tabla `sessions` debe existir
3. **Error en el servidor**: Puede haber un error de PHP o configuración

## ✅ Soluciones Implementadas

### 1. Ruta de CSRF Cookie Agregada

Se agregó la ruta `/sanctum/csrf-cookie` en `routes/web.php` para manejar las peticiones de CSRF.

### 2. Manejo de Errores en el Frontend

El frontend ahora maneja errores de CSRF de forma elegante, ya que cuando usamos tokens Bearer, el CSRF cookie no es estrictamente necesario.

### 3. Verificar Configuración de Sesiones

Si el error persiste, verifica que:

#### En Railway - Variables de Entorno:

```env
SESSION_DRIVER=database
SESSION_LIFETIME=120
```

#### Verificar que la tabla `sessions` exista:

La tabla `sessions` debe existir en la base de datos. Si no existe, ejecuta:

```sql
CREATE TABLE [sessions] (
    [id] NVARCHAR(255) NOT NULL PRIMARY KEY,
    [user_id] BIGINT NULL,
    [ip_address] NVARCHAR(45) NULL,
    [user_agent] TEXT NULL,
    [payload] TEXT NOT NULL,
    [last_activity] INT NOT NULL,
    INDEX [sessions_user_id_index] ([user_id]),
    INDEX [sessions_last_activity_index] ([last_activity])
);
```

O ejecuta las migraciones de Laravel:

```bash
php artisan migrate
```

## 🔧 Solución Alternativa: Usar Tokens Bearer Sin CSRF

Si prefieres no usar CSRF cookies (recomendado para APIs con tokens Bearer), puedes:

### Opción 1: Deshabilitar CSRF en el Frontend

Modifica `frontend/src/contexts/AuthContext.tsx`:

```typescript
const login = async (login: string, password: string) => {
  try {
    // Comentar esta línea si no usas CSRF
    // await csrf();
    const response = await http.post('/api/auth/login', { usuario: login, password });
    // ... resto del código
  }
}
```

### Opción 2: Usar SESSION_DRIVER=file (Solo para desarrollo)

En desarrollo local, puedes usar:

```env
SESSION_DRIVER=file
```

Esto no requiere la tabla de sesiones, pero no es recomendado para producción.

## 📝 Verificación

### 1. Verificar que la Ruta Funcione

Prueba directamente en el navegador o con curl:

```bash
curl -I https://wms-v9-production.up.railway.app/sanctum/csrf-cookie
```

Debería responder con 200 OK.

### 2. Verificar Logs de Railway

1. Ve a Railway Dashboard
2. Selecciona tu servicio
3. Pestaña **Deployments** → Último deployment → **View Logs**
4. Busca errores relacionados con sesiones o CSRF

### 3. Verificar Variables de Entorno

Asegúrate de que en Railway tengas:

```env
APP_ENV=production
SESSION_DRIVER=database
SESSION_LIFETIME=120
DB_CONNECTION=sqlsrv
# ... resto de configuración de DB
```

## 🚨 Troubleshooting

### Error: "Table 'sessions' doesn't exist"

**Solución**: Ejecuta las migraciones de Laravel o crea la tabla manualmente (ver arriba).

### Error: "SQLSTATE[08001]: Connection error"

**Solución**: Verifica la configuración de la base de datos en Railway.

### Error: "500 Internal Server Error" sin más detalles

**Solución**:
1. Revisa los logs de Railway
2. Verifica que `APP_DEBUG=false` en producción (pero temporalmente puedes ponerlo en `true` para ver el error)
3. Verifica que todas las variables de entorno estén configuradas

## 📌 Nota Importante

**Para APIs con autenticación por tokens Bearer, el CSRF cookie NO es necesario**. El CSRF cookie es útil cuando usas autenticación basada en sesiones (cookies), pero cuando usas tokens Bearer en el header `Authorization`, no necesitas CSRF.

El código ahora maneja ambos casos:
- Si el CSRF cookie funciona, lo usa
- Si falla, continúa con la autenticación por token (que es lo que realmente necesitas)

