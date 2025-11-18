import axios, { AxiosInstance, AxiosError } from 'axios';
import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';
import { API_BASE_URL, API_TIMEOUT } from '../config/api';
import NetInfo from '@react-native-community/netinfo';
import { ApiResponse, PaginatedResponse, ApiError } from '../types/api';

// Helper para almacenamiento seguro según plataforma
const storage = {
  async getItem(key: string): Promise<string | null> {
    if (Platform.OS === 'web') {
      return localStorage.getItem(key);
    }
    return await SecureStore.getItemAsync(key);
  },
  async setItem(key: string, value: string): Promise<void> {
    if (Platform.OS === 'web') {
      localStorage.setItem(key, value);
    } else {
      await SecureStore.setItemAsync(key, value);
    }
  },
  async removeItem(key: string): Promise<void> {
    if (Platform.OS === 'web') {
      localStorage.removeItem(key);
    } else {
      await SecureStore.deleteItemAsync(key);
    }
  },
};

// Clase para manejar la API
class ApiService {
  private client: AxiosInstance;
  private isOnline: boolean = true;

  constructor() {
    console.log('🔧 Inicializando ApiService con baseURL:', API_BASE_URL);
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: API_TIMEOUT,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    // Monitorear conexión (solo en móvil)
    if (Platform.OS !== 'web') {
      NetInfo.addEventListener(state => {
        this.isOnline = state.isConnected ?? false;
      });
    } else {
      // En web, usar la API del navegador
      window.addEventListener('online', () => {
        this.isOnline = true;
      });
      window.addEventListener('offline', () => {
        this.isOnline = false;
      });
      this.isOnline = navigator.onLine;
    }

    // Interceptor de requests
    this.client.interceptors.request.use(
      async (config) => {
        const token = await storage.getItem('auth_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Interceptor de responses
    this.client.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        if (error.response?.status === 401) {
          // Token expirado o inválido
          await storage.removeItem('auth_token');
          await storage.removeItem('user_data');
        }
        return Promise.reject(this.handleError(error));
      }
    );
  }

  private handleError(error: AxiosError): ApiError {
    if (error.response) {
      // Error de respuesta del servidor
      const data = error.response.data as any;
      return {
        message: data?.message || 'Error en la petición',
        errors: data?.errors,
        status: error.response.status,
      };
    } else if (error.request) {
      // Error de red
      return {
        message: this.isOnline 
          ? 'No se pudo conectar con el servidor' 
          : 'Sin conexión a internet',
        status: 0,
      };
    } else {
      // Error al configurar la petición
      return {
        message: error.message || 'Error desconocido',
      };
    }
  }

  // Métodos HTTP - Manejan el formato estandarizado de respuesta
  async get<T = any>(url: string, config?: any): Promise<T> {
    try {
      const response = await this.client.get<ApiResponse<T>>(url, config);
      const apiResponse = response.data;
      
      // Si la respuesta tiene success: false, lanzar error
      if (!apiResponse.success) {
        throw {
          message: apiResponse.message || 'Error en la petición',
          errors: apiResponse.errors,
        };
      }
      
      // Retornar solo los datos (apiResponse.data)
      // Si data es undefined, retornar la respuesta completa como fallback
      return apiResponse.data !== undefined ? apiResponse.data : (apiResponse as unknown as T);
    } catch (error) {
      throw error;
    }
  }

  async getPaginated<T = any>(url: string, config?: any): Promise<PaginatedResponse<T>> {
    try {
      const response = await this.client.get<PaginatedResponse<T>>(url, config);
      const apiResponse = response.data;
      
      if (!apiResponse.success) {
        throw {
          message: apiResponse.message || 'Error en la petición',
          errors: apiResponse.errors,
        };
      }
      
      return apiResponse;
    } catch (error) {
      throw error;
    }
  }

  async post<T = any>(url: string, data?: any, config?: any): Promise<T> {
    try {
      console.log('📤 POST Request:', { url, data });
      const response = await this.client.post<ApiResponse<T>>(url, data, config);
      const apiResponse = response.data;
      
      console.log('📥 POST Response:', apiResponse);
      
      if (!apiResponse.success) {
        console.error('❌ API Response success: false', apiResponse);
        throw {
          message: apiResponse.message || 'Error en la petición',
          errors: apiResponse.errors,
        };
      }
      
      // Si data es undefined, retornar la respuesta completa como fallback
      if (apiResponse.data === undefined) {
        console.warn('⚠️ apiResponse.data es undefined, retornando respuesta completa');
        return apiResponse as unknown as T;
      }
      
      return apiResponse.data;
    } catch (error: any) {
      console.error('❌ Error en POST:', {
        url,
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
      });
      throw error;
    }
  }

  async put<T = any>(url: string, data?: any, config?: any): Promise<T> {
    try {
      const response = await this.client.put<ApiResponse<T>>(url, data, config);
      const apiResponse = response.data;
      
      if (!apiResponse.success) {
        throw {
          message: apiResponse.message || 'Error en la petición',
          errors: apiResponse.errors,
        };
      }
      
      return apiResponse.data;
    } catch (error) {
      throw error;
    }
  }

  async patch<T = any>(url: string, data?: any, config?: any): Promise<T> {
    try {
      const response = await this.client.patch<ApiResponse<T>>(url, data, config);
      const apiResponse = response.data;
      
      if (!apiResponse.success) {
        throw {
          message: apiResponse.message || 'Error en la petición',
          errors: apiResponse.errors,
        };
      }
      
      return apiResponse.data;
    } catch (error) {
      throw error;
    }
  }

  async delete<T = any>(url: string, config?: any): Promise<T> {
    try {
      const response = await this.client.delete<ApiResponse<T>>(url, config);
      const apiResponse = response.data;
      
      if (!apiResponse.success) {
        throw {
          message: apiResponse.message || 'Error en la petición',
          errors: apiResponse.errors,
        };
      }
      
      return apiResponse.data;
    } catch (error) {
      throw error;
    }
  }

  // Verificar conexión
  isConnected(): boolean {
    return this.isOnline;
  }
}

export const apiService = new ApiService();
