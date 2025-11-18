import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Platform } from 'react-native';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';
import { offlineService } from '../services/offline';

interface NetworkContextType {
  isConnected: boolean;
  isOnline: boolean;
  pendingRequests: number;
  syncPendingRequests: () => Promise<void>;
}

const NetworkContext = createContext<NetworkContextType | undefined>(undefined);

export const useNetwork = () => {
  const context = useContext(NetworkContext);
  if (!context) {
    throw new Error('useNetwork debe usarse dentro de NetworkProvider');
  }
  return context;
};

interface NetworkProviderProps {
  children: ReactNode;
}

export const NetworkProvider: React.FC<NetworkProviderProps> = ({ children }) => {
  const [isConnected, setIsConnected] = useState<boolean>(true);
  const [isOnline, setIsOnline] = useState<boolean>(true);
  const [pendingRequests, setPendingRequests] = useState<number>(0);

  useEffect(() => {
    let isMounted = true;

    // En web, usar la API nativa de navegador para detectar conexión
    if (Platform.OS === 'web') {
      const handleOnline = () => {
        if (!isMounted) return;
        setIsConnected(true);
        setIsOnline(true);
        syncPendingRequests();
      };
      
      const handleOffline = () => {
        if (!isMounted) return;
        setIsConnected(false);
        setIsOnline(false);
      };

      window.addEventListener('online', handleOnline);
      window.addEventListener('offline', handleOffline);

      // Estado inicial
      setIsConnected(navigator.onLine);
      setIsOnline(navigator.onLine);

      return () => {
        isMounted = false;
        window.removeEventListener('online', handleOnline);
        window.removeEventListener('offline', handleOffline);
      };
    }

    // Para móvil, usar NetInfo
    // Suscribirse a cambios de red
    const unsubscribe = NetInfo.addEventListener((state: NetInfoState) => {
      if (!isMounted) return;
      
      const connected = state.isConnected ?? false;
      setIsConnected(connected);
      setIsOnline(connected && (state.isInternetReachable ?? false));

      // Si se reconecta, sincronizar pendientes
      if (connected) {
        syncPendingRequests();
      }
    });

    // Verificar estado inicial
    NetInfo.fetch().then((state: NetInfoState) => {
      if (!isMounted) return;
      
      const connected = state.isConnected ?? false;
      setIsConnected(connected);
      setIsOnline(connected && (state.isInternetReachable ?? false));
    });

    // Actualizar contador de pendientes periódicamente
    const interval = setInterval(async () => {
      if (!isMounted) return;
      
      try {
        const pending = await offlineService.getPendingRequests();
        setPendingRequests(pending.length);
      } catch (error) {
        console.error('Error obteniendo peticiones pendientes:', error);
      }
    }, 5000);

    return () => {
      isMounted = false;
      if (Platform.OS !== 'web') {
        unsubscribe();
      }
      clearInterval(interval);
    };
  }, []);

  const syncPendingRequests = async () => {
    await offlineService.syncPendingRequests();
    const pending = await offlineService.getPendingRequests();
    setPendingRequests(pending.length);
  };

  return (
    <NetworkContext.Provider
      value={{
        isConnected,
        isOnline,
        pendingRequests,
        syncPendingRequests,
      }}
    >
      {children}
    </NetworkContext.Provider>
  );
};

