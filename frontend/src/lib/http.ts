import axios from 'axios';

// Validar y normalizar la URL de la API
const getApiUrl = () => {
  const envUrl = import.meta.env.VITE_API_URL;
  const isProduction = import.meta.env.PROD;
  
  // Si no hay URL configurada
  if (!envUrl) {
    // En producción, usar Railway por defecto
    if (isProduction) {
      console.warn('⚠️ VITE_API_URL no configurada, usando URL de producción por defecto');
      return 'https://wms-v9-production.up.railway.app';
    }
    // En desarrollo, usar localhost
    return 'http://127.0.0.1:8000';
  }
  
  // Si la URL no comienza con http:// o https://, agregar https://
  if (!envUrl.startsWith('http://') && !envUrl.startsWith('https://')) {
    console.warn('⚠️ VITE_API_URL no incluye protocolo, agregando https://');
    return `https://${envUrl}`;
  }
  
  // Asegurar que la URL no termine con /
  const normalizedUrl = envUrl.endsWith('/') ? envUrl.slice(0, -1) : envUrl;
  
  // Log para debug (solo en desarrollo)
  if (!isProduction) {
    console.log('🌐 API URL configurada:', normalizedUrl);
  }
  
  return normalizedUrl;
};

export const http = axios.create({
  baseURL: getApiUrl(),
  withCredentials: true,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

// Interceptor para manejar errores de autenticación
http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Redirigir al login si no está autenticado
      localStorage.removeItem('user');
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export async function csrf() {
  try {
    await http.get('/sanctum/csrf-cookie');
  } catch (error: any) {
    // Si falla el CSRF cookie, no es crítico cuando usamos tokens Bearer
    // Solo loguear el error pero no fallar
    console.warn('No se pudo obtener CSRF cookie, continuando con autenticación por token:', error.message);
  }
}
