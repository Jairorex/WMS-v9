import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import { offlineService } from '../../services/offline';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import ErrorView from '../../components/common/ErrorView';
import EmptyState from '../../components/common/EmptyState';
import OfflineBanner from '../../components/common/OfflineBanner';
import { Ionicons } from '@expo/vector-icons';
import { Tarea } from '../../types/api';

const TareasScreen: React.FC = () => {
  const navigation = useNavigation();
  const [tareas, setTareas] = useState<Tarea[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadTareas = async () => {
    try {
      setError(null);
      // La API devuelve { success: true, data: Tarea[] }
      const data = await apiService.get<Tarea[]>(API_ENDPOINTS.TAREAS.BASE);
      const tareasList = Array.isArray(data) ? data : [];
      setTareas(tareasList);
      
      // Cachear datos
      await offlineService.cacheData('tareas', tareasList, 5);
    } catch (err: any) {
      // Intentar cargar desde cache
      const cached = await offlineService.getCachedData('tareas');
      if (cached.length > 0) {
        setTareas(cached[0].data);
      } else {
        setError(err.message || 'Error al cargar las tareas');
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    loadTareas();
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    loadTareas();
  };

  const getEstadoColor = (estado: string | { codigo?: string; nombre?: string }) => {
    // Manejar tanto string como objeto estado
    const estadoCode = typeof estado === 'string' 
      ? estado.toLowerCase() 
      : estado?.codigo?.toLowerCase() || estado?.nombre?.toLowerCase() || '';
    
    switch (estadoCode) {
      case 'pendiente':
      case 'PENDIENTE':
        return '#f59e0b';
      case 'en_proceso':
      case 'EN_PROCESO':
        return '#2563eb';
      case 'completada':
      case 'COMPLETADA':
        return '#10b981';
      case 'cancelada':
      case 'CANCELADA':
        return '#ef4444';
      default:
        return '#6b7280';
    }
  };

  const getEstadoNombre = (estado: string | { codigo?: string; nombre?: string }) => {
    if (typeof estado === 'string') {
      return estado;
    }
    return estado?.nombre || estado?.codigo || 'Desconocido';
  };

  const renderTarea = ({ item }: { item: Tarea }) => (
    <TouchableOpacity
      style={styles.tareaCard}
      onPress={() => (navigation as any).navigate('TareaDetalle', { tareaId: item.id_tarea })}
    >
      <View style={styles.tareaHeader}>
        <Text style={styles.tareaTitulo} numberOfLines={1}>
          {item.descripcion || 'Sin descripción'}
        </Text>
        <View style={[styles.estadoBadge, { backgroundColor: getEstadoColor(item.estado || {}) }]}>
          <Text style={styles.estadoText}>{getEstadoNombre(item.estado || {})}</Text>
        </View>
      </View>
      
      {item.descripcion && (
        <Text style={styles.tareaDescripcion} numberOfLines={2}>
          {item.descripcion}
        </Text>
      )}

      <View style={styles.tareaFooter}>
        <View style={styles.tareaInfo}>
          <Ionicons name="pricetag" size={14} color="#6b7280" />
          <Text style={styles.tareaInfoText}>
            {typeof item.tipo === 'string' ? item.tipo : item.tipo?.nombre || 'Sin tipo'}
          </Text>
        </View>
        {item.usuarios && item.usuarios.length > 0 && (
          <View style={styles.tareaInfo}>
            <Ionicons name="person" size={14} color="#6b7280" />
            <Text style={styles.tareaInfoText}>{item.usuarios[0].nombre}</Text>
          </View>
        )}
      </View>
    </TouchableOpacity>
  );

  if (loading && !refreshing) {
    return <LoadingSpinner fullScreen={true} />;
  }

  if (error && tareas.length === 0) {
    return (
      <>
        <OfflineBanner />
        <ErrorView message={error} onRetry={loadTareas} />
      </>
    );
  }

  return (
    <View style={styles.container}>
      <OfflineBanner />
      {tareas.length === 0 ? (
        <EmptyState
          icon="list-outline"
          title="No hay tareas"
          message="No se encontraron tareas disponibles"
        />
      ) : (
        <FlatList
          data={tareas}
          renderItem={renderTarea}
          keyExtractor={(item) => item.id_tarea.toString()}
          contentContainerStyle={styles.list}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
          }
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  list: {
    padding: 16,
  },
  tareaCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  tareaHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  tareaTitulo: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
    marginRight: 8,
  },
  estadoBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  estadoText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '600',
  },
  tareaDescripcion: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 12,
  },
  tareaFooter: {
    flexDirection: 'row',
    gap: 16,
  },
  tareaInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  tareaInfoText: {
    fontSize: 12,
    color: '#6b7280',
  },
});

export default TareasScreen;

