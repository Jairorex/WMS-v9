import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';
import { apiService } from '../services/api';
import { API_ENDPOINTS } from '../config/api';
import { offlineService } from '../services/offline';
import { Usuario, LoginResponse } from '../types/api';

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

// Usar el tipo Usuario de la API
export type User = Usuario;

interface AuthContextType {
  user: User | null;
  loading: boolean;
  isAuthenticated: boolean;
  login: (usuario: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth debe usarse dentro de AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // Cargar usuario al iniciar
  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      const token = await storage.getItem('auth_token');
      const userData = await storage.getItem('user_data');

      if (token && userData) {
        try {
          // Intentar validar token con el servidor
          // La API devuelve { success: true, data: { usuario: {...} } }
          // El servicio extrae data, así que obtenemos { usuario: User }
          const response = await apiService.get<{ usuario: User }>(API_ENDPOINTS.AUTH.ME);
          
          // Manejar ambos formatos
          let user: User;
          if ((response as any).usuario) {
            user = (response as any).usuario;
          } else if ((response as any).data && (response as any).data.usuario) {
            user = (response as any).data.usuario;
          } else {
            user = response as unknown as User;
          }
          
          setUser(user);
        } catch (error) {
          console.error('Error validando token:', error);
          // Token inválido, limpiar
          await storage.removeItem('auth_token');
          await storage.removeItem('user_data');
          setUser(null);
        }
      } else {
        setUser(null);
      }
    } catch (error) {
      console.error('Error cargando usuario:', error);
      setUser(null);
    } finally {
      // Asegurar que loading se establece en false
      setTimeout(() => {
        setLoading(false);
      }, 100);
    }
  };

  const login = async (usuario: string, password: string) => {
    try {
      console.log('🔐 Intentando login con:', { usuario: usuario.trim() });
      console.log('🌐 URL de API:', API_ENDPOINTS.AUTH.LOGIN);
      
      // La API devuelve { success: true, data: { usuario: {...}, token: "..." } }
      // El apiService.post extrae response.data, así que obtenemos { usuario: {...}, token: "..." }
      const response = await apiService.post<LoginResponse>(
        API_ENDPOINTS.AUTH.LOGIN,
        { usuario: usuario.trim(), password }
      );

      console.log('✅ Respuesta del login:', response);

      // El apiService ya extrae data del formato estandarizado
      // Así que response debería ser directamente { usuario: {...}, token: "..." }
      // Pero verificamos ambos formatos por compatibilidad
      let usuarioData, tokenData;
      
      if (response && response.token && response.usuario) {
        // Formato directo: { usuario, token }
        usuarioData = response.usuario;
        tokenData = response.token;
      } else if ((response as any).data && (response as any).data.usuario && (response as any).data.token) {
        // Formato anidado: { data: { usuario, token } }
        usuarioData = (response as any).data.usuario;
        tokenData = (response as any).data.token;
      } else {
        console.error('❌ Respuesta de login inválida:', response);
        throw new Error('La respuesta del servidor no tiene el formato esperado');
      }

      if (!usuarioData || !tokenData) {
        throw new Error('La respuesta del servidor no contiene usuario o token');
      }

      // Guardar token y datos de usuario
      await storage.setItem('auth_token', tokenData);
      await storage.setItem('user_data', JSON.stringify(usuarioData));

      setUser(usuarioData);

      // Iniciar sincronización offline
      offlineService.startAutoSync();
      
      console.log('✅ Login exitoso');
    } catch (error: any) {
      console.error('❌ Error en login:', error);
      console.error('❌ Detalles del error:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
      });
      throw new Error(error.message || 'Error al iniciar sesión');
    }
  };

  const logout = async () => {
    try {
      // Intentar logout en el servidor
      try {
        await apiService.post(API_ENDPOINTS.AUTH.LOGOUT);
      } catch (error) {
        // Si falla, continuar con logout local
        console.warn('Error en logout del servidor:', error);
      }

      // Limpiar almacenamiento local
      await storage.removeItem('auth_token');
      await storage.removeItem('user_data');
      
      // Limpiar cache
      await offlineService.clearCache();

      // Detener sincronización
      offlineService.stopAutoSync();

      setUser(null);
    } catch (error) {
      console.error('Error en logout:', error);
    }
  };

  const refreshUser = async () => {
    try {
      // La API devuelve { success: true, data: { usuario: {...} } }
      // El servicio extrae data, así que obtenemos { usuario: User }
      const response = await apiService.get<{ usuario: User }>(API_ENDPOINTS.AUTH.ME);
      
      // Manejar ambos formatos
      let user: User;
      if ((response as any).usuario) {
        user = (response as any).usuario;
      } else if ((response as any).data && (response as any).data.usuario) {
        user = (response as any).data.usuario;
      } else {
        user = response as unknown as User;
      }
      
      setUser(user);
      await storage.setItem('user_data', JSON.stringify(user));
    } catch (error) {
      console.error('Error refrescando usuario:', error);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        isAuthenticated: !!user,
        login,
        logout,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

