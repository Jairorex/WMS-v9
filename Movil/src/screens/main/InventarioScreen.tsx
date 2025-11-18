import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import OfflineBanner from '../../components/common/OfflineBanner';
import EmptyState from '../../components/common/EmptyState';

const InventarioScreen: React.FC = () => {
  return (
    <View style={styles.container}>
      <OfflineBanner />
      <EmptyState
        icon="cube-outline"
        title="Inventario"
        message="Pantalla en desarrollo"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
});

export default InventarioScreen;

