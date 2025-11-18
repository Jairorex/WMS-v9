import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useAuth } from '../../contexts/AuthContext';
import { Ionicons } from '@expo/vector-icons';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import LoadingSpinner from '../../components/common/LoadingSpinner';

interface TareaPendiente {
  id_tarea: number;
  descripcion: string;
  tipo: string;
  prioridad: string;
}

const MenuPrincipalScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const { user } = useAuth();
  const [tareasPendientes, setTareasPendientes] = useState<TareaPendiente[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const loadTareasPendientes = async () => {
    try {
      const tareas = await apiService.get<any[]>(API_ENDPOINTS.TAREAS.BASE, {
        params: {
          estado: 'PENDIENTE',
          asignado_a: user?.id_usuario,
        },
      });
      setTareasPendientes(tareas.slice(0, 5)); // Solo las primeras 5
    } catch (error) {
      console.error('Error cargando tareas:', error);
    }
  };

  useEffect(() => {
    loadTareasPendientes();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadTareasPendientes();
    setRefreshing(false);
  };

  const menuItems = [
    {
      id: 'recepcion',
      title: 'Recepción',
      icon: 'download-outline',
      color: '#2563eb',
      screen: 'Recepcion',
      description: 'Recibir mercancía',
    },
    {
      id: 'putaway',
      title: 'Guardado',
      icon: 'archive-outline',
      color: '#10b981',
      screen: 'PutAway',
      description: 'Guardar en ubicación',
    },
    {
      id: 'picking',
      title: 'Picking',
      icon: 'cart-outline',
      color: '#f59e0b',
      screen: 'Picking',
      description: 'Preparar pedidos',
    },
    {
      id: 'inventario',
      title: 'Consulta Stock',
      icon: 'search-outline',
      color: '#8b5cf6',
      screen: 'ConsultaStock',
      description: 'Consultar inventario',
    },
    {
      id: 'conteo',
      title: 'Conteo Cíclico',
      icon: 'calculator-outline',
      color: '#ef4444',
      screen: 'ConteoCiclico',
      description: 'Contar inventario',
    },
    {
      id: 'transferencia',
      title: 'Transferencias',
      icon: 'swap-horizontal-outline',
      color: '#06b6d4',
      screen: 'Transferencias',
      description: 'Mover inventario',
    },
  ];

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.welcomeText}>Bienvenido,</Text>
          <Text style={styles.userName}>{user?.nombre}</Text>
          {user?.rol && (
            <Text style={styles.rolText}>{user.rol.nombre}</Text>
          )}
        </View>

        {/* Tareas Pendientes */}
        {tareasPendientes.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Tareas Pendientes</Text>
            {tareasPendientes.map((tarea) => (
              <TouchableOpacity
                key={tarea.id_tarea}
                style={styles.tareaCard}
                onPress={() => navigation.navigate('TareaDetalle', { id: tarea.id_tarea })}
              >
                <View style={styles.tareaContent}>
                  <Text style={styles.tareaDescripcion} numberOfLines={1}>
                    {tarea.descripcion}
                  </Text>
                  <Text style={styles.tareaTipo}>{tarea.tipo}</Text>
                </View>
                <Ionicons name="chevron-forward" size={20} color="#6b7280" />
              </TouchableOpacity>
            ))}
          </View>
        )}

        {/* Menú Principal */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Módulos</Text>
          <View style={styles.menuGrid}>
            {menuItems.map((item) => (
              <TouchableOpacity
                key={item.id}
                style={[styles.menuButton, { borderLeftColor: item.color }]}
                onPress={() => navigation.navigate(item.screen)}
                activeOpacity={0.7}
              >
                <View style={[styles.menuIconContainer, { backgroundColor: `${item.color}15` }]}>
                  <Ionicons name={item.icon as any} size={32} color={item.color} />
                </View>
                <Text style={styles.menuTitle}>{item.title}</Text>
                <Text style={styles.menuDescription}>{item.description}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  scrollView: {
    flex: 1,
  },
  header: {
    padding: 24,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  welcomeText: {
    fontSize: 16,
    color: '#6b7280',
  },
  userName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1f2937',
    marginTop: 4,
  },
  rolText: {
    fontSize: 14,
    color: '#2563eb',
    marginTop: 4,
    fontWeight: '500',
  },
  section: {
    padding: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 16,
  },
  tareaCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#f59e0b',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  tareaContent: {
    flex: 1,
  },
  tareaDescripcion: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1f2937',
    marginBottom: 4,
  },
  tareaTipo: {
    fontSize: 14,
    color: '#6b7280',
  },
  menuGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  menuButton: {
    width: '48%',
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    alignItems: 'center',
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    minHeight: 140,
    justifyContent: 'center',
  },
  menuIconContainer: {
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  menuTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 4,
    textAlign: 'center',
  },
  menuDescription: {
    fontSize: 12,
    color: '#6b7280',
    textAlign: 'center',
  },
});

export default MenuPrincipalScreen;

