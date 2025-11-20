# 📱 Guía de la Aplicación Móvil WMS Escasan

## 🎯 Descripción

Aplicación móvil desarrollada con React Native Expo que consume la API del sistema WMS Escasan. Diseñada para trabajar offline, con interfaz intuitiva y arquitectura escalable.

## ✨ Características Principales

### 🔄 Funcionalidad Offline
- **Cache Inteligente**: Almacena datos localmente para acceso rápido
- **Cola de Sincronización**: Guarda peticiones cuando no hay conexión
- **Sincronización Automática**: Sincroniza cuando se restablece la conexión
- **Indicadores Visuales**: Banner de estado offline y contador de pendientes

### 🎨 Interfaz Intuitiva
- Diseño moderno y limpio
- Navegación por tabs intuitiva
- Componentes reutilizables
- Feedback visual claro

### 📈 Escalabilidad
- Arquitectura modular
- Separación de responsabilidades
- Servicios independientes
- Fácil de extender

## 🏗️ Arquitectura

```
Movil/
├── src/
│   ├── config/          # Configuración centralizada
│   │   └── api.ts       # Endpoints y configuración de API
│   │
│   ├── services/        # Servicios de negocio
│   │   ├── api.ts       # Cliente HTTP con interceptores
│   │   └── offline.ts   # Gestión offline y sincronización
│   │
│   ├── contexts/       # Contextos de React
│   │   ├── AuthContext.tsx      # Autenticación
│   │   └── NetworkContext.tsx   # Estado de red
│   │
│   ├── navigation/     # Navegación
│   │   └── AppNavigator.tsx      # Configuración de rutas
│   │
│   ├── screens/        # Pantallas
│   │   ├── auth/       # Autenticación
│   │   ├── main/       # Pantallas principales
│   │   └── detail/     # Pantallas de detalle
│   │
│   └── components/     # Componentes reutilizables
│       └── common/     # Componentes comunes
│
└── App.tsx             # Punto de entrada
```

## 🔐 Autenticación

### Flujo de Login
1. Usuario ingresa credenciales
2. Se envía petición a `/api/auth/login`
3. Se recibe token y datos del usuario
4. Token se almacena en SecureStore
5. Se inicia sincronización automática

### Almacenamiento Seguro
- Tokens en `expo-secure-store`
- Datos de usuario encriptados
- Logout limpia todo el almacenamiento

## 📡 Sistema Offline

### Cómo Funciona

1. **Detección de Red**: Monitorea estado de conexión
2. **Cache de Datos**: Almacena respuestas de API
3. **Cola de Peticiones**: Guarda peticiones cuando offline
4. **Sincronización**: Procesa cola cuando hay conexión

### Uso del Servicio Offline

```typescript
import { offlineService } from './src/services/offline';

// Guardar petición pendiente
await offlineService.savePendingRequest({
  method: 'POST',
  url: '/api/tareas',
  data: { titulo: 'Nueva tarea' }
});

// Sincronizar manualmente
await offlineService.syncPendingRequests();

// Cachear datos
await offlineService.cacheData('tareas', data, 5); // 5 minutos

// Obtener datos cacheados
const cached = await offlineService.getCachedData('tareas');
```

## 🎨 Componentes Principales

### LoadingSpinner
Indicador de carga reutilizable.

```tsx
<LoadingSpinner size="large" fullScreen />
```

### ErrorView
Vista de error con opción de reintentar.

```tsx
<ErrorView 
  message="Error al cargar datos" 
  onRetry={loadData} 
/>
```

### EmptyState
Estado vacío con icono y mensaje.

```tsx
<EmptyState
  icon="list-outline"
  title="No hay tareas"
  message="No se encontraron tareas disponibles"
/>
```

### OfflineBanner
Banner que muestra estado offline.

```tsx
<OfflineBanner />
```

## 📱 Pantallas

### Autenticación
- **LoginScreen**: Inicio de sesión

### Principales (Tabs)
- **DashboardScreen**: Estadísticas y resumen
- **TareasScreen**: Lista de tareas
- **InventarioScreen**: Gestión de inventario
- **ProductosScreen**: Catálogo de productos
- **PerfilScreen**: Perfil de usuario

### Detalle
- **TareaDetalleScreen**: Detalle de tarea
- **ProductoDetalleScreen**: Detalle de producto

## 🔧 Configuración

### URL de la API

Edita `app.json`:

```json
{
  "expo": {
    "extra": {
      "apiUrl": "https://tu-api-url.com/api"
    }
  }
}
```

O modifica directamente en `src/config/api.ts`:

```typescript
export const API_BASE_URL = 'https://tu-api-url.com/api';
```

## 🚀 Desarrollo

### Iniciar Proyecto

```bash
cd Movil
npm install
npm start
```

### Ejecutar en Dispositivo

```bash
# Android
npm run android

# iOS (solo macOS)
npm run ios

# Web
npm run web
```

### Estructura de Datos

#### Usuario
```typescript
interface User {
  id_usuario: number;
  nombre: string;
  usuario: string;
  email: string;
  rol_id: number;
  activo: boolean;
  rol: {
    id_rol: number;
    nombre: string;
    descripcion: string;
  };
}
```

#### Tarea
```typescript
interface Tarea {
  id_tarea: number;
  titulo: string;
  descripcion?: string;
  tipo: string;
  estado: string;
  prioridad: string;
  asignado_a?: number;
  asignadoA?: {
    nombre: string;
  };
}
```

## 🔄 Sincronización

### Automática
- Cada 30 segundos cuando hay conexión
- Inmediatamente al detectar reconexión
- Al iniciar sesión

### Manual
- Desde el banner offline
- Botón de sincronización en perfil

## 📊 Mejores Prácticas

### 1. Manejo de Errores
```typescript
try {
  const data = await apiService.get('/api/endpoint');
  // Procesar datos
} catch (error) {
  // Intentar cargar desde cache
  const cached = await offlineService.getCachedData('key');
  if (cached.length > 0) {
    // Usar datos cacheados
  } else {
    // Mostrar error
  }
}
```

### 2. Cache de Datos
```typescript
// Cachear después de cargar
const data = await apiService.get('/api/endpoint');
await offlineService.cacheData('endpoint', data, 10); // 10 minutos
```

### 3. Peticiones Offline
```typescript
if (!isOnline) {
  await offlineService.savePendingRequest({
    method: 'POST',
    url: '/api/endpoint',
    data: payload
  });
} else {
  await apiService.post('/api/endpoint', payload);
}
```

## 🐛 Troubleshooting

### Error: "Network request failed"
- Verificar conexión a internet
- Verificar URL de API en configuración
- Revisar logs del servidor

### Datos no se sincronizan
- Verificar que hay conexión
- Revisar cola de peticiones pendientes
- Verificar logs de sincronización

### Token expirado
- El sistema limpia automáticamente
- Usuario debe iniciar sesión nuevamente

## 📝 Próximas Mejoras

- [ ] Notificaciones push
- [ ] Escaneo de códigos de barras
- [ ] Modo oscuro
- [ ] Internacionalización (i18n)
- [ ] Más pantallas (Incidencias, Picking, etc.)
- [ ] Filtros y búsqueda avanzada
- [ ] Exportación de datos
- [ ] Sincronización selectiva

## 📄 Licencia

Propietario - Escasan

