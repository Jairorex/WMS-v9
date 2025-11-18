import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  TouchableOpacity,
} from 'react-native';
import { useAuth } from '../../contexts/AuthContext';
import { useNetwork } from '../../contexts/NetworkContext';
import { apiService } from '../../services/api';
import { API_ENDPOINTS } from '../../config/api';
import { offlineService } from '../../services/offline';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import ErrorView from '../../components/common/ErrorView';
import OfflineBanner from '../../components/common/OfflineBanner';
import { Ionicons } from '@expo/vector-icons';

interface DashboardStats {
  total_productos?: number;
  total_ubicaciones?: number;
  tareas_pendientes?: number;
  inventario_total?: number;
}

const DashboardScreen: React.FC = () => {
  const { user } = useAuth();
  const { isOnline } = useNetwork();
  const [stats, setStats] = useState<DashboardStats>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadDashboard = async () => {
    try {
      setError(null);
      const data = await apiService.get<DashboardStats>(API_ENDPOINTS.DASHBOARD.ESTADISTICAS);
      setStats(data);
      
      // Cachear datos
      await offlineService.cacheData('dashboard_stats', data, 5); // 5 minutos
    } catch (err: any) {
      // Intentar cargar desde cache si hay error
      const cached = await offlineService.getCachedData('dashboard_stats');
      if (cached.length > 0) {
        setStats(cached[0].data);
      } else {
        setError(err.message || 'Error al cargar el dashboard');
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    loadDashboard();
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    loadDashboard();
  };

  if (loading && !refreshing) {
    return <LoadingSpinner fullScreen={true} />;
  }

  if (error && Object.keys(stats).length === 0) {
    return (
      <>
        <OfflineBanner />
        <ErrorView message={error} onRetry={loadDashboard} />
      </>
    );
  }

  return (
    <View style={styles.container}>
      <OfflineBanner />
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <View style={styles.header}>
          <Text style={styles.welcomeText}>Bienvenido,</Text>
          <Text style={styles.userName}>{user?.nombre}</Text>
        </View>

        <View style={styles.statsGrid}>
          <StatCard
            icon="cube"
            label="Productos"
            value={stats.total_productos || 0}
            color="#2563eb"
          />
          <StatCard
            icon="location"
            label="Ubicaciones"
            value={stats.total_ubicaciones || 0}
            color="#10b981"
          />
          <StatCard
            icon="list"
            label="Tareas Pendientes"
            value={stats.tareas_pendientes || 0}
            color="#f59e0b"
          />
          <StatCard
            icon="stats-chart"
            label="Inventario Total"
            value={stats.inventario_total || 0}
            color="#8b5cf6"
          />
        </View>

        {!isOnline && (
          <View style={styles.offlineNotice}>
            <Ionicons name="information-circle" size={20} color="#6b7280" />
            <Text style={styles.offlineText}>
              Modo offline activo. Los datos se sincronizarán cuando se restablezca la conexión.
            </Text>
          </View>
        )}
      </ScrollView>
    </View>
  );
};

interface StatCardProps {
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  value: number;
  color: string;
}

const StatCard: React.FC<StatCardProps> = ({ icon, label, value, color }) => {
  return (
    <View style={styles.statCard}>
      <View style={[styles.statIconContainer, { backgroundColor: `${color}15` }]}>
        <Ionicons name={icon} size={24} color={color} />
      </View>
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
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
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1f2937',
    marginTop: 4,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 16,
  },
  statCard: {
    width: '48%',
    backgroundColor: '#ffffff',
    borderRadius: 12,
    padding: 16,
    margin: '1%',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: '#6b7280',
    textAlign: 'center',
  },
  offlineNotice: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fef3c7',
    padding: 16,
    margin: 16,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#f59e0b',
  },
  offlineText: {
    flex: 1,
    marginLeft: 8,
    fontSize: 14,
    color: '#92400e',
  },
});

export default DashboardScreen;

