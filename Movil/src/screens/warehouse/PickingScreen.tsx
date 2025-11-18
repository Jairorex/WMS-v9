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
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import BarcodeScanner from '../../components/common/BarcodeScanner';
import { playSuccessFeedback, playErrorFeedback } from '../../utils/feedback';

interface PedidoPicking {
  id: number;
  numero_pedido: string;
  estado: string;
  total_items: number;
  items_completados: number;
  fecha_creacion: string;
}

interface ItemPicking {
  id: number;
  producto_id: number;
  producto_nombre: string;
  producto_codigo: string;
  ubicacion: string;
  cantidad_solicitada: number;
  cantidad_pickeada: number;
  estado: string;
}

const PickingScreen: React.FC = () => {
  const navigation = useNavigation();
  const [pedidos, setPedidos] = useState<PedidoPicking[]>([]);
  const [pedidoSeleccionado, setPedidoSeleccionado] = useState<PedidoPicking | null>(null);
  const [items, setItems] = useState<ItemPicking[]>([]);
  const [itemActual, setItemActual] = useState<ItemPicking | null>(null);
  const [cantidadEscaneada, setCantidadEscaneada] = useState<string>('');
  const [scannerVisible, setScannerVisible] = useState(false);
  const [cantidadModalVisible, setCantidadModalVisible] = useState(false);
  const [cantidadInput, setCantidadInput] = useState<string>('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadPedidos();
  }, []);

  const loadPedidos = async () => {
    try {
      setLoading(true);
      const data = await apiService.get<PedidoPicking[]>(API_ENDPOINTS.PICKING.BASE);
      setPedidos(data.filter((p: PedidoPicking) => p.estado === 'ASIGNADO' || p.estado === 'EN_PROCESO'));
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Error al cargar pedidos');
    } finally {
      setLoading(false);
    }
  };

  const seleccionarPedido = async (pedido: PedidoPicking) => {
    try {
      setLoading(true);
      setPedidoSeleccionado(pedido);
      
      // Cargar items del pedido
      const data = await apiService.get<any>(`${API_ENDPOINTS.PICKING.BASE}/${pedido.id}`);
      setItems(data.items || []);
      
      // Encontrar el primer item pendiente
      const itemPendiente = data.items?.find((item: ItemPicking) => 
        item.estado === 'PENDIENTE' || item.cantidad_pickeada < item.cantidad_solicitada
      );
      setItemActual(itemPendiente || null);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Error al cargar el pedido');
    } finally {
      setLoading(false);
    }
  };

  const escanearUbicacion = (codigo: string) => {
    if (!itemActual) return;
    
    // Verificar que la ubicación escaneada coincida
    if (codigo !== itemActual.ubicacion) {
      playErrorFeedback();
      Alert.alert('Error', `Ubicación incorrecta. Esperada: ${itemActual.ubicacion}`);
      return;
    }
    
    playSuccessFeedback();
    setScannerVisible(false);
    // Continuar con el escaneo del producto
    Alert.alert('Correcto', 'Ubicación confirmada. Ahora escanea el producto.');
  };

  const escanearProducto = async (codigo: string) => {
    if (!itemActual) return;
    
    // Verificar que el producto escaneado coincida
    if (codigo !== itemActual.producto_codigo) {
      playErrorFeedback();
      Alert.alert('Error', 'Producto incorrecto. Por favor escanea el producto correcto.');
      return;
    }
    
    playSuccessFeedback();
    setScannerVisible(false);
    
    // Si la cantidad es 1, confirmar automáticamente
    if (itemActual.cantidad_solicitada === 1) {
      await confirmarPicking(1);
    } else {
      // Mostrar modal para cantidad
      setCantidadInput(itemActual.cantidad_solicitada.toString());
      setCantidadModalVisible(true);
    }
  };

  const confirmarPicking = async (cantidad: number) => {
    if (!itemActual || !pedidoSeleccionado) return;
    
    try {
      setLoading(true);
      await apiService.post(`${API_ENDPOINTS.PICKING.BASE}/${pedidoSeleccionado.id}/pick-item`, {
        item_id: itemActual.id,
        cantidad: cantidad,
      });
      
      playSuccessFeedback();
      
      // Recargar items
      const data = await apiService.get<any>(`${API_ENDPOINTS.PICKING.BASE}/${pedidoSeleccionado.id}`);
      setItems(data.items || []);
      
      // Buscar siguiente item pendiente
      const itemPendiente = data.items?.find((item: ItemPicking) => 
        item.estado === 'PENDIENTE' || item.cantidad_pickeada < item.cantidad_solicitada
      );
      
      if (!itemPendiente) {
        Alert.alert('¡Completado!', 'Todos los items han sido recogidos.');
        setPedidoSeleccionado(null);
        setItemActual(null);
        setItems([]);
        loadPedidos();
      } else {
        setItemActual(itemPendiente);
      }
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al confirmar picking');
    } finally {
      setLoading(false);
    }
  };

  if (loading && !pedidoSeleccionado) {
    return <LoadingSpinner fullScreen={true} />;
  }

  // Vista de selección de pedido
  if (!pedidoSeleccionado) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>Pedidos de Picking</Text>
          <TouchableOpacity onPress={loadPedidos}>
            <Ionicons name="refresh" size={24} color="#2563eb" />
          </TouchableOpacity>
        </View>
        
        <ScrollView style={styles.scrollView}>
          {pedidos.length === 0 ? (
            <View style={styles.emptyState}>
              <Ionicons name="cart-outline" size={64} color="#9ca3af" />
              <Text style={styles.emptyText}>No hay pedidos asignados</Text>
            </View>
          ) : (
            pedidos.map((pedido) => (
              <TouchableOpacity
                key={pedido.id}
                style={styles.pedidoCard}
                onPress={() => seleccionarPedido(pedido)}
              >
                <View style={styles.pedidoHeader}>
                  <Text style={styles.pedidoNumero}>{pedido.numero_pedido}</Text>
                  <View style={[styles.badge, { backgroundColor: '#f59e0b15' }]}>
                    <Text style={[styles.badgeText, { color: '#f59e0b' }]}>
                      {pedido.estado}
                    </Text>
                  </View>
                </View>
                <View style={styles.pedidoInfo}>
                  <Text style={styles.pedidoInfoText}>
                    {pedido.items_completados} / {pedido.total_items} items
                  </Text>
                  <Text style={styles.pedidoFecha}>
                    {new Date(pedido.fecha_creacion).toLocaleDateString()}
                  </Text>
                </View>
              </TouchableOpacity>
            ))
          )}
        </ScrollView>
      </View>
    );
  }

  // Vista de picking activo
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => {
          setPedidoSeleccionado(null);
          setItemActual(null);
          setItems([]);
        }}>
          <Ionicons name="arrow-back" size={24} color="#2563eb" />
        </TouchableOpacity>
        <Text style={styles.title}>{pedidoSeleccionado.numero_pedido}</Text>
        <View style={{ width: 24 }} />
      </View>

      {itemActual ? (
        <View style={styles.pickingContainer}>
          <View style={styles.itemCard}>
            <Text style={styles.itemTitle}>Producto a Recoger</Text>
            <Text style={styles.itemNombre}>{itemActual.producto_nombre}</Text>
            <Text style={styles.itemCodigo}>Código: {itemActual.producto_codigo}</Text>
            
            <View style={styles.ubicacionCard}>
              <Ionicons name="location" size={24} color="#10b981" />
              <Text style={styles.ubicacionText}>Ubicación: {itemActual.ubicacion}</Text>
            </View>
            
            <View style={styles.cantidadCard}>
              <Text style={styles.cantidadLabel}>Cantidad Solicitada:</Text>
              <Text style={styles.cantidadValue}>{itemActual.cantidad_solicitada}</Text>
            </View>

            <View style={styles.actions}>
              <TouchableOpacity
                style={[styles.button, styles.buttonPrimary]}
                onPress={() => setScannerVisible(true)}
              >
                <Ionicons name="scan-outline" size={24} color="#ffffff" />
                <Text style={styles.buttonText}>Escanear Ubicación</Text>
              </TouchableOpacity>
            </View>
          </View>

          <View style={styles.progressCard}>
            <Text style={styles.progressTitle}>Progreso del Pedido</Text>
            <View style={styles.progressBar}>
              <View
                style={[
                  styles.progressFill,
                  {
                    width: `${(pedidoSeleccionado.items_completados / pedidoSeleccionado.total_items) * 100}%`,
                  },
                ]}
              />
            </View>
            <Text style={styles.progressText}>
              {pedidoSeleccionado.items_completados} / {pedidoSeleccionado.total_items} items
            </Text>
          </View>
        </View>
      ) : (
        <View style={styles.emptyState}>
          <Ionicons name="checkmark-circle" size={64} color="#10b981" />
          <Text style={styles.emptyText}>Pedido completado</Text>
        </View>
      )}

      <BarcodeScanner
        visible={scannerVisible}
        onClose={() => setScannerVisible(false)}
        onScan={(data) => {
          if (!itemActual) return;
          // Determinar si es ubicación o producto basado en el contexto
          if (data === itemActual.ubicacion) {
            escanearUbicacion(data);
          } else {
            escanearProducto(data);
          }
        }}
        title="Escanear Código"
        description="Escanea la ubicación o el producto"
      />

      {/* Modal para ingresar cantidad */}
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
            <Text style={styles.modalTitle}>Cantidad a Recoger</Text>
            <Text style={styles.modalSubtitle}>
              Cantidad solicitada: {itemActual?.cantidad_solicitada}
            </Text>
            <TextInput
              style={styles.cantidadInput}
              value={cantidadInput}
              onChangeText={setCantidadInput}
              keyboardType="numeric"
              placeholder="Ingrese cantidad"
              autoFocus
            />
            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setCantidadModalVisible(false);
                  setCantidadInput('');
                }}
              >
                <Text style={styles.modalButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={async () => {
                  const cantidadNum = parseInt(cantidadInput || '0');
                  if (cantidadNum > 0 && cantidadNum <= (itemActual?.cantidad_solicitada || 0)) {
                    setCantidadModalVisible(false);
                    setCantidadInput('');
                    await confirmarPicking(cantidadNum);
                  } else {
                    Alert.alert('Error', 'Cantidad inválida');
                  }
                }}
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
  pedidoCard: {
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
  pedidoHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  pedidoNumero: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  badgeText: {
    fontSize: 12,
    fontWeight: '600',
  },
  pedidoInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  pedidoInfoText: {
    fontSize: 14,
    color: '#6b7280',
  },
  pedidoFecha: {
    fontSize: 14,
    color: '#6b7280',
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
  pickingContainer: {
    flex: 1,
    padding: 16,
  },
  itemCard: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 24,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  itemTitle: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 8,
  },
  itemNombre: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 8,
  },
  itemCodigo: {
    fontSize: 16,
    color: '#6b7280',
    marginBottom: 24,
  },
  ubicacionCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f0fdf4',
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
  },
  ubicacionText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#10b981',
    marginLeft: 12,
  },
  cantidadCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#f9fafb',
    padding: 16,
    borderRadius: 12,
    marginBottom: 24,
  },
  cantidadLabel: {
    fontSize: 16,
    color: '#6b7280',
  },
  cantidadValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2563eb',
  },
  actions: {
    gap: 12,
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    gap: 8,
  },
  buttonPrimary: {
    backgroundColor: '#2563eb',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '600',
  },
  progressCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  progressTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
    marginBottom: 12,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#e5e7eb',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 8,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#10b981',
  },
  progressText: {
    fontSize: 14,
    color: '#6b7280',
    textAlign: 'center',
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
    color: '#6b7280',
    marginBottom: 24,
  },
  cantidadInput: {
    borderWidth: 2,
    borderColor: '#e5e7eb',
    borderRadius: 12,
    padding: 16,
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
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

export default PickingScreen;

