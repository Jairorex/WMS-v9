# 🔍 Guía de Debug para Login

## 📋 Pasos para depurar el problema de login

### 1. **Abrir la Consola del Navegador (Web)**
   - Presiona `F12` en el navegador
   - Ve a la pestaña "Console"
   - Busca los logs que empiezan con:
     - `🌐 API Base URL:`
     - `🔧 Inicializando ApiService`
     - `🔐 Intentando login con:`
     - `📤 POST Request:`
     - `📥 POST Response:`
     - `✅` o `❌` para ver el resultado

### 2. **Verificar la URL de la API**
   - Deberías ver: `🌐 API Base URL: http://localhost:8000/api` (en web)
   - O: `🌐 API Base URL: https://wms-v9-production.up.railway.app/api` (en producción)

### 3. **Verificar la Petición**
   - Deberías ver: `📤 POST Request: { url: '/auth/login', data: { usuario: '...', password: '...' } }`

### 4. **Verificar la Respuesta**
   - Deberías ver: `📥 POST Response: { success: true, data: { usuario: {...}, token: "..." } }`
   - O un error si algo falla

### 5. **Errores Comunes**

#### Error: "Network Error" o "Failed to fetch"
   - **Causa:** El backend no está corriendo o la URL es incorrecta
   - **Solución:** 
     - Verifica que el backend esté corriendo en `http://localhost:8000`
     - O cambia la URL en `src/config/api.ts` para usar la API de producción

#### Error: "401 Unauthorized"
   - **Causa:** Credenciales incorrectas
   - **Solución:** Verifica que el usuario y contraseña sean correctos

#### Error: "La respuesta del servidor no tiene el formato esperado"
   - **Causa:** La estructura de la respuesta no coincide
   - **Solución:** Revisa los logs para ver qué estructura tiene la respuesta real

#### Error: "apiResponse.data es undefined"
   - **Causa:** La API no está devolviendo `data` en la respuesta
   - **Solución:** Revisa la estructura de la respuesta en los logs

## 🔧 Cambiar la URL de la API

Si necesitas cambiar la URL de la API (por ejemplo, para usar la API de producción):

1. Abre `Movil/src/config/api.ts`
2. Modifica la función `getApiBaseUrl()`:

```typescript
const getApiBaseUrl = () => {
  // Para usar siempre la API de producción:
  return 'https://wms-v9-production.up.railway.app/api';
  
  // O para desarrollo local:
  // return 'http://localhost:8000/api';
};
```

## 📝 Información que necesito

Cuando pruebes el login, comparte:

1. **Los logs de la consola** (especialmente los que empiezan con emojis)
2. **El mensaje de error exacto** (si hay alguno)
3. **La URL que se está usando** (debería aparecer en los logs)
4. **Si el backend está corriendo localmente** o si estás usando la API de producción

## ✅ Checklist

- [ ] Backend corriendo (si usas localhost)
- [ ] URL de API correcta en los logs
- [ ] Credenciales correctas
- [ ] Consola del navegador abierta (F12)
- [ ] Logs visibles en la consola

