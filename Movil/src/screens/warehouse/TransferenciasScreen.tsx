import React, { useState } from 'react';
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

const TransferenciasScreen: React.FC = () => {
  const [paso, setPaso] = useState<'producto' | 'origen' | 'destino' | 'cantidad' | 'confirmacion'>('producto');
  const [productoEscaneado, setProductoEscaneado] = useState<string>('');
  const [productoInfo, setProductoInfo] = useState<any>(null);
  const [ubicacionOrigen, setUbicacionOrigen] = useState<string>('');
  const [stockOrigen, setStockOrigen] = useState<number>(0);
  const [ubicacionDestino, setUbicacionDestino] = useState<string>('');
  const [cantidad, setCantidad] = useState<string>('');
  const [scannerVisible, setScannerVisible] = useState(false);
  const [cantidadModalVisible, setCantidadModalVisible] = useState(false);
  const [loading, setLoading] = useState(false);

  const escanearProducto = async (codigo: string) => {
    try {
      setLoading(true);
      setProductoEscaneado(codigo);
      
      const producto = await apiService.get<any>(`${API_ENDPOINTS.PRODUCTOS.BASE}/por-codigo/${codigo}`);
      setProductoInfo(producto);
      
      playSuccessFeedback();
      setPaso('origen');
      setScannerVisible(false);
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Producto no encontrado');
      setScannerVisible(false);
    } finally {
      setLoading(false);
    }
  };

  const escanearUbicacionOrigen = async (codigo: string) => {
    if (!productoInfo) return;
    
    try {
      setLoading(true);
      // Verificar stock en la ubicación
      const stock = await apiService.get<any>(
        `${API_ENDPOINTS.INVENTARIO.POR_UBICACION(codigo)}`
      );
      
      const productoEnUbicacion = stock.find((item: any) => 
        item.producto_codigo === productoEscaneado
      );
      
      if (!productoEnUbicacion || productoEnUbicacion.cantidad <= 0) {
        playErrorFeedback();
        Alert.alert('Error', 'No hay stock de este producto en la ubicación origen');
        setScannerVisible(false);
        return;
      }
      
      setUbicacionOrigen(codigo);
      setStockOrigen(productoEnUbicacion.cantidad);
      playSuccessFeedback();
      setPaso('destino');
      setScannerVisible(false);
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al verificar ubicación origen');
      setScannerVisible(false);
    } finally {
      setLoading(false);
    }
  };

  const escanearUbicacionDestino = (codigo: string) => {
    if (codigo === ubicacionOrigen) {
      playErrorFeedback();
      Alert.alert('Error', 'La ubicación destino no puede ser la misma que la origen');
      return;
    }
    
    setUbicacionDestino(codigo);
    playSuccessFeedback();
    setPaso('cantidad');
    setScannerVisible(false);
    setCantidadModalVisible(true);
  };

  const confirmarTransferencia = async () => {
    if (!productoInfo || !ubicacionOrigen || !ubicacionDestino) return;
    
    const cantidadNum = parseInt(cantidad || '0');
    if (cantidadNum <= 0) {
      Alert.alert('Error', 'La cantidad debe ser mayor a 0');
      return;
    }
    
    if (cantidadNum > stockOrigen) {
      Alert.alert('Error', `No hay suficiente stock. Disponible: ${stockOrigen}`);
      return;
    }
    
    try {
      setLoading(true);
      // TODO: Crear endpoint en backend
      await apiService.post(`${API_ENDPOINTS.INVENTARIO.BASE}/transferir`, {
        producto_id: productoInfo.id_producto,
        ubicacion_origen: ubicacionOrigen,
        ubicacion_destino: ubicacionDestino,
        cantidad: cantidadNum,
      });
      
      playSuccessFeedback();
      Alert.alert('¡Éxito!', 'Transferencia realizada correctamente.', [
        {
          text: 'OK',
          onPress: () => {
            // Reiniciar
            setPaso('producto');
            setProductoEscaneado('');
            setProductoInfo(null);
            setUbicacionOrigen('');
            setStockOrigen(0);
            setUbicacionDestino('');
            setCantidad('');
          },
        },
      ]);
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al realizar la transferencia');
    } finally {
      setLoading(false);
      setCantidadModalVisible(false);
    }
  };

  if (loading && paso === 'producto') {
    return <LoadingSpinner fullScreen={true} />;
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Transferencias Internas</Text>
      </View>

      <ScrollView style={styles.scrollView}>
        {/* Paso 1: Producto */}
        {paso === 'producto' && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#2563eb' }]}>
                <Text style={styles.stepNumberText}>1</Text>
              </View>
              <Text style={styles.stepTitle}>Escanear Producto</Text>
            </View>
            <Text style={styles.stepDescription}>
              Escanea el código del producto que deseas transferir
            </Text>
            <TouchableOpacity
              style={styles.scanButton}
              onPress={() => setScannerVisible(true)}
            >
              <Ionicons name="scan-outline" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Escanear Producto</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Paso 2: Ubicación Origen */}
        {paso === 'origen' && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#ef4444' }]}>
                <Text style={styles.stepNumberText}>2</Text>
              </View>
              <Text style={styles.stepTitle}>Ubicación Origen</Text>
            </View>
            {productoInfo && (
              <View style={styles.infoCard}>
                <Text style={styles.infoLabel}>Producto:</Text>
                <Text style={styles.infoValue}>{productoInfo.nombre}</Text>
                <Text style={styles.infoSubtext}>Código: {productoEscaneado}</Text>
              </View>
            )}
            <TouchableOpacity
              style={styles.scanButton}
              onPress={() => setScannerVisible(true)}
            >
              <Ionicons name="scan-outline" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Escanear Ubicación Origen</Text>
            </TouchableOpacity>
            {ubicacionOrigen && (
              <View style={styles.infoCard}>
                <Text style={styles.infoLabel}>Ubicación Origen:</Text>
                <Text style={styles.infoValue}>{ubicacionOrigen}</Text>
                <Text style={styles.infoSubtext}>Stock disponible: {stockOrigen}</Text>
              </View>
            )}
          </View>
        )}

        {/* Paso 3: Ubicación Destino */}
        {paso === 'destino' && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#10b981' }]}>
                <Text style={styles.stepNumberText}>3</Text>
              </View>
              <Text style={styles.stepTitle}>Ubicación Destino</Text>
            </View>
            <TouchableOpacity
              style={styles.scanButton}
              onPress={() => setScannerVisible(true)}
            >
              <Ionicons name="scan-outline" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Escanear Ubicación Destino</Text>
            </TouchableOpacity>
            {ubicacionDestino && (
              <View style={styles.infoCard}>
                <Text style={styles.infoLabel}>Ubicación Destino:</Text>
                <Text style={styles.infoValue}>{ubicacionDestino}</Text>
              </View>
            )}
          </View>
        )}

        {/* Paso 4: Confirmación */}
        {paso === 'confirmacion' && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#f59e0b' }]}>
                <Text style={styles.stepNumberText}>4</Text>
              </View>
              <Text style={styles.stepTitle}>Confirmar Transferencia</Text>
            </View>

            <View style={styles.resumenCard}>
              {productoInfo && (
                <View style={styles.resumenItem}>
                  <Text style={styles.resumenLabel}>Producto:</Text>
                  <Text style={styles.resumenValue}>{productoInfo.nombre}</Text>
                </View>
              )}
              <View style={styles.resumenItem}>
                <Text style={styles.resumenLabel}>Desde:</Text>
                <Text style={styles.resumenValue}>{ubicacionOrigen}</Text>
              </View>
              <View style={styles.resumenItem}>
                <Text style={styles.resumenLabel}>Hacia:</Text>
                <Text style={styles.resumenValue}>{ubicacionDestino}</Text>
              </View>
              <View style={styles.resumenItem}>
                <Text style={styles.resumenLabel}>Cantidad:</Text>
                <Text style={styles.resumenValue}>{cantidad}</Text>
              </View>
            </View>

            <TouchableOpacity
              style={[styles.scanButton, styles.confirmButton]}
              onPress={confirmarTransferencia}
            >
              <Ionicons name="checkmark" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Confirmar Transferencia</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.scanButton, styles.cancelButton]}
              onPress={() => {
                setPaso('producto');
                setProductoEscaneado('');
                setProductoInfo(null);
                setUbicacionOrigen('');
                setStockOrigen(0);
                setUbicacionDestino('');
                setCantidad('');
              }}
            >
              <Text style={[styles.scanButtonText, { color: '#1f2937' }]}>Cancelar</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>

      <BarcodeScanner
        visible={scannerVisible}
        onClose={() => setScannerVisible(false)}
        onScan={(data) => {
          if (paso === 'producto') {
            escanearProducto(data);
          } else if (paso === 'origen') {
            escanearUbicacionOrigen(data);
          } else if (paso === 'destino') {
            escanearUbicacionDestino(data);
          }
        }}
        title={
          paso === 'producto'
            ? 'Escanear Producto'
            : paso === 'origen'
            ? 'Escanear Ubicación Origen'
            : 'Escanear Ubicación Destino'
        }
        description={
          paso === 'producto'
            ? 'Escanea el código del producto'
            : paso === 'origen'
            ? 'Escanea el código de la ubicación origen'
            : 'Escanea el código de la ubicación destino'
        }
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
            <Text style={styles.modalTitle}>Cantidad a Transferir</Text>
            <Text style={styles.modalInfo}>
              Stock disponible en origen: {stockOrigen}
            </Text>
            <TextInput
              style={styles.cantidadInput}
              value={cantidad}
              onChangeText={setCantidad}
              keyboardType="numeric"
              placeholder="Ingrese cantidad"
              autoFocus
            />
            <View style={styles.modalActions}>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonCancel]}
                onPress={() => {
                  setCantidadModalVisible(false);
                  setCantidad('');
                }}
              >
                <Text style={styles.modalButtonTextCancel}>Cancelar</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalButton, styles.modalButtonConfirm]}
                onPress={() => {
                  const cantidadNum = parseInt(cantidad || '0');
                  if (cantidadNum > 0 && cantidadNum <= stockOrigen) {
                    setCantidadModalVisible(false);
                    setPaso('confirmacion');
                  } else {
                    Alert.alert('Error', 'Cantidad inválida');
                  }
                }}
              >
                <Text style={styles.modalButtonTextConfirm}>Continuar</Text>
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
  stepContainer: {
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
  stepHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  stepNumber: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  stepNumberText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  stepTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1f2937',
  },
  stepDescription: {
    fontSize: 16,
    color: '#6b7280',
    marginBottom: 24,
    lineHeight: 24,
  },
  scanButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2563eb',
    padding: 20,
    borderRadius: 12,
    gap: 12,
  },
  scanButtonText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '600',
  },
  confirmButton: {
    backgroundColor: '#10b981',
    marginBottom: 12,
  },
  cancelButton: {
    backgroundColor: '#f3f4f6',
  },
  infoCard: {
    backgroundColor: '#f9fafb',
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
  },
  infoLabel: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
  },
  infoSubtext: {
    fontSize: 14,
    color: '#6b7280',
    marginTop: 4,
  },
  resumenCard: {
    backgroundColor: '#f9fafb',
    padding: 20,
    borderRadius: 12,
    marginBottom: 24,
  },
  resumenItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  resumenLabel: {
    fontSize: 16,
    color: '#6b7280',
  },
  resumenValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1f2937',
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

export default TransferenciasScreen;

