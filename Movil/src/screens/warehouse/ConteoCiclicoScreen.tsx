import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  TextInput,
  Modal,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import BarcodeScanner from '../../components/common/BarcodeScanner';
import { playSuccessFeedback, playErrorFeedback } from '../../utils/feedback';

interface TareaConteo {
  id: number;
  tipo: 'ubicacion' | 'producto';
  codigo: string;
  descripcion: string;
  ubicacion_codigo?: string;
  producto_codigo?: string;
  cantidad_sistema?: number;
  estado: string;
}

const ConteoCiclicoScreen: React.FC = () => {
  const [tareas, setTareas] = useState<TareaConteo[]>([]);
  const [tareaActual, setTareaActual] = useState<TareaConteo | null>(null);
  const [cantidadContada, setCantidadContada] = useState<string>('');
  const [scannerVisible, setScannerVisible] = useState(false);
  const [cantidadModalVisible, setCantidadModalVisible] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadTareas();
  }, []);

  const loadTareas = async () => {
    try {
      setLoading(true);
      // TODO: Crear endpoint en backend
      const data = await apiService.get<TareaConteo[]>('/conteo-ciclico/tareas');
      setTareas(data.filter(t => t.estado === 'PENDIENTE'));
    } catch (error: any) {
      if (error.status === 404) {
        Alert.alert('Info', 'Endpoint no disponible aún. Se implementará próximamente.');
      } else {
        Alert.alert('Error', error.message || 'Error al cargar tareas de conteo');
      }
    } finally {
      setLoading(false);
    }
  };

  const iniciarConteo = (tarea: TareaConteo) => {
    setTareaActual(tarea);
    setCantidadContada('');
    
    if (tarea.tipo === 'ubicacion') {
      setScannerVisible(true);
    } else {
      setCantidadModalVisible(true);
    }
  };

  const escanearUbicacion = (codigo: string) => {
    if (!tareaActual) return;
    
    if (codigo !== tareaActual.ubicacion_codigo) {
      playErrorFeedback();
      Alert.alert('Error', 'Ubicación incorrecta');
      return;
    }
    
    playSuccessFeedback();
    setScannerVisible(false);
    setCantidadModalVisible(true);
  };

  const confirmarConteo = async () => {
    if (!tareaActual) return;
    
    const cantidad = parseInt(cantidadContada || '0');
    if (cantidad < 0) {
      Alert.alert('Error', 'La cantidad no puede ser negativa');
      return;
    }
    
    try {
      setLoading(true);
      // TODO: Crear endpoint en backend
      await apiService.post(`/conteo-ciclico/${tareaActual.id}/confirmar`, {
        cantidad_contada: cantidad,
      });
      
      playSuccessFeedback();
      Alert.alert('¡Éxito!', 'Conteo registrado correctamente. Un supervisor revisará las diferencias.');
      
      setCantidadModalVisible(false);
      setTareaActual(null);
      setCantidadContada('');
      loadTareas();
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al confirmar conteo');
    } finally {
      setLoading(false);
    }
  };

  if (loading && tareas.length === 0) {
    return <LoadingSpinner fullScreen={true} />;
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Conteo Cíclico</Text>
        <TouchableOpacity onPress={loadTareas}>
          <Ionicons name="refresh" size={24} color="#2563eb" />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.scrollView}>
        {tareas.length === 0 ? (
          <View style={styles.emptyState}>
            <Ionicons name="calculator-outline" size={64} color="#9ca3af" />
            <Text style={styles.emptyText}>No hay tareas de conteo asignadas</Text>
          </View>
        ) : (
          tareas.map((tarea) => (
            <TouchableOpacity
              key={tarea.id}
              style={styles.tareaCard}
              onPress={() => iniciarConteo(tarea)}
            >
              <View style={styles.tareaHeader}>
                <View style={[styles.tipoBadge, {
                  backgroundColor: tarea.tipo === 'ubicacion' ? '#2563eb15' : '#10b98115'
                }]}>
                  <Ionicons
                    name={tarea.tipo === 'ubicacion' ? 'location' : 'cube'}
                    size={20}
                    color={tarea.tipo === 'ubicacion' ? '#2563eb' : '#10b981'}
                  />
                  <Text style={[styles.tipoText, {
                    color: tarea.tipo === 'ubicacion' ? '#2563eb' : '#10b981'
                  }]}>
                    {tarea.tipo === 'ubicacion' ? 'Ubicación' : 'Producto'}
                  </Text>
                </View>
              </View>
              <Text style={styles.tareaDescripcion}>{tarea.descripcion}</Text>
              <Text style={styles.tareaCodigo}>
                {tarea.tipo === 'ubicacion' ? 'Ubicación' : 'Producto'}: {tarea.codigo}
              </Text>
              {tarea.cantidad_sistema !== undefined && (
                <Text style={styles.tareaCantidad}>
                  Cantidad en sistema: {tarea.cantidad_sistema}
                </Text>
              )}
            </TouchableOpacity>
          ))
        )}
      </ScrollView>

      <BarcodeScanner
        visible={scannerVisible}
        onClose={() => setScannerVisible(false)}
        onScan={escanearUbicacion}
        title="Escanear Ubicación"
        description="Escanea el código de la ubicación a contar"
      />

      <Modal
        visible={cantidadModalVisible}
        transparent
        animationType="slide"
        onRequestClose={() => setCantidadModalVisible(false)}
      >
        <KeyboardAvoidingView
          style={styles.modalOverlay}
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Cantidad Contada</Text>
            {tareaActual && (
              <>
                <Text style={styles.modalSubtitle}>{tareaActual.descripcion}</Text>
                {tareaActual.cantidad_sistema !== undefined && (
                  <Text style={styles.modalInfo}>
                    Cantidad en sistema: {tareaActual.cantidad_sistema}
                  </Text>
                )}
                <Text style={styles.modalInfo}>
                  {tareaActual.tipo === 'ubicacion' 
                    ? 'Cuenta todos los productos en esta ubicación'
                    : 'Cuenta las unidades de este producto'}
                </Text>
              </>
            )}
            <TextInput
              style={styles.cantidadInput}
              value={cantidadContada}
              onChangeText={setCantidadContada}
              keyboardType="numeric"
              placeholder="Ingrese cantidad contada"
              autoFocus
            />
            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setCantidadModalVisible(false);
                  setTareaActual(null);
                  setCantidadContada('');
                }}
              >
                <Text style={styles.modalButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={confirmarConteo}
              >
                <Text style={styles.modalButtonTextConfirm}>Confirmar</Text>
              </TouchableOpacity>
            </View>
          </View>
        </KeyboardAvoidingView>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1f2937',
  },
  scrollView: {
    flex: 1,
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
    marginBottom: 12,
  },
  tipoBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
    gap: 6,
  },
  tipoText: {
    fontSize: 12,
    fontWeight: '600',
  },
  tareaDescripcion: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
    marginBottom: 8,
  },
  tareaCodigo: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 4,
  },
  tareaCantidad: {
    fontSize: 14,
    color: '#2563eb',
    fontWeight: '600',
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    fontSize: 16,
    color: '#6b7280',
    marginTop: 16,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#ffffff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 24,
    paddingBottom: 40,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 8,
  },
  modalSubtitle: {
    fontSize: 16,
    color: '#1f2937',
    marginBottom: 8,
  },
  modalInfo: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 8,
  },
  cantidadInput: {
    borderWidth: 2,
    borderColor: '#e5e7eb',
    borderRadius: 12,
    padding: 16,
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginTop: 16,
    marginBottom: 24,
    backgroundColor: '#f9fafb',
  },
  modalActions: {
    flexDirection: 'row',
    gap: 12,
  },
  modalButton: {
    flex: 1,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  modalButtonCancel: {
    backgroundColor: '#f3f4f6',
  },
  modalButtonConfirm: {
    backgroundColor: '#2563eb',
  },
  modalButtonTextCancel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
  },
  modalButtonTextConfirm: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
  },
});

export default ConteoCiclicoScreen;

