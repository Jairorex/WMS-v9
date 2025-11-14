import axios from 'axios';

// Validar y normalizar la URL de la API
const getApiUrl = () => {
  const envUrl = import.meta.env.VITE_API_URL;
  
  // Si no hay URL configurada, usar localhost por defecto
  if (!envUrl) {
    return 'http://127.0.0.1:8000';
  }
  
  // Si la URL no comienza con http:// o https://, agregar https://
  if (!envUrl.startsWith('http://') && !envUrl.startsWith('https://')) {
    console.warn('VITE_API_URL no incluye protocolo, agregando https://');
    return `https://${envUrl}`;
  }
  
  // Asegurar que la URL no termine con /
  return envUrl.endsWith('/') ? envUrl.slice(0, -1) : envUrl;
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
  await http.get('/sanctum/csrf-cookie');
}
