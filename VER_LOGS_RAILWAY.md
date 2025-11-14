# Cómo Ver los Logs de Railway para Diagnosticar Errores

## 🔍 Ver Logs en Railway

Para ver el error específico que está causando el 500:

### Método 1: Desde Railway Dashboard

1. Ve a [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu proyecto
3. Selecciona el servicio del backend
4. Ve a la pestaña **Deployments**
5. Haz clic en el deployment más reciente
6. Haz clic en **View Logs** o **View Build Logs**
7. Busca el error específico (debería mostrar el mensaje de error de PHP)

### Método 2: Logs en Tiempo Real

1. En Railway Dashboard → tu servicio
2. Pestaña **Metrics** o **Logs**
3. Aquí verás los logs en tiempo real

### Método 3: Usar Railway CLI

```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login
railway login

# Ver logs
railway logs
```

## 📋 Qué Buscar en los Logs

Busca mensajes como:
- `SQLSTATE[...]` - Errores de base de datos
- `Call to undefined function` - Funciones no definidas
- `Class not found` - Clases no encontradas
- `Syntax error` - Errores de sintaxis
- `Fatal error` - Errores fatales de PHP

## 🔧 Solución Temporal: Deshabilitar CSRF Cookie

Si el error persiste, puedes deshabilitar completamente la llamada a CSRF en el frontend:

**En `frontend/src/contexts/AuthContext.tsx`:**

```typescript
const login = async (login: string, password: string) => {
  try {
    // Comentar esta línea temporalmente
    // await csrf();
    const response = await http.post('/api/auth/login', { usuario: login, password });
    // ... resto del código
  }
}
```

Esto es seguro porque estás usando tokens Bearer, no cookies de sesión.

