import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNetwork } from '../../contexts/NetworkContext';
import { Ionicons } from '@expo/vector-icons';

const OfflineBanner: React.FC = () => {
  const { isOnline, pendingRequests, syncPendingRequests } = useNetwork();

  if (isOnline) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Ionicons name="cloud-offline" size={20} color="#ffffff" />
      <Text style={styles.text}>
        Sin conexión
        {pendingRequests > 0 && ` • ${pendingRequests} pendiente${pendingRequests > 1 ? 's' : ''}`}
      </Text>
      {pendingRequests > 0 && (
        <TouchableOpacity onPress={syncPendingRequests} style={styles.syncButton}>
          <Ionicons name="sync" size={16} color="#ffffff" />
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f59e0b',
    paddingVertical: 8,
    paddingHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '500',
    marginLeft: 8,
  },
  syncButton: {
    marginLeft: 12,
    padding: 4,
  },
});

export default OfflineBanner;

