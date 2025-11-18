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

interface StockUbicacion {
  producto_id: number;
  producto_nombre: string;
  producto_codigo: string;
  cantidad: number;
  lote_id?: number;
  lote_codigo?: string;
}

interface StockProducto {
  ubicacion_id: number;
  ubicacion_codigo: string;
  ubicacion_completa: string;
  cantidad: number;
  lote_id?: number;
  lote_codigo?: string;
}

const ConsultaStockScreen: React.FC = () => {
  const [modo, setModo] = useState<'ubicacion' | 'producto' | null>(null);
  const [scannerVisible, setScannerVisible] = useState(false);
  const [loading, setLoading] = useState(false);
  const [stockUbicacion, setStockUbicacion] = useState<StockUbicacion[]>([]);
  const [stockProducto, setStockProducto] = useState<StockProducto[]>([]);
  const [codigoEscaneado, setCodigoEscaneado] = useState<string>('');

  const consultarPorUbicacion = async (codigoUbicacion: string) => {
    try {
      setLoading(true);
      setModo('ubicacion');
      setCodigoEscaneado(codigoUbicacion);
      
      const data = await apiService.get<StockUbicacion[]>(
        `${API_ENDPOINTS.INVENTARIO.BASE}/por-ubicacion/${codigoUbicacion}`
      );
      
      setStockUbicacion(data);
      playSuccessFeedback();
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al consultar stock por ubicación');
      setStockUbicacion([]);
    } finally {
      setLoading(false);
    }
  };

  const consultarPorProducto = async (codigoProducto: string) => {
    try {
      setLoading(true);
      setModo('producto');
      setCodigoEscaneado(codigoProducto);
      
      const data = await apiService.get<StockProducto[]>(
        `${API_ENDPOINTS.INVENTARIO.BASE}/por-producto/${codigoProducto}`
      );
      
      setStockProducto(data);
      playSuccessFeedback();
    } catch (error: any) {
      playErrorFeedback();
      Alert.alert('Error', error.message || 'Error al consultar stock por producto');
      setStockProducto([]);
    } finally {
      setLoading(false);
    }
  };

  const handleScan = (data: string) => {
    setScannerVisible(false);
    if (modo === 'ubicacion') {
      consultarPorUbicacion(data);
    } else if (modo === 'producto') {
      consultarPorProducto(data);
    }
  };

  if (loading) {
    return <LoadingSpinner fullScreen={true} />;
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Consulta de Stock</Text>
      </View>

      {!modo ? (
        <View style={styles.menuContainer}>
          <TouchableOpacity
            style={[styles.menuButton, { borderLeftColor: '#2563eb' }]}
            onPress={() => {
              setModo('ubicacion');
              setScannerVisible(true);
            }}
          >
            <View style={[styles.menuIcon, { backgroundColor: '#2563eb15' }]}>
              <Ionicons name="location" size={32} color="#2563eb" />
            </View>
            <Text style={styles.menuTitle}>Por Ubicación</Text>
            <Text style={styles.menuDescription}>
              Escanea una ubicación para ver qué productos hay
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.menuButton, { borderLeftColor: '#10b981' }]}
            onPress={() => {
              setModo('producto');
              setScannerVisible(true);
            }}
          >
            <View style={[styles.menuIcon, { backgroundColor: '#10b98115' }]}>
              <Ionicons name="cube" size={32} color="#10b981" />
            </View>
            <Text style={styles.menuTitle}>Por Producto</Text>
            <Text style={styles.menuDescription}>
              Escanea un producto para ver dónde está almacenado
            </Text>
          </TouchableOpacity>
        </View>
      ) : (
        <ScrollView style={styles.scrollView}>
          <View style={styles.resultHeader}>
            <TouchableOpacity
              onPress={() => {
                setModo(null);
                setStockUbicacion([]);
                setStockProducto([]);
                setCodigoEscaneado('');
              }}
              style={styles.backButton}
            >
              <Ionicons name="arrow-back" size={24} color="#2563eb" />
            </TouchableOpacity>
            <Text style={styles.resultTitle}>
              {modo === 'ubicacion' ? 'Stock en Ubicación' : 'Ubicaciones del Producto'}
            </Text>
            <TouchableOpacity
              onPress={() => setScannerVisible(true)}
              style={styles.scanButton}
            >
              <Ionicons name="scan" size={24} color="#2563eb" />
            </TouchableOpacity>
          </View>

          <View style={styles.codigoCard}>
            <Text style={styles.codigoLabel}>
              {modo === 'ubicacion' ? 'Ubicación' : 'Producto'}
            </Text>
            <Text style={styles.codigoValue}>{codigoEscaneado}</Text>
          </View>

          {modo === 'ubicacion' && (
            <View style={styles.stockList}>
              {stockUbicacion.length === 0 ? (
                <View style={styles.emptyState}>
                  <Ionicons name="cube-outline" size={48} color="#9ca3af" />
                  <Text style={styles.emptyText}>No hay productos en esta ubicación</Text>
                </View>
              ) : (
                stockUbicacion.map((item, index) => (
                  <View key={index} style={styles.stockItem}>
                    <View style={styles.stockItemHeader}>
                      <Text style={styles.stockItemNombre}>{item.producto_nombre}</Text>
                      <Text style={styles.stockItemCantidad}>{item.cantidad}</Text>
                    </View>
                    <Text style={styles.stockItemCodigo}>Código: {item.producto_codigo}</Text>
                    {item.lote_codigo && (
                      <Text style={styles.stockItemLote}>Lote: {item.lote_codigo}</Text>
                    )}
                  </View>
                ))
              )}
            </View>
          )}

          {modo === 'producto' && (
            <View style={styles.stockList}>
              {stockProducto.length === 0 ? (
                <View style={styles.emptyState}>
                  <Ionicons name="location-outline" size={48} color="#9ca3af" />
                  <Text style={styles.emptyText}>Producto no encontrado en inventario</Text>
                </View>
              ) : (
                stockProducto.map((item, index) => (
                  <View key={index} style={styles.stockItem}>
                    <View style={styles.stockItemHeader}>
                      <Text style={styles.stockItemUbicacion}>{item.ubicacion_completa}</Text>
                      <Text style={styles.stockItemCantidad}>{item.cantidad}</Text>
                    </View>
                    <Text style={styles.stockItemCodigo}>Código: {item.ubicacion_codigo}</Text>
                    {item.lote_codigo && (
                      <Text style={styles.stockItemLote}>Lote: {item.lote_codigo}</Text>
                    )}
                  </View>
                ))
              )}
            </View>
          )}
        </ScrollView>
      )}

      <BarcodeScanner
        visible={scannerVisible}
        onClose={() => setScannerVisible(false)}
        onScan={handleScan}
        title={modo === 'ubicacion' ? 'Escanear Ubicación' : 'Escanear Producto'}
        description={
          modo === 'ubicacion'
            ? 'Escanea el código de la ubicación'
            : 'Escanea el código del producto'
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
  menuContainer: {
    flex: 1,
    padding: 16,
    justifyContent: 'center',
  },
  menuButton: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 24,
    marginBottom: 16,
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  menuIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    alignSelf: 'center',
  },
  menuTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1f2937',
    textAlign: 'center',
    marginBottom: 8,
  },
  menuDescription: {
    fontSize: 14,
    color: '#6b7280',
    textAlign: 'center',
  },
  scrollView: {
    flex: 1,
  },
  resultHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  backButton: {
    padding: 8,
  },
  resultTitle: {
    flex: 1,
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
    textAlign: 'center',
  },
  scanButton: {
    padding: 8,
  },
  codigoCard: {
    backgroundColor: '#ffffff',
    padding: 16,
    margin: 16,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: '#2563eb',
  },
  codigoLabel: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 4,
  },
  codigoValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1f2937',
  },
  stockList: {
    padding: 16,
  },
  stockItem: {
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
  stockItemHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  stockItemNombre: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
  },
  stockItemUbicacion: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
  },
  stockItemCantidad: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2563eb',
  },
  stockItemCodigo: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 4,
  },
  stockItemLote: {
    fontSize: 14,
    color: '#10b981',
  },
  emptyState: {
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    fontSize: 16,
    color: '#6b7280',
    marginTop: 16,
    textAlign: 'center',
  },
});

export default ConsultaStockScreen;

