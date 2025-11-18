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

interface OrdenCompra {
  id: number;
  numero_orden: string;
  proveedor: string;
  fecha_esperada: string;
  estado: string;
  items_esperados: number;
  items_recibidos: number;
}

interface ItemRecepcion {
  id: number;
  producto_id: number;
  producto_nombre: string;
  producto_codigo: string;
  cantidad_esperada: number;
  cantidad_recibida: number;
  estado: string;
}

const RecepcionScreen: React.FC = () => {
  const [ordenes, setOrdenes] = useState<OrdenCompra[]>([]);
  const [ordenSeleccionada, setOrdenSeleccionada] = useState<OrdenCompra | null>(null);
  const [items, setItems] = useState<ItemRecepcion[]>([]);
  const [scannerVisible, setScannerVisible] = useState(false);
  const [cantidadModalVisible, setCantidadModalVisible] = useState(false);
  const [productoEscaneado, setProductoEscaneado] = useState<ItemRecepcion | null>(null);
  const [cantidadInput, setCantidadInput] = useState<string>('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadOrdenes();
  }, []);

  const loadOrdenes = async () => {
    try {
      setLoading(true);
      // TODO: Crear endpoint en backend
      const data = await apiService.get<OrdenCompra[]>('/ordenes-compra/pendientes');
      setOrdenes(data);
    } catch (error: any) {
      // Si el endpoint no existe, mostrar mensaje
      if (error.status === 404) {
        Alert.alert('Info', 'Endpoint no disponible aún. Se implementará próximamente.');
      } else {
        Alert.alert('Error', error.message || 'Error al cargar órdenes');
      }
    } finally {
      setLoading(false);
    }
  };

  const seleccionarOrden = async (orden: OrdenCompra) => {
    try {
      setLoading(true);
      setOrdenSeleccionada(orden);
      
      // TODO: Crear endpoint en backend
      const data = await apiService.get<any>(`/ordenes-compra/${orden.id}`);
      setItems(data.items || []);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Error al cargar la orden');
    } finally {
      setLoading(false);
    }
  };

  const escanearProducto = async (codigo: string) => {
    if (!ordenSeleccionada) return;
    
    // Buscar el producto en los items de la orden
    const item = items.find(i => i.producto_codigo === codigo);
    
    if (!item) {
      playErrorFeedback();
      Alert.alert('Error', 'Este producto no está en la orden de compra');
      return;
    }
    
    playSuccessFeedback();
    setScannerVisible(false);
    setProductoEscaneado(item);
    setCantidadInput(item.cantidad_esperada.toString());
    setCantidadModalVisible(true);
  };

  const confirmarRecepcion = async () => {
    if (!productoEscaneado || !ordenSeleccionada) return;
    
    const cantidad = parseInt(cantidadInput || '0');
    if (cantidad <= 0) {
      Alert.alert('Error', 'La cantidad debe ser mayor a 0');
      return;
    }
    
    try {
      setLoading(true);
      // TODO: Crear endpoint en backend
      await apiService.post(`/ordenes-compra/${ordenSeleccionada.id}/recibir`, {
        item_id: productoEscaneado.id,
        cantidad: cantidad,
      });
      
      playSuccessFeedback();
      setCantidadModalVisible(false);
      setProductoEscaneado(null);
      setCantidadInput('');
      
      // Recargar items
      const data = await apiService.get<any>(`/ordenes-compra/${ordenSeleccionada.id}`);
      setItems(data.items || []);
      
      // Si todos los items están recibidos, mostrar mensaje
      const todosRecibidos = data.items?.every((item: ItemRecepcion) => 
        item.cantidad_recibida >= item.cantidad_esperada
      );
      
      if (todosRecibidos) {
        Alert.alert('¡Completado!', 'Todos los productos han sido recibidos.');
        setOrdenSeleccionada(null);
        setItems([]);
        loadOrdenes();
      }
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al confirmar recepción');
    } finally {
      setLoading(false);
    }
  };

  if (loading && !ordenSeleccionada) {
    return <LoadingSpinner fullScreen={true} />;
  }

  if (!ordenSeleccionada) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>Órdenes de Compra</Text>
          <TouchableOpacity onPress={loadOrdenes}>
            <Ionicons name="refresh" size={24} color="#2563eb" />
          </TouchableOpacity>
        </View>
        
        <ScrollView style={styles.scrollView}>
          {ordenes.length === 0 ? (
            <View style={styles.emptyState}>
              <Ionicons name="document-text-outline" size={64} color="#9ca3af" />
              <Text style={styles.emptyText}>No hay órdenes pendientes</Text>
            </View>
          ) : (
            ordenes.map((orden) => (
              <TouchableOpacity
                key={orden.id}
                style={styles.ordenCard}
                onPress={() => seleccionarOrden(orden)}
              >
                <View style={styles.ordenHeader}>
                  <Text style={styles.ordenNumero}>{orden.numero_orden}</Text>
                  <View style={[styles.badge, { backgroundColor: '#2563eb15' }]}>
                    <Text style={[styles.badgeText, { color: '#2563eb' }]}>
                      {orden.estado}
                    </Text>
                  </View>
                </View>
                <Text style={styles.ordenProveedor}>{orden.proveedor}</Text>
                <View style={styles.ordenInfo}>
                  <Text style={styles.ordenInfoText}>
                    {orden.items_recibidos} / {orden.items_esperados} items
                  </Text>
                  <Text style={styles.ordenFecha}>
                    {new Date(orden.fecha_esperada).toLocaleDateString()}
                  </Text>
                </View>
              </TouchableOpacity>
            ))
          )}
        </ScrollView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => {
          setOrdenSeleccionada(null);
          setItems([]);
        }}>
          <Ionicons name="arrow-back" size={24} color="#2563eb" />
        </TouchableOpacity>
        <Text style={styles.title}>{ordenSeleccionada.numero_orden}</Text>
        <View style={{ width: 24 }} />
      </View>

      <ScrollView style={styles.scrollView}>
        <View style={styles.itemsList}>
          {items.map((item) => (
            <View key={item.id} style={styles.itemCard}>
              <View style={styles.itemHeader}>
                <Text style={styles.itemNombre}>{item.producto_nombre}</Text>
                <View style={[
                  styles.estadoBadge,
                  item.cantidad_recibida >= item.cantidad_esperada 
                    ? styles.estadoBadgeCompleto 
                    : styles.estadoBadgePendiente
                ]}>
                  <Text style={styles.estadoBadgeText}>
                    {item.cantidad_recibida >= item.cantidad_esperada ? '✓' : '○'}
                  </Text>
                </View>
              </View>
              <Text style={styles.itemCodigo}>Código: {item.producto_codigo}</Text>
              <View style={styles.cantidadRow}>
                <Text style={styles.cantidadLabel}>Esperada:</Text>
                <Text style={styles.cantidadValue}>{item.cantidad_esperada}</Text>
                <Text style={styles.cantidadLabel}>Recibida:</Text>
                <Text style={[styles.cantidadValue, { color: '#10b981' }]}>
                  {item.cantidad_recibida}
                </Text>
              </View>
            </View>
          ))}
        </View>

        <TouchableOpacity
          style={styles.scanButton}
          onPress={() => setScannerVisible(true)}
        >
          <Ionicons name="scan-outline" size={24} color="#ffffff" />
          <Text style={styles.scanButtonText}>Escanear Producto</Text>
        </TouchableOpacity>
      </ScrollView>

      <BarcodeScanner
        visible={scannerVisible}
        onClose={() => setScannerVisible(false)}
        onScan={escanearProducto}
        title="Escanear Producto"
        description="Escanea el código del producto recibido"
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
            <Text style={styles.modalTitle}>Cantidad Recibida</Text>
            {productoEscaneado && (
              <>
                <Text style={styles.modalSubtitle}>{productoEscaneado.producto_nombre}</Text>
                <Text style={styles.modalInfo}>
                  Cantidad esperada: {productoEscaneado.cantidad_esperada}
                </Text>
              </>
            )}
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
                  setProductoEscaneado(null);
                  setCantidadInput('');
                }}
              >
                <Text style={styles.modalButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={confirmarRecepcion}
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
  ordenCard: {
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
  ordenHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  ordenNumero: {
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
  ordenProveedor: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 8,
  },
  ordenInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  ordenInfoText: {
    fontSize: 14,
    color: '#6b7280',
  },
  ordenFecha: {
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
  itemsList: {
    marginBottom: 16,
  },
  itemCard: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  itemHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  itemNombre: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
  },
  estadoBadge: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  estadoBadgeCompleto: {
    backgroundColor: '#10b98115',
  },
  estadoBadgePendiente: {
    backgroundColor: '#f59e0b15',
  },
  estadoBadgeText: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  itemCodigo: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 8,
  },
  cantidadRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  cantidadLabel: {
    fontSize: 14,
    color: '#6b7280',
  },
  cantidadValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2563eb',
  },
  scanButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2563eb',
    padding: 16,
    borderRadius: 12,
    gap: 8,
    marginTop: 16,
  },
  scanButtonText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '600',
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

export default RecepcionScreen;

