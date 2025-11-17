import React, { createContext, useContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';
import { http, csrf } from '../lib/http';

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

interface AuthContextType {
  user: User | null;
  login: (login: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initAuth = async () => {
      try {
        const token = localStorage.getItem('token');
        if (token) {
          http.defaults.headers.common['Authorization'] = `Bearer ${token}`;
          const response = await http.get('/api/me');
          
          // El backend devuelve: { success: true, data: { usuario: {...} } }
          const responseData = response.data;
          const usuario = responseData.success && responseData.data 
            ? responseData.data.usuario 
            : responseData.usuario || responseData.data?.usuario;
          
          if (usuario) {
            setUser(usuario);
          } else {
            throw new Error('No se pudo obtener el usuario');
          }
        }
      } catch (error) {
        console.error('Error al inicializar autenticación:', error);
        localStorage.removeItem('token');
        localStorage.removeItem('user');
      } finally {
        setLoading(false);
      }
    };

    initAuth();
  }, []);

  const login = async (login: string, password: string) => {
    try {
      // Intentar obtener CSRF cookie (no crítico si falla)
      try {
        await csrf();
      } catch (csrfError) {
        console.warn('⚠️ CSRF cookie no disponible, continuando con autenticación por token');
      }
      
      const response = await http.post('/api/auth/login', { usuario: login, password });
      
      console.log('🔐 Respuesta completa del login:', response.data);
      
      // El backend devuelve: { success: true, message: "...", data: { usuario: {...}, token: "..." } }
      const responseData = response.data;
      
      // Verificar si la respuesta tiene el formato estandarizado
      let usuario, token;
      
      if (responseData.success && responseData.data) {
        // Formato estandarizado: { success: true, data: { usuario, token } }
        usuario = responseData.data.usuario;
        token = responseData.data.token;
      } else if (responseData.usuario && responseData.token) {
        // Formato directo: { usuario, token }
        usuario = responseData.usuario;
        token = responseData.token;
      } else {
        console.error('❌ Formato de respuesta inesperado:', responseData);
        throw new Error('Formato de respuesta del servidor no reconocido');
      }
      
      if (!usuario || !token) {
        throw new Error('La respuesta del servidor no contiene usuario o token');
      }
      
      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(usuario));
      
      http.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      setUser(usuario);
      
      console.log('✅ Login exitoso');
    } catch (error: any) {
      console.error('❌ Error en login:', error);
      
      // Manejar diferentes tipos de errores
      let errorMessage = 'Error al iniciar sesión';
      
      if (error.response) {
        const status = error.response.status;
        const data = error.response.data;
        
        console.error('❌ Detalles del error:', {
          status,
          data,
          message: error.message,
        });
        
        if (status === 500) {
          errorMessage = 'Error del servidor. Por favor, verifica que el backend esté funcionando correctamente.';
        } else if (status === 401) {
          errorMessage = data?.message || 'Credenciales incorrectas';
        } else if (status === 403) {
          errorMessage = data?.message || 'Acceso denegado';
        } else if (data?.message) {
          errorMessage = data.message;
        } else {
          errorMessage = `Error del servidor (${status})`;
        }
      } else if (error.request) {
        errorMessage = 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
      } else {
        errorMessage = error.message || 'Error desconocido';
      }
      
      throw new Error(errorMessage);
    }
  };

  const logout = async () => {
    try {
      await http.post('/api/auth/logout');
    } catch (error) {
      console.error('Error al cerrar sesión:', error);
    } finally {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      delete http.defaults.headers.common['Authorization'];
      setUser(null);
    }
  };

  const value = {
    user,
    login,
    logout,
    loading,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
