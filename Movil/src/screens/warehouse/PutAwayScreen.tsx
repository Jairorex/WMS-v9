import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import BarcodeScanner from '../../components/common/BarcodeScanner';
import { playSuccessFeedback, playErrorFeedback } from '../../utils/feedback';

interface UbicacionSugerida {
  ubicacion_id: number;
  codigo: string;
  ubicacion_completa: string;
  razon: string;
  espacio_disponible: number;
}

const PutAwayScreen: React.FC = () => {
  const [paso, setPaso] = useState<'producto' | 'ubicacion' | 'confirmacion'>('producto');
  const [productoEscaneado, setProductoEscaneado] = useState<string>('');
  const [productoInfo, setProductoInfo] = useState<any>(null);
  const [ubicacionSugerida, setUbicacionSugerida] = useState<UbicacionSugerida | null>(null);
  const [ubicacionConfirmada, setUbicacionConfirmada] = useState<string>('');
  const [scannerVisible, setScannerVisible] = useState(false);
  const [loading, setLoading] = useState(false);

  const escanearProducto = async (codigo: string) => {
    try {
      setLoading(true);
      setProductoEscaneado(codigo);
      
      // Obtener información del producto
      const producto = await apiService.get<any>(`${API_ENDPOINTS.PRODUCTOS.BASE}/por-codigo/${codigo}`);
      setProductoInfo(producto);
      
      // Obtener sugerencia de ubicación
      const sugerencia = await apiService.get<UbicacionSugerida>(
        `${API_ENDPOINTS.UBICACIONES.BASE}/sugerir/${producto.id_producto}`
      );
      setUbicacionSugerida(sugerencia);
      
      playSuccessFeedback();
      setPaso('ubicacion');
      setScannerVisible(false);
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al obtener información del producto');
      setScannerVisible(false);
    } finally {
      setLoading(false);
    }
  };

  const escanearUbicacion = async (codigo: string) => {
    if (!ubicacionSugerida) return;
    
    // Verificar que la ubicación escaneada coincida con la sugerida
    if (codigo !== ubicacionSugerida.codigo) {
      playErrorFeedback();
      Alert.alert(
        'Ubicación Incorrecta',
        `La ubicación escaneada no coincide con la sugerida.\n\nSugerida: ${ubicacionSugerida.ubicacion_completa}\nEscaneada: ${codigo}\n\n¿Desea continuar de todas formas?`,
        [
          { text: 'Cancelar', style: 'cancel' },
          {
            text: 'Continuar',
            onPress: () => {
              setUbicacionConfirmada(codigo);
              setPaso('confirmacion');
            },
          },
        ]
      );
      return;
    }
    
    playSuccessFeedback();
    setUbicacionConfirmada(codigo);
    setPaso('confirmacion');
    setScannerVisible(false);
  };

  const confirmarGuardado = async () => {
    if (!productoInfo || !ubicacionConfirmada) return;
    
    try {
      setLoading(true);
      await apiService.post(`${API_ENDPOINTS.INVENTARIO.BASE}/guardar`, {
        producto_id: productoInfo.id_producto,
        ubicacion_codigo: ubicacionConfirmada,
        cantidad: 1, // Por defecto 1, se puede ajustar
      });
      
      playSuccessFeedback();
      Alert.alert('¡Éxito!', 'Producto guardado correctamente en la ubicación.', [
        {
          text: 'OK',
          onPress: () => {
            // Reiniciar el flujo
            setPaso('producto');
            setProductoEscaneado('');
            setProductoInfo(null);
            setUbicacionSugerida(null);
            setUbicacionConfirmada('');
          },
        },
      ]);
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al guardar el producto');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner fullScreen={true} />;
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Guardado (Put-Away)</Text>
      </View>

      <ScrollView style={styles.scrollView}>
        {paso === 'producto' && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#2563eb' }]}>
                <Text style={styles.stepNumberText}>1</Text>
              </View>
              <Text style={styles.stepTitle}>Escanear Producto</Text>
            </View>
            <Text style={styles.stepDescription}>
              Escanea el código de barras del producto o pallet que deseas guardar
            </Text>
            <TouchableOpacity
              style={styles.scanButton}
              onPress={() => setScannerVisible(true)}
            >
              <Ionicons name="scan-outline" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Escanear Producto</Text>
            </TouchableOpacity>
            {productoEscaneado && (
              <View style={styles.infoCard}>
                <Text style={styles.infoLabel}>Código Escaneado:</Text>
                <Text style={styles.infoValue}>{productoEscaneado}</Text>
              </View>
            )}
          </View>
        )}

        {paso === 'ubicacion' && ubicacionSugerida && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#10b981' }]}>
                <Text style={styles.stepNumberText}>2</Text>
              </View>
              <Text style={styles.stepTitle}>Ubicación Sugerida</Text>
            </View>

            {productoInfo && (
              <View style={styles.productoCard}>
                <Text style={styles.productoNombre}>{productoInfo.nombre}</Text>
                <Text style={styles.productoCodigo}>Código: {productoEscaneado}</Text>
              </View>
            )}

            <View style={styles.ubicacionCard}>
              <Ionicons name="location" size={48} color="#10b981" />
              <Text style={styles.ubicacionCodigo}>{ubicacionSugerida.ubicacion_completa}</Text>
              <Text style={styles.ubicacionRazon}>{ubicacionSugerida.razon}</Text>
              <Text style={styles.ubicacionEspacio}>
                Espacio disponible: {ubicacionSugerida.espacio_disponible}
              </Text>
            </View>

            <TouchableOpacity
              style={styles.scanButton}
              onPress={() => setScannerVisible(true)}
            >
              <Ionicons name="scan-outline" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Confirmar Ubicación</Text>
            </TouchableOpacity>
          </View>
        )}

        {paso === 'confirmacion' && (
          <View style={styles.stepContainer}>
            <View style={styles.stepHeader}>
              <View style={[styles.stepNumber, { backgroundColor: '#f59e0b' }]}>
                <Text style={styles.stepNumberText}>3</Text>
              </View>
              <Text style={styles.stepTitle}>Confirmar Guardado</Text>
            </View>

            {productoInfo && (
              <View style={styles.productoCard}>
                <Text style={styles.productoNombre}>{productoInfo.nombre}</Text>
                <Text style={styles.productoCodigo}>Código: {productoEscaneado}</Text>
              </View>
            )}

            <View style={styles.confirmacionCard}>
              <Ionicons name="checkmark-circle" size={48} color="#10b981" />
              <Text style={styles.confirmacionText}>
                Guardar en: {ubicacionConfirmada}
              </Text>
            </View>

            <TouchableOpacity
              style={[styles.scanButton, styles.confirmButton]}
              onPress={confirmarGuardado}
            >
              <Ionicons name="checkmark" size={32} color="#ffffff" />
              <Text style={styles.scanButtonText}>Confirmar Guardado</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.scanButton, styles.cancelButton]}
              onPress={() => {
                setPaso('producto');
                setProductoEscaneado('');
                setProductoInfo(null);
                setUbicacionSugerida(null);
                setUbicacionConfirmada('');
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
          } else if (paso === 'ubicacion') {
            escanearUbicacion(data);
          }
        }}
        title={paso === 'producto' ? 'Escanear Producto' : 'Escanear Ubicación'}
        description={
          paso === 'producto'
            ? 'Escanea el código del producto'
            : 'Escanea el código de la ubicación'
        }
      />
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
    marginTop: 16,
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
  productoCard: {
    backgroundColor: '#f9fafb',
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
  },
  productoNombre: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 4,
  },
  productoCodigo: {
    fontSize: 14,
    color: '#6b7280',
  },
  ubicacionCard: {
    backgroundColor: '#f0fdf4',
    padding: 24,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 24,
    borderWidth: 2,
    borderColor: '#10b981',
  },
  ubicacionCodigo: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#10b981',
    marginTop: 12,
    marginBottom: 8,
  },
  ubicacionRazon: {
    fontSize: 14,
    color: '#6b7280',
    textAlign: 'center',
    marginBottom: 8,
  },
  ubicacionEspacio: {
    fontSize: 12,
    color: '#10b981',
    fontWeight: '600',
  },
  confirmacionCard: {
    backgroundColor: '#f0fdf4',
    padding: 24,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 24,
  },
  confirmacionText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#10b981',
    marginTop: 12,
    textAlign: 'center',
  },
});

export default PutAwayScreen;

