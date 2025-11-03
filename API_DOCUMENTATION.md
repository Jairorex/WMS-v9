# 📱 Documentación de la API WMS Escasan

## 🚀 Resumen

La API REST está construida con **Laravel 11** y utiliza **Laravel Sanctum** para autenticación basada en tokens. Está lista para desarrollo móvil, pero requiere algunos ajustes menores en CORS.

---

## 🔐 Autenticación

### Flujo de Autenticación

La API utiliza **Laravel Sanctum** con autenticación por tokens Bearer.

#### 1. Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "usuario": "admin",
  "password": "admin123"
}
```

**Respuesta exitosa:**
```json
{
  "usuario": {
    "id_usuario": 1,
    "nombre": "Administrador",
    "usuario": "admin",
    "email": "admin@escasan.com",
    "rol_id": 1,
    "activo": true,
    "rol": {
      "id_rol": 1,
      "nombre": "Administrador",
      "descripcion": "Rol administrativo"
    }
  },
  "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "message": "Login exitoso"
}
```

#### 2. Usar el Token
Después del login, incluye el token en todas las peticiones protegidas:

```http
Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 3. Obtener Usuario Actual
```http
GET /api/me
Authorization: Bearer {token}
```

#### 4. Logout
```http
POST /api/auth/logout
Authorization: Bearer {token}
```

---

## 📋 Endpoints Principales

### Base URL
```
Desarrollo local: http://127.0.0.1:8000
Producción: (configurar según entorno)
```

Todas las rutas de la API están bajo el prefijo `/api/`

### Rutas Públicas (sin autenticación)
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/roles` - Listar roles
- `GET /api/estados-producto` - Listar estados de producto
- `GET /api/unidades-medida-catalogos` - Catálogo de unidades de medida

### Rutas Protegidas (requieren token)

#### Dashboard
- `GET /api/dashboard/estadisticas` - Estadísticas del dashboard
- `GET /api/dashboard/actividad` - Actividad reciente
- `GET /api/dashboard/resumen` - Resumen general

#### Productos
- `GET /api/productos` - Listar productos (con paginación)
- `POST /api/productos` - Crear producto
- `GET /api/productos/{id}` - Ver producto
- `PUT /api/productos/{id}` - Actualizar producto
- `DELETE /api/productos/{id}` - Eliminar producto
- `PATCH /api/productos/{id}/activar` - Activar producto
- `PATCH /api/productos/{id}/desactivar` - Desactivar producto
- `GET /api/productos-catalogos` - Catálogos relacionados

#### Inventario
- `GET /api/inventario` - Listar inventario
- `POST /api/inventario` - Crear registro de inventario
- `GET /api/inventario/{id}` - Ver registro
- `PUT /api/inventario/{id}` - Actualizar
- `DELETE /api/inventario/{id}` - Eliminar
- `PATCH /api/inventario/{id}/ajustar` - Ajustar cantidad

#### Tareas
- `GET /api/tareas` - Listar tareas
- `POST /api/tareas` - Crear tarea
- `GET /api/tareas/{id}` - Ver tarea
- `PUT /api/tareas/{id}` - Actualizar tarea
- `DELETE /api/tareas/{id}` - Eliminar tarea
- `PATCH /api/tareas/{id}/asignar` - Asignar tarea
- `PATCH /api/tareas/{id}/cambiar-estado` - Cambiar estado

#### Picking
- `GET /api/picking` - Listar pickings
- `POST /api/picking` - Crear picking
- `GET /api/picking/{id}` - Ver picking
- `PUT /api/picking/{id}` - Actualizar picking
- `DELETE /api/picking/{id}` - Eliminar picking
- `PATCH /api/picking/{id}/asignar` - Asignar picking
- `PATCH /api/picking/{id}/completar` - Completar picking
- `PATCH /api/picking/{id}/cancelar` - Cancelar picking

#### Órdenes de Salida
- `GET /api/ordenes-salida` - Listar órdenes
- `POST /api/ordenes-salida` - Crear orden
- `GET /api/ordenes-salida/{id}` - Ver orden
- `PUT /api/ordenes-salida/{id}` - Actualizar orden
- `PATCH /api/ordenes-salida/{id}/confirmar` - Confirmar orden
- `PATCH /api/ordenes-salida/{id}/cancelar` - Cancelar orden

#### Ubicaciones
- `GET /api/ubicaciones` - Listar ubicaciones
- `POST /api/ubicaciones` - Crear ubicación
- `GET /api/ubicaciones/{id}` - Ver ubicación
- `PUT /api/ubicaciones/{id}` - Actualizar ubicación
- `PATCH /api/ubicaciones/{id}/activar` - Activar ubicación
- `PATCH /api/ubicaciones/{id}/desactivar` - Desactivar ubicación

#### Incidencias
- `GET /api/incidencias` - Listar incidencias
- `POST /api/incidencias` - Crear incidencia
- `GET /api/incidencias/{id}` - Ver incidencia
- `PUT /api/incidencias/{id}` - Actualizar incidencia
- `PATCH /api/incidencias/{id}/resolver` - Resolver incidencia
- `PATCH /api/incidencias/{id}/reabrir` - Reabrir incidencia

#### Usuarios
- `GET /api/usuarios` - Listar usuarios
- `POST /api/usuarios` - Crear usuario
- `GET /api/usuarios/{id}` - Ver usuario
- `PUT /api/usuarios/{id}` - Actualizar usuario
- `PATCH /api/usuarios/{id}/toggle-status` - Cambiar estado

---

## 📱 Preparación para Desarrollo Móvil

### ✅ Lo que ya está listo:
1. ✅ Autenticación por tokens (Sanctum)
2. ✅ Rutas API RESTful organizadas
3. ✅ Respuestas JSON estructuradas
4. ✅ Middleware CORS configurado (parcialmente)

### ⚠️ Ajustes necesarios para móvil:

#### 1. Actualizar CORS para aceptar cualquier origen (móvil)

**Archivo:** `backend/app/Http/Middleware/CorsMiddleware.php`

Actualmente solo permite:
```php
'http://localhost:5173',
'http://localhost:5174',
'http://127.0.0.1:5173',
'http://127.0.0.1:5174',
```

**Para móvil necesitas:**

```php
// Permitir cualquier origen para apps móviles
$allowedOrigin = $origin ?? '*';
```

O mejor aún, configurar dominios específicos según el entorno.

#### 2. Configurar la URL base de la API

**Android (Kotlin/Java):**
```kotlin
const val BASE_URL = "http://TU_IP_LOCAL:8000/api"
// Para emulador Android usar: "http://10.0.2.2:8000/api"
```

**iOS (Swift):**
```swift
let baseURL = "http://TU_IP_LOCAL:8000/api"
```

**React Native:**
```javascript
const API_URL = __DEV__ 
  ? 'http://TU_IP_LOCAL:8000/api' 
  : 'https://api.escasan.com/api';
```

#### 3. Manejo del token en móvil

**Guardar token:**
- Android: `SharedPreferences` o `SecureStore`
- iOS: `Keychain`
- React Native: `@react-native-async-storage/async-storage` o `expo-secure-store`

**Incluir en headers:**
```javascript
headers: {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}
```

---

## 🔧 Ejemplo de Cliente HTTP (React Native)

```typescript
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_URL = 'http://TU_IP:8000/api';

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

// Interceptor para agregar token
apiClient.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor para manejar errores 401
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await AsyncStorage.removeItem('token');
      // Redirigir al login
    }
    return Promise.reject(error);
  }
);

// Ejemplo de uso
export const login = async (usuario: string, password: string) => {
  const response = await apiClient.post('/auth/login', {
    usuario,
    password,
  });
  
  const { token, usuario: userData } = response.data;
  await AsyncStorage.setItem('token', token);
  return userData;
};

export const getProductos = async () => {
  const response = await apiClient.get('/productos');
  return response.data;
};
```

---

## 📊 Formato de Respuestas

### Respuesta exitosa con datos:
```json
{
  "data": [...],
  "current_page": 1,
  "per_page": 15,
  "total": 100,
  "last_page": 7
}
```

### Respuesta de error:
```json
{
  "message": "Mensaje de error",
  "errors": {
    "campo": ["Error específico del campo"]
  }
}
```

---

## 🚀 ¿Puedes empezar a desarrollar en móvil?

### ✅ **SÍ, puedes empezar ahora mismo**

La API está lista, solo necesitas:

1. **Ajustar CORS** para permitir tu app móvil (ver arriba)
2. **Configurar la URL** de la API en tu app
3. **Implementar el cliente HTTP** con manejo de tokens
4. **Empezar a consumir endpoints**

### 📝 Checklist antes de producción móvil:

- [ ] Actualizar CORS para producción
- [ ] Configurar HTTPS (obligatorio en producción)
- [ ] Configurar dominio de API en producción
- [ ] Implementar refresh tokens (opcional, pero recomendado)
- [ ] Configurar timeouts y retry logic
- [ ] Manejar offline mode (cache local)

---

## 🆘 Soporte

Para más detalles sobre endpoints específicos, revisa:
- `backend/routes/api.php` - Todas las rutas disponibles
- `backend/app/Http/Controllers/Api/` - Lógica de los controladores

---

## 📝 Notas Importantes

1. **Paginación**: La mayoría de endpoints `GET` soportan `?page=1&per_page=15`
2. **Filtros**: Muchos endpoints aceptan query parameters para filtrar
3. **Tokens**: No expiran por defecto (configurable en `config/sanctum.php`)
4. **CORS**: Actualmente limitado a localhost, ajustar para móvil

