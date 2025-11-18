import { Platform, Vibration } from 'react-native';
import * as Haptics from 'expo-haptics';
import { Audio } from 'expo-av';

// Sonidos de feedback
let successSound: Audio.Sound | null = null;
let errorSound: Audio.Sound | null = null;

// Inicializar sonidos
export const initSounds = async () => {
  try {
    // Sonido de éxito (BIP corto)
    const { sound: success } = await Audio.Sound.createAsync(
      require('../../assets/sounds/success.mp3') // Necesitarás crear estos archivos
    );
    successSound = success;

    // Sonido de error (BEEP-BEEP-BEEP)
    const { sound: error } = await Audio.Sound.createAsync(
      require('../../assets/sounds/error.mp3')
    );
    errorSound = error;
  } catch (error) {
    console.warn('No se pudieron cargar los sonidos:', error);
  }
};

// Feedback de éxito
export const playSuccessFeedback = async () => {
  try {
    // Vibración corta
    if (Platform.OS === 'ios') {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else {
      Vibration.vibrate(50);
    }

    // Sonido
    if (successSound) {
      await successSound.replayAsync();
    }
  } catch (error) {
    console.warn('Error en feedback de éxito:', error);
  }
};

// Feedback de error
export const playErrorFeedback = async () => {
  try {
    // Vibración larga
    if (Platform.OS === 'ios') {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    } else {
      Vibration.vibrate([0, 100, 50, 100, 50, 100]);
    }

    // Sonido
    if (errorSound) {
      await errorSound.replayAsync();
    }
  } catch (error) {
    console.warn('Error en feedback de error:', error);
  }
};

// Feedback de escaneo
export const playScanFeedback = async () => {
  try {
    // Vibración muy corta
    if (Platform.OS === 'ios') {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } else {
      Vibration.vibrate(30);
    }
  } catch (error) {
    console.warn('Error en feedback de escaneo:', error);
  }
};

