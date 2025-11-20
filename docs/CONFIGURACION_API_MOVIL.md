# 📱 Configuración de API para Desarrollo Móvil

## 🔗 URLs de la API

### Para Emulador Android (Android Studio)

```
http://10.0.2.2:8000/api
```

### Para Emulador iOS (Xcode)

```
http://localhost:8000/api
```

### Para Dispositivo Físico

Obtén tu IP local y usa:

```
http://TU_IP_LOCAL:8000/api
```

**Ejemplo:**

```bash
# Windows
ipconfig
# Busca "IPv4 Address" (ejemplo: 192.168.1.100)

# Linux/macOS
ifconfig
# Busca "inet" (ejemplo: 192.168.1.100)
```

**URL completa:** `http://192.168.1.100:8000/api`

---

## 📋 Formato de Respuestas de la API

### ✅ Respuesta Exitosa (Estándar)

```json
{
  "success": true,
  "message": "Mensaje descriptivo",
  "data": {
    /* tus datos aquí */
  }
}
```

### ✅ Respuesta Paginada

```json
{
  "success": true,
  "message": "Tareas obtenidas exitosamente",
  "data": [
    /* array de tareas */
  ],
  "meta": {
    "total": 100,
    "per_page": 15,
    "current_page": 1,
    "last_page": 7,
    "from": 1,
    "to": 15
  }
}
```

### ❌ Respuesta de Error

```json
{
  "success": false,
  "message": "Mensaje de error",
  "errors": {
    "campo": ["Error específico del campo"]
  }
}
```

---

## 🔐 Endpoint de Autenticación

### POST `/api/auth/login`

**Request:**

```json
{
  "usuario": "admin",
  "password": "admin123"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "usuario": {
      "id_usuario": 1,
      "nombre": "Administrador",
      "usuario": "admin",
      "email": "admin@escasan.com",
      "activo": true,
      "rol_id": 1,
      "rol": {
        "id_rol": 1,
        "nombre": "Administrador",
        "codigo": "ADMIN"
      },
      "ultimo_login": "2024-01-15T10:30:00.000000Z"
    },
    "token": "1|abc123def456ghi789..."
  }
}
```

**Response Error (401):**

```json
{
  "success": false,
  "message": "Las credenciales proporcionadas son incorrectas.",
  "errors": {
    "usuario": ["Las credenciales proporcionadas son incorrectas."]
  }
}
```

---

### GET `/api/auth/me`

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Usuario obtenido exitosamente",
  "data": {
    "usuario": {
      "id_usuario": 1,
      "nombre": "Administrador",
      "usuario": "admin",
      "email": "admin@escasan.com",
      "activo": true,
      "rol_id": 1,
      "rol": {
        "id_rol": 1,
        "nombre": "Administrador",
        "codigo": "ADMIN"
      }
    }
  }
}
```

---

### POST `/api/auth/logout`

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Logout exitoso",
  "data": null
}
```

---

## 📦 Endpoint de Tareas

### GET `/api/tareas`

**Query Parameters:**

- `page` (int): Número de página (default: 1)
- `per_page` (int): Elementos por página (default: 15)
- `q` (string): Búsqueda general
- `tipo` (int|string): ID o código de tipo de tarea
- `estado` (int|string): ID o código de estado
- `prioridad` (string): Prioridad
- `usuario_asignado` (int): ID de usuario asignado
- `zona` (string): Zona
- `fecha_inicio` (date): Fecha inicio
- `fecha_fin` (date): Fecha fin
- `desde` (date): Alias de fecha_inicio
- `hasta` (date): Alias de fecha_fin
- `vencidas` (boolean): Solo tareas vencidas
- `order_by` (string): Campo para ordenar (default: fecha_creacion)
- `order_dir` (string): Dirección (asc|desc, default: desc)
- `paginate` (boolean): Usar paginación (default: true)

**Example:**

```
GET /api/tareas?per_page=10&estado=EN_PROCESO&page=1
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Tareas obtenidas exitosamente",
  "data": [
    {
      "id_tarea": 1,
      "tipo_tarea_id": 1,
      "estado_tarea_id": 2,
      "prioridad": "Alta",
      "descripcion": "Picking de orden #123",
      "creado_por": 1,
      "fecha_creacion": "2024-01-15T10:00:00.000000Z",
      "fecha_vencimiento": "2024-01-20T10:00:00.000000Z",
      "fecha_cierre": null,
      "tipo": {
        "id_tipo_tarea": 1,
        "codigo": "PICKING",
        "nombre": "Picking"
      },
      "estado": {
        "id_estado_tarea": 2,
        "codigo": "EN_PROCESO",
        "nombre": "En Proceso"
      },
      "creador": {
        "id_usuario": 1,
        "nombre": "Administrador"
      },
      "usuarios": [
        {
          "id_usuario": 2,
          "nombre": "Operario 1",
          "usuario": "operario1",
          "pivot": {
            "es_responsable": true,
            "asignado_desde": "2024-01-15T10:00:00.000000Z"
          }
        }
      ],
      "detalles": [
        {
          "id_detalle": 1,
          "id_producto": 10,
          "cantidad_solicitada": 5,
          "cantidad_confirmada": 0,
          "producto": {
            "nombre": "Producto A",
            "codigo_barra": "1234567890123"
          }
        }
      ]
    }
  ],
  "meta": {
    "total": 25,
    "per_page": 10,
    "current_page": 1,
    "last_page": 3,
    "from": 1,
    "to": 10
  }
}
```

---

## 👤 Estructura de Datos

### Usuario

```typescript
interface Usuario {
  id_usuario: number;
  nombre: string;
  usuario: string;          // Campo para login (NO email)
  email: string;           // Email opcional
  activo: boolean;
  rol_id: number;
  rol?: {
    id_rol: number;
    nombre: string;
    codigo: string;
  };
  ultimo_login?: string;
}
```

**Nota:** El login acepta tanto `usuario` como `email` en el campo `usuario` del request.

---

### Tarea

```typescript
interface Tarea {
  id_tarea: number;
  tipo_tarea_id: number;
  estado_tarea_id: number;
  prioridad: string;       // "Alta", "Media", "Baja"
  descripcion: string;
  creado_por: number;
  fecha_creacion: string;
  fecha_vencimiento?: string;
  fecha_cierre?: string;
  tipo?: {
    id_tipo_tarea: number;
    codigo: string;
    nombre: string;
  };
  estado?: {
    id_estado_tarea: number;
    codigo: string;
    nombre: string;
  };
  creador?: {
    id_usuario: number;
    nombre: string;
  };
  usuarios?: Array<{
    id_usuario: number;
    nombre: string;
    usuario: string;
    pivot: {
      es_responsable: boolean;
      asignado_desde: string;
      asignado_hasta?: string;
    };
  }>;
  detalles?: Array<{
    id_detalle: number;
    id_producto: number;
    cantidad_solicitada: number;
    cantidad_confirmada: number;
    producto?: {
      nombre: string;
      codigo_barra?: string;
    };
  }>;
}
```

---

## 🔧 Configuración en el Cliente Móvil

La aplicación móvil ya está configurada para:

1. **Detectar automáticamente el entorno** (emulador Android/iOS o dispositivo físico)
2. **Manejar el formato estandarizado** de respuestas (`success`, `message`, `data`)
3. **Extraer automáticamente los datos** de la respuesta
4. **Manejar errores** de forma consistente

### Archivos Actualizados

- ✅ `src/config/api.ts` - Detección automática de URL según plataforma
- ✅ `src/services/api.ts` - Manejo del formato estandarizado de respuestas
- ✅ `src/types/api.ts` - Tipos TypeScript actualizados
- ✅ `src/contexts/AuthContext.tsx` - Actualizado para el nuevo formato
- ✅ `src/screens/main/TareasScreen.tsx` - Manejo correcto de estructura de datos
- ✅ `src/screens/main/ProductosScreen.tsx` - Actualizado
- ✅ `src/screens/detail/*` - Pantallas de detalle actualizadas

---

## 🧪 Pruebas Rápidas

### 1. Probar Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'
```

### 2. Probar Obtener Tareas

```bash
# Obtener token primero
TOKEN="tu_token_aqui"

curl http://localhost:8000/api/tareas?per_page=5 \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Probar Obtener Usuario Actual

```bash
curl http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## ✅ Checklist de Configuración Móvil

- [x] Configurar URL de API según entorno (emulador/dispositivo)
- [x] Implementar manejo de formato de respuesta estandarizado
- [x] Implementar manejo de errores (401, 403, 500)
- [x] Configurar headers de autenticación (Bearer token)
- [x] Actualizar tipos TypeScript
- [ ] Probar conexión desde emulador
- [ ] Probar conexión desde dispositivo físico
- [x] Verificar que CORS permite origen móvil

---

## 🔒 Seguridad

### CORS

El middleware CORS está configurado para permitir:
- `http://localhost:5173` (desarrollo web)
- `http://localhost:5174` (desarrollo web alternativo)
- `http://127.0.0.1:5173`
- `http://127.0.0.1:5174`
- Orígenes configurados en `CORS_ALLOWED_ORIGINS` del `.env`

**Para móvil:** Las apps móviles no envían `Origin` header, por lo que el middleware permite el acceso automáticamente.

### Token

- Los tokens se generan con Laravel Sanctum
- No expiran por defecto (configurable en `config/sanctum.php`)
- Se almacenan en `personal_access_tokens`
- Se eliminan al hacer logout

---

## 📝 Notas Importantes

1. **Campo de login:** El endpoint acepta `usuario` (puede ser username o email)
2. **Formato de respuesta:** Todos los endpoints usan el formato estandarizado con `success`, `message`, `data`
3. **Paginación:** Los endpoints que soportan paginación devuelven `meta` con información de paginación
4. **Errores:** Los errores de validación devuelven `errors` con detalles por campo
5. **Autenticación:** Todos los endpoints protegidos requieren header `Authorization: Bearer {token}`

---

**✅ La aplicación móvil está actualizada para usar el formato estandarizado de la API.**

