import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';
import { apiService } from './api';

// Claves de almacenamiento
const STORAGE_KEYS = {
  PENDING_REQUESTS: '@wms:pending_requests',
  SYNC_QUEUE: '@wms:sync_queue',
  LAST_SYNC: '@wms:last_sync',
  CACHED_DATA: '@wms:cached_data',
};

// Tipos
export interface PendingRequest {
  id: string;
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  url: string;
  data?: any;
  timestamp: number;
  retries: number;
}

export interface CachedData {
  key: string;
  data: any;
  timestamp: number;
  expiresIn?: number; // minutos
}

// Servicio de sincronización offline
class OfflineService {
  private syncInterval: NodeJS.Timeout | null = null;

  // Guardar petición pendiente
  async savePendingRequest(request: Omit<PendingRequest, 'id' | 'timestamp' | 'retries'>): Promise<void> {
    try {
      const pending = await this.getPendingRequests();
      const newRequest: PendingRequest = {
        ...request,
        id: `${Date.now()}-${Math.random()}`,
        timestamp: Date.now(),
        retries: 0,
      };
      pending.push(newRequest);
      await AsyncStorage.setItem(STORAGE_KEYS.PENDING_REQUESTS, JSON.stringify(pending));
    } catch (error) {
      console.error('Error guardando petición pendiente:', error);
    }
  }

  // Obtener peticiones pendientes
  async getPendingRequests(): Promise<PendingRequest[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.PENDING_REQUESTS);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Error obteniendo peticiones pendientes:', error);
      return [];
    }
  }

  // Eliminar petición pendiente
  async removePendingRequest(id: string): Promise<void> {
    try {
      const pending = await this.getPendingRequests();
      const filtered = pending.filter(req => req.id !== id);
      await AsyncStorage.setItem(STORAGE_KEYS.PENDING_REQUESTS, JSON.stringify(filtered));
    } catch (error) {
      console.error('Error eliminando petición pendiente:', error);
    }
  }

  // Sincronizar peticiones pendientes
  async syncPendingRequests(): Promise<void> {
    const isConnected = await NetInfo.fetch().then(state => state.isConnected);
    if (!isConnected) {
      return;
    }

    const pending = await this.getPendingRequests();
    if (pending.length === 0) {
      return;
    }

    console.log(`Sincronizando ${pending.length} peticiones pendientes...`);

    for (const request of pending) {
      try {
        let response;
        switch (request.method) {
          case 'GET':
            response = await apiService.get(request.url);
            break;
          case 'POST':
            response = await apiService.post(request.url, request.data);
            break;
          case 'PUT':
            response = await apiService.put(request.url, request.data);
            break;
          case 'PATCH':
            response = await apiService.patch(request.url, request.data);
            break;
          case 'DELETE':
            response = await apiService.delete(request.url);
            break;
        }

        // Éxito: eliminar de pendientes
        await this.removePendingRequest(request.id);
        console.log(`Petición ${request.id} sincronizada exitosamente`);
      } catch (error) {
        // Error: incrementar reintentos
        request.retries++;
        if (request.retries >= 3) {
          // Eliminar después de 3 intentos fallidos
          await this.removePendingRequest(request.id);
          console.error(`Petición ${request.id} falló después de 3 intentos`);
        } else {
          // Actualizar en almacenamiento
          const allPending = await this.getPendingRequests();
          const updated = allPending.map(req => 
            req.id === request.id ? request : req
          );
          await AsyncStorage.setItem(STORAGE_KEYS.PENDING_REQUESTS, JSON.stringify(updated));
        }
      }
    }
  }

  // Cachear datos
  async cacheData(key: string, data: any, expiresIn?: number): Promise<void> {
    try {
      const cached: CachedData = {
        key,
        data,
        timestamp: Date.now(),
        expiresIn,
      };
      const allCached = await this.getCachedData();
      const filtered = allCached.filter(c => c.key !== key);
      filtered.push(cached);
      await AsyncStorage.setItem(STORAGE_KEYS.CACHED_DATA, JSON.stringify(filtered));
    } catch (error) {
      console.error('Error cacheando datos:', error);
    }
  }

  // Obtener datos cacheados
  async getCachedData(key?: string): Promise<CachedData[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.CACHED_DATA);
      const allCached: CachedData[] = data ? JSON.parse(data) : [];
      
      if (!key) {
        return allCached;
      }

      const cached = allCached.find(c => c.key === key);
      if (!cached) {
        return [];
      }

      // Verificar expiración
      if (cached.expiresIn) {
        const age = (Date.now() - cached.timestamp) / 1000 / 60; // minutos
        if (age > cached.expiresIn) {
          // Eliminar expirado
          const filtered = allCached.filter(c => c.key !== key);
          await AsyncStorage.setItem(STORAGE_KEYS.CACHED_DATA, JSON.stringify(filtered));
          return [];
        }
      }

      return [cached];
    } catch (error) {
      console.error('Error obteniendo datos cacheados:', error);
      return [];
    }
  }

  // Limpiar cache
  async clearCache(): Promise<void> {
    try {
      await AsyncStorage.removeItem(STORAGE_KEYS.CACHED_DATA);
    } catch (error) {
      console.error('Error limpiando cache:', error);
    }
  }

  // Iniciar sincronización automática
  startAutoSync(interval: number = 30000): void {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }
    this.syncInterval = setInterval(() => {
      this.syncPendingRequests();
    }, interval);
  }

  // Detener sincronización automática
  stopAutoSync(): void {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
    }
  }

  // Verificar si hay datos pendientes
  async hasPendingRequests(): Promise<boolean> {
    const pending = await this.getPendingRequests();
    return pending.length > 0;
  }
}

export const offlineService = new OfflineService();

