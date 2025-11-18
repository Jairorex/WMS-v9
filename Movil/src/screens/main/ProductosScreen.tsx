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
import { Producto } from '../../types/api';

const ProductosScreen: React.FC = () => {
  const navigation = useNavigation();
  const [productos, setProductos] = useState<Producto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadProductos = async () => {
    try {
      setError(null);
      // La API devuelve { success: true, data: Producto[] }
      const data = await apiService.get<Producto[]>(API_ENDPOINTS.PRODUCTOS.BASE);
      const productosList = Array.isArray(data) ? data : [];
      setProductos(productosList);
      
      await offlineService.cacheData('productos', productosList, 10);
    } catch (err: any) {
      const cached = await offlineService.getCachedData('productos');
      if (cached.length > 0) {
        setProductos(cached[0].data);
      } else {
        setError(err.message || 'Error al cargar los productos');
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    loadProductos();
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    loadProductos();
  };

  const renderProducto = ({ item }: { item: Producto }) => (
    <TouchableOpacity
      style={styles.productoCard}
      onPress={() => (navigation as any).navigate('ProductoDetalle', { productoId: item.id_producto })}
    >
      <View style={styles.productoHeader}>
        <Text style={styles.productoNombre} numberOfLines={1}>
          {item.nombre}
        </Text>
        <View style={[styles.estadoBadge, { 
          backgroundColor: item.estado === 'activo' ? '#10b981' : '#ef4444' 
        }]}>
          <Text style={styles.estadoText}>{item.estado}</Text>
        </View>
      </View>
      
      {item.codigo && (
        <Text style={styles.productoCodigo}>Código: {item.codigo}</Text>
      )}
      
      {item.unidad_medida && (
        <View style={styles.productoFooter}>
          <Ionicons name="scale-outline" size={14} color="#6b7280" />
          <Text style={styles.productoInfoText}>{item.unidad_medida.nombre}</Text>
        </View>
      )}
    </TouchableOpacity>
  );

  if (loading && !refreshing) {
    return <LoadingSpinner fullScreen={true} />;
  }

  if (error && productos.length === 0) {
    return (
      <>
        <OfflineBanner />
        <ErrorView message={error} onRetry={loadProductos} />
      </>
    );
  }

  return (
    <View style={styles.container}>
      <OfflineBanner />
      {productos.length === 0 ? (
        <EmptyState
          icon="cube-outline"
          title="No hay productos"
          message="No se encontraron productos disponibles"
        />
      ) : (
        <FlatList
          data={productos}
          renderItem={renderProducto}
          keyExtractor={(item) => item.id_producto.toString()}
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
  productoCard: {
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
  productoHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  productoNombre: {
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
  productoCodigo: {
    fontSize: 14,
    color: '#6b7280',
    marginBottom: 8,
  },
  productoFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  productoInfoText: {
    fontSize: 12,
    color: '#6b7280',
  },
});

export default ProductosScreen;

