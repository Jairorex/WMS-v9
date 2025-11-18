# WMS Escasan - Aplicación Móvil

Aplicación móvil React Native Expo para el sistema de gestión de almacenes WMS Escasan.

## 🚀 Características

- ✅ **Funcionalidad Offline**: Trabaja sin conexión y sincroniza automáticamente
- ✅ **Interfaz Intuitiva**: Diseño moderno y fácil de usar
- ✅ **Escalable**: Arquitectura modular y bien estructurada
- ✅ **Autenticación Segura**: Uso de tokens Bearer y almacenamiento seguro
- ✅ **Sincronización Automática**: Sincroniza peticiones pendientes cuando hay conexión
- ✅ **Cache Inteligente**: Almacena datos localmente para acceso rápido
- ✅ **Detección Automática de Entorno**: Configura URL según emulador o dispositivo físico

## 📋 Requisitos

- Node.js >= 16
- npm o yarn
- Expo CLI
- Cuenta de Expo (opcional, para desarrollo)

## 🛠️ Instalación

```bash
# Instalar dependencias
npm install

# Iniciar el servidor de desarrollo
npm start

# Ejecutar en Android
npm run android

# Ejecutar en iOS (solo macOS)
npm run ios

# Ejecutar en web
npm run web
```

## 🔧 Configuración de la API

La aplicación detecta automáticamente el entorno:

- **Emulador Android**: `http://10.0.2.2:8000/api`
- **Emulador iOS**: `http://localhost:8000/api`
- **Producción**: `https://wms-v9-production.up.railway.app/api`

### Para Dispositivo Físico

Si usas un dispositivo físico, edita `src/config/api.ts` y cambia la URL:

```typescript
export const API_BASE_URL = 'http://TU_IP_LOCAL:8000/api';
```

Para obtener tu IP local:
- **Windows**: `ipconfig` (busca "IPv4 Address")
- **Linux/macOS**: `ifconfig` (busca "inet")

## 📱 Estructura del Proyecto

```
Movil/
├── src/
│   ├── config/          # Configuración (API endpoints, etc.)
│   ├── types/           # Tipos TypeScript
│   ├── contexts/        # Contextos de React (Auth, Network)
│   ├── services/        # Servicios (API, Offline)
│   ├── navigation/      # Configuración de navegación
│   ├── screens/         # Pantallas de la aplicación
│   │   ├── auth/        # Pantallas de autenticación
│   │   ├── main/        # Pantallas principales
│   │   └── detail/      # Pantallas de detalle
│   └── components/      # Componentes reutilizables
│       └── common/      # Componentes comunes
├── assets/              # Imágenes y recursos
└── App.tsx              # Componente principal
```

## 🔐 Autenticación

La aplicación usa Laravel Sanctum para autenticación:
- Tokens Bearer almacenados de forma segura
- Renovación automática de sesión
- Logout seguro

**Credenciales de prueba:**
- Usuario: `admin` o `admin@escasan.com`
- Contraseña: `admin123`

## 📡 Funcionalidad Offline

### Características:

1. **Cache de Datos**: Los datos se almacenan localmente para acceso rápido
2. **Cola de Peticiones**: Las peticiones se guardan cuando no hay conexión
3. **Sincronización Automática**: Se sincronizan automáticamente cuando hay conexión
4. **Indicadores Visuales**: Banner de estado offline y contador de peticiones pendientes

### Uso:

```typescript
import { offlineService } from './src/services/offline';

// Guardar petición pendiente
await offlineService.savePendingRequest({
  method: 'POST',
  url: '/api/tareas',
  data: { ... }
});

// Sincronizar manualmente
await offlineService.syncPendingRequests();
```

## 🎨 Componentes Principales

- **LoadingSpinner**: Indicador de carga
- **ErrorView**: Vista de error con opción de reintentar
- **EmptyState**: Estado vacío con icono y mensaje
- **OfflineBanner**: Banner de estado offline

## 📱 Pantallas

### Autenticación
- Login: Inicio de sesión con usuario/email y contraseña

### Principales
- Dashboard: Estadísticas y resumen del sistema
- Tareas: Lista de tareas con filtros
- Inventario: Gestión de inventario
- Productos: Catálogo de productos
- Perfil: Información del usuario y configuración

### Detalle
- TareaDetalle: Detalle completo de una tarea
- ProductoDetalle: Detalle completo de un producto

## 🔄 Sincronización

La aplicación sincroniza automáticamente:
- Cada 30 segundos cuando hay conexión
- Inmediatamente al detectar reconexión
- Al iniciar sesión

## 📊 Formato de Respuestas de la API

La aplicación está configurada para manejar el formato estandarizado:

```json
{
  "success": true,
  "message": "Mensaje descriptivo",
  "data": {
    /* tus datos aquí */
  }
}
```

El servicio de API extrae automáticamente `data` de la respuesta.

## 🚀 Próximas Mejoras

- [ ] Notificaciones push
- [ ] Escaneo de códigos de barras
- [ ] Modo oscuro
- [ ] Internacionalización (i18n)
- [ ] Más pantallas y funcionalidades

## 📝 Licencia

Propietario - Escasan
