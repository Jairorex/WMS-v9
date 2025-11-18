import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import ErrorView from '../../components/common/ErrorView';
import { Ionicons } from '@expo/vector-icons';
import { Tarea } from '../../types/api';

const TareaDetalleScreen: React.FC = () => {
  const route = useRoute();
  const navigation = useNavigation();
  const { tareaId } = route.params as { tareaId: number };
  
  const [tarea, setTarea] = useState<Tarea | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadTarea();
  }, [tareaId]);

  const loadTarea = async () => {
    try {
      setError(null);
      // La API devuelve { success: true, data: Tarea }
      const data = await apiService.get<Tarea>(`${API_ENDPOINTS.TAREAS.BASE}/${tareaId}`);
      setTarea(data);
    } catch (err: any) {
      setError(err.message || 'Error al cargar la tarea');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner fullScreen={true} />;
  }

  if (error || !tarea) {
    return <ErrorView message={error || 'Tarea no encontrada'} onRetry={loadTarea} />;
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.titulo}>{tarea.descripcion || 'Sin descripción'}</Text>
        
        {tarea.descripcion && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Descripción</Text>
            <Text style={styles.descripcion}>{tarea.descripcion}</Text>
          </View>
        )}

        <View style={styles.infoGrid}>
          <InfoItem 
            label="Tipo" 
            value={typeof tarea.tipo === 'string' ? tarea.tipo : tarea.tipo?.nombre || 'Sin tipo'} 
            icon="pricetag" 
          />
          <InfoItem 
            label="Estado" 
            value={typeof tarea.estado === 'string' ? tarea.estado : tarea.estado?.nombre || 'Sin estado'} 
            icon="flag" 
          />
          <InfoItem label="Prioridad" value={tarea.prioridad || 'Sin prioridad'} icon="alert-circle" />
          {tarea.usuarios && tarea.usuarios.length > 0 && (
            <InfoItem label="Asignado a" value={tarea.usuarios[0].nombre} icon="person" />
          )}
        </View>
      </View>
    </ScrollView>
  );
};

interface InfoItemProps {
  label: string;
  value: string;
  icon: keyof typeof Ionicons.glyphMap;
}

const InfoItem: React.FC<InfoItemProps> = ({ label, value, icon }) => {
  return (
    <View style={styles.infoItem}>
      <Ionicons name={icon} size={20} color="#6b7280" />
      <View style={styles.infoContent}>
        <Text style={styles.infoLabel}>{label}</Text>
        <Text style={styles.infoValue}>{value}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  content: {
    padding: 16,
  },
  titulo: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 24,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 8,
  },
  descripcion: {
    fontSize: 14,
    color: '#6b7280',
    lineHeight: 20,
  },
  infoGrid: {
    gap: 16,
  },
  infoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#f9fafb',
    borderRadius: 12,
    gap: 12,
  },
  infoContent: {
    flex: 1,
  },
  infoLabel: {
    fontSize: 12,
    color: '#6b7280',
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 16,
    fontWeight: '500',
    color: '#1f2937',
  },
});

export default TareaDetalleScreen;

