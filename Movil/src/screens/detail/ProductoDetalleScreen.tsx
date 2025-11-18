import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
} from 'react-native';
import { useRoute } from '@react-navigation/native';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import ErrorView from '../../components/common/ErrorView';
import { Ionicons } from '@expo/vector-icons';
import { Producto } from '../../types/api';

const ProductoDetalleScreen: React.FC = () => {
  const route = useRoute();
  const { productoId } = route.params as { productoId: number };
  
  const [producto, setProducto] = useState<Producto | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadProducto();
  }, [productoId]);

  const loadProducto = async () => {
    try {
      setError(null);
      // La API devuelve { success: true, data: Producto }
      const data = await apiService.get<Producto>(`${API_ENDPOINTS.PRODUCTOS.BASE}/${productoId}`);
      setProducto(data);
    } catch (err: any) {
      setError(err.message || 'Error al cargar el producto');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner fullScreen={true} />;
  }

  if (error || !producto) {
    return <ErrorView message={error || 'Producto no encontrado'} onRetry={loadProducto} />;
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.nombre}>{producto.nombre}</Text>
        
        {producto.descripcion && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Descripción</Text>
            <Text style={styles.descripcion}>{producto.descripcion}</Text>
          </View>
        )}

        <View style={styles.infoGrid}>
          {producto.codigo && (
            <InfoItem label="Código" value={producto.codigo} icon="barcode" />
          )}
          <InfoItem 
            label="Estado" 
            value={producto.estado} 
            icon="checkmark-circle"
            valueColor={producto.estado === 'activo' ? '#10b981' : '#ef4444'}
          />
          {producto.unidad_medida && (
            <InfoItem label="Unidad de Medida" value={producto.unidad_medida.nombre} icon="scale" />
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
  valueColor?: string;
}

const InfoItem: React.FC<InfoItemProps> = ({ label, value, icon, valueColor = '#1f2937' }) => {
  return (
    <View style={styles.infoItem}>
      <Ionicons name={icon} size={20} color="#6b7280" />
      <View style={styles.infoContent}>
        <Text style={styles.infoLabel}>{label}</Text>
        <Text style={[styles.infoValue, { color: valueColor }]}>{value}</Text>
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
  nombre: {
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
  },
});

export default ProductoDetalleScreen;

