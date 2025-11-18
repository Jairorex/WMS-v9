import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useAuth } from '../contexts/AuthContext';
import { ActivityIndicator, View, StyleSheet } from 'react-native';

// Pantallas de autenticación
import LoginScreen from '../screens/auth/LoginScreen';

// Pantallas principales
import MenuPrincipalScreen from '../screens/main/MenuPrincipalScreen';
import DashboardScreen from '../screens/main/DashboardScreen';
import TareasScreen from '../screens/main/TareasScreen';
import InventarioScreen from '../screens/main/InventarioScreen';
import ProductosScreen from '../screens/main/ProductosScreen';
import PerfilScreen from '../screens/main/PerfilScreen';

// Pantallas de warehouse
import PickingScreen from '../screens/warehouse/PickingScreen';
import ConsultaStockScreen from '../screens/warehouse/ConsultaStockScreen';
import RecepcionScreen from '../screens/warehouse/RecepcionScreen';
import PutAwayScreen from '../screens/warehouse/PutAwayScreen';
import ConteoCiclicoScreen from '../screens/warehouse/ConteoCiclicoScreen';
import TransferenciasScreen from '../screens/warehouse/TransferenciasScreen';

// Pantallas de detalle
import TareaDetalleScreen from '../screens/detail/TareaDetalleScreen';
import ProductoDetalleScreen from '../screens/detail/ProductoDetalleScreen';

// Iconos
import { Ionicons } from '@expo/vector-icons';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

// Navegador de tabs para usuarios autenticados
const MainTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#2563eb',
        tabBarInactiveTintColor: '#6b7280',
        headerShown: true,
      }}
    >
      <Tab.Screen 
        name="MenuPrincipal" 
        component={MenuPrincipalScreen}
        options={{ 
          title: 'Menú',
          tabBarIcon: ({ focused, color, size }) => (
            <Ionicons name={focused ? 'apps' : 'apps-outline'} size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Dashboard" 
        component={DashboardScreen}
        options={{ 
          title: 'Dashboard',
          tabBarIcon: ({ focused, color, size }) => (
            <Ionicons name={focused ? 'stats-chart' : 'stats-chart-outline'} size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Tareas" 
        component={TareasScreen}
        options={{ 
          title: 'Tareas',
          tabBarIcon: ({ focused, color, size }) => (
            <Ionicons name={focused ? 'list' : 'list-outline'} size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Inventario" 
        component={InventarioScreen}
        options={{ 
          title: 'Inventario',
          tabBarIcon: ({ focused, color, size }) => (
            <Ionicons name={focused ? 'cube' : 'cube-outline'} size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Productos" 
        component={ProductosScreen}
        options={{ 
          title: 'Productos',
          tabBarIcon: ({ focused, color, size }) => (
            <Ionicons name={focused ? 'grid' : 'grid-outline'} size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Perfil" 
        component={PerfilScreen}
        options={{ 
          title: 'Perfil',
          tabBarIcon: ({ focused, color, size }) => (
            <Ionicons name={focused ? 'person' : 'person-outline'} size={size} color={color} />
          ),
        }}
      />
    </Tab.Navigator>
  );
};

// Navegador principal
const AppNavigator = () => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2563eb" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
        }}
      >
        {!isAuthenticated ? (
          <Stack.Screen 
            name="Login" 
            component={LoginScreen}
          />
        ) : (
          <>
            <Stack.Screen 
              name="Main" 
              component={MainTabs}
            />
            <Stack.Screen 
              name="TareaDetalle" 
              component={TareaDetalleScreen}
              options={{ 
                headerShown: true,
                title: 'Detalle de Tarea',
              }}
            />
            <Stack.Screen 
              name="ProductoDetalle" 
              component={ProductoDetalleScreen}
              options={{ 
                headerShown: true,
                title: 'Detalle de Producto',
              }}
            />
            {/* Pantallas de Warehouse */}
            <Stack.Screen 
              name="Picking" 
              component={PickingScreen}
              options={{ 
                headerShown: true,
                title: 'Picking',
              }}
            />
            <Stack.Screen 
              name="ConsultaStock" 
              component={ConsultaStockScreen}
              options={{ 
                headerShown: true,
                title: 'Consulta de Stock',
              }}
            />
            <Stack.Screen 
              name="Recepcion" 
              component={RecepcionScreen}
              options={{ 
                headerShown: true,
                title: 'Recepción',
              }}
            />
            <Stack.Screen 
              name="PutAway" 
              component={PutAwayScreen}
              options={{ 
                headerShown: true,
                title: 'Guardado',
              }}
            />
            <Stack.Screen 
              name="ConteoCiclico" 
              component={ConteoCiclicoScreen}
              options={{ 
                headerShown: true,
                title: 'Conteo Cíclico',
              }}
            />
            <Stack.Screen 
              name="Transferencias" 
              component={TransferenciasScreen}
              options={{ 
                headerShown: true,
                title: 'Transferencias',
              }}
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
});

export default AppNavigator;
