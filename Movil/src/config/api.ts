import { Platform } from 'react-native';
import Constants from 'expo-constants';

// URL del backend en Railway
const RAILWAY_API_URL = 'https://wms-v9-production.up.railway.app/api';

// Configuración: Cambiar a true para usar Railway siempre, false para usar localhost en desarrollo
const FORCE_RAILWAY = true; // Cambiar a false si quieres usar localhost en desarrollo

// Detectar entorno y configurar URL base
const getApiBaseUrl = () => {
  // Si FORCE_RAILWAY está activado, siempre usar Railway
  if (FORCE_RAILWAY) {
    return RAILWAY_API_URL;
  }

  // Intentar obtener la URL desde las constantes de Expo (app.json)
  const apiUrlFromConfig = Constants.expoConfig?.extra?.apiUrl;
  if (apiUrlFromConfig) {
    return apiUrlFromConfig;
  }

  // En desarrollo, detectar si es emulador, dispositivo físico o web
  if (__DEV__) {
    if (Platform.OS === 'web') {
      // En web, usar 127.0.0.1 (equivalente a localhost pero más explícito)
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.OS === 'android') {
      // Emulador Android usa 10.0.2.2 para acceder al localhost de la máquina host
      // Para dispositivo físico, necesitarás usar tu IP local (ej: http://192.168.1.100:8000/api)
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.OS === 'ios') {
      // Emulador iOS usa localhost
      return 'http://127.0.0.1:8000/api';
    }
  }
  
  // Producción: usar la URL del servidor en Railway
  return RAILWAY_API_URL;
};

// URL base de la API
export const API_BASE_URL = getApiBaseUrl();

// Log para debug (siempre mostrar la URL para verificar la conexión)
console.log('🌐 API Base URL:', API_BASE_URL);
console.log('🌐 Platform:', Platform.OS);
if (FORCE_RAILWAY) {
  console.log('✅ Conectado a Railway (Producción)');
} else {
  console.log('🔧 Modo desarrollo - usando localhost');
}

// Timeouts
export const API_TIMEOUT = 30000; // 30 segundos

// Endpoints principales
export const API_ENDPOINTS = {
  // Autenticación
  AUTH: {
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    ME: '/me',
  },
  // Dashboard
  DASHBOARD: {
    ESTADISTICAS: '/dashboard/estadisticas',
    ACTIVIDAD: '/dashboard/actividad',
    RESUMEN: '/dashboard/resumen',
  },
  // Productos
  PRODUCTOS: {
    BASE: '/productos',
    CATALOGOS: '/productos-catalogos',
    ACTIVAR: (id: number) => `/productos/${id}/activar`,
    DESACTIVAR: (id: number) => `/productos/${id}/desactivar`,
  },
  // Inventario
  INVENTARIO: {
    BASE: '/inventario',
    AJUSTAR: (id: number) => `/inventario/${id}/ajustar`,
    POR_UBICACION: (codigo: string) => `/inventario/por-ubicacion/${codigo}`,
    POR_PRODUCTO: (codigo: string) => `/inventario/por-producto/${codigo}`,
  },
  // Tareas
  TAREAS: {
    BASE: '/tareas',
    CATALOGOS: '/tareas-catalogos',
    ASIGNAR: (id: number) => `/tareas/${id}/asignar`,
    CAMBIAR_ESTADO: (id: number) => `/tareas/${id}/cambiar-estado`,
    COMPLETAR: (id: number) => `/tareas/${id}/completar`,
  },
  // Ubicaciones
  UBICACIONES: {
    BASE: '/ubicaciones',
    CATALOGOS: '/ubicaciones-catalogos',
    ACTIVAR: (id: number) => `/ubicaciones/${id}/activar`,
    DESACTIVAR: (id: number) => `/ubicaciones/${id}/desactivar`,
  },
  // Incidencias
  INCIDENCIAS: {
    BASE: '/incidencias',
    CATALOGOS: '/incidencias-catalogos',
    RESOLVER: (id: number) => `/incidencias/${id}/resolver`,
    REABRIR: (id: number) => `/incidencias/${id}/reabrir`,
  },
  // Picking
  PICKING: {
    BASE: '/picking',
    ASIGNAR: (id: number) => `/picking/${id}/asignar`,
    COMPLETAR: (id: number) => `/picking/${id}/completar`,
    CANCELAR: (id: number) => `/picking/${id}/cancelar`,
    PICK_ITEM: (id: number) => `/picking/${id}/pick-item`,
  },
  // Órdenes de Salida
  ORDENES_SALIDA: {
    BASE: '/ordenes-salida',
    CATALOGOS: '/ordenes-salida-catalogos',
    CONFIRMAR: (id: number) => `/ordenes-salida/${id}/confirmar`,
    CANCELAR: (id: number) => `/ordenes-salida/${id}/cancelar`,
  },
  // Lotes
  LOTES: {
    BASE: '/lotes',
    AJUSTAR_CANTIDAD: (id: number) => `/lotes/${id}/ajustar-cantidad`,
    RESERVAR: (id: number) => `/lotes/${id}/reservar`,
    LIBERAR: (id: number) => `/lotes/${id}/liberar`,
    CAMBIAR_ESTADO: (id: number) => `/lotes/${id}/cambiar-estado`,
    MOVIMIENTOS: (id: number) => `/lotes/${id}/movimientos`,
    TRAZABILIDAD: (id: number) => `/lotes/${id}/trazabilidad`,
  },
  // Notificaciones
  NOTIFICACIONES: {
    BASE: '/notificaciones',
    ESTADISTICAS: '/notificaciones/estadisticas',
    CONFIGURACION: '/notificaciones/configuracion',
    MARCAR_LEIDA: (id: number) => `/notificaciones/${id}/marcar-leida`,
    MARCAR_TODAS_LEIDAS: '/notificaciones/marcar-todas-leidas',
  },
};
