# 🔧 Configuración para Backend Local

## ✅ Configuración Actual

La aplicación móvil está configurada para conectarse al backend local en desarrollo.

### URLs por Plataforma

- **Web:** `http://127.0.0.1:8000/api`
- **Android Emulador:** `http://10.0.2.2:8000/api`
- **iOS Emulador:** `http://127.0.0.1:8000/api`
- **Producción:** `https://wms-v9-production.up.railway.app/api`

## 🚀 Cómo Usar

### 1. Iniciar el Backend Local

```bash
cd backend
php artisan serve
```

El servidor se iniciará en `http://127.0.0.1:8000`

### 2. Iniciar la Aplicación Móvil

```bash
cd Movil
npm start
# O para web:
npm run web
```

### 3. Verificar la Conexión

En la consola deberías ver:
- `🌐 API Base URL: http://127.0.0.1:8000/api` (o la URL correspondiente)
- `🔧 Inicializando ApiService con baseURL: ...`

## 📱 Para Dispositivo Físico Android

Si estás usando un dispositivo físico Android, necesitas:

1. **Obtener tu IP local:**
   ```powershell
   # Windows
   ipconfig
   # Busca "IPv4 Address" (ejemplo: 192.168.1.100)
   ```

2. **Actualizar la configuración:**
   Edita `Movil/src/config/api.ts` y cambia:
   ```typescript
   } else if (Platform.OS === 'android') {
     // Para dispositivo físico, usa tu IP local
     return 'http://192.168.1.100:8000/api'; // Cambia por tu IP
   }
   ```

## 🔍 Debugging

### Ver Logs de la API

La aplicación tiene logs detallados:
- `🔐 Intentando login con: ...`
- `📤 POST Request: ...`
- `📥 POST Response: ...`
- `✅ Login exitoso` o `❌ Error en login`

### Verificar que el Backend Responde

```bash
# Probar el endpoint de login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'
```

## ⚠️ Problemas Comunes

### Error: "Network Error" o "Failed to fetch"
- **Causa:** El backend no está corriendo
- **Solución:** Asegúrate de que `php artisan serve` esté ejecutándose

### Error: "Connection refused"
- **Causa:** URL incorrecta o backend en otro puerto
- **Solución:** Verifica que el backend esté en `http://127.0.0.1:8000`

### Error: "CORS policy"
- **Causa:** El backend no permite el origen de la app móvil
- **Solución:** Las apps móviles no envían `Origin`, así que debería funcionar. Si persiste, verifica la configuración de CORS en el backend.

## ✅ Checklist

- [ ] Backend corriendo en `http://127.0.0.1:8000`
- [ ] URL de API correcta en los logs
- [ ] Credenciales correctas (admin/admin123)
- [ ] Consola abierta para ver logs
- [ ] Red local accesible (si usas dispositivo físico)

