# 🔍 Cómo Ver el Stack Trace del Error

## 📱 Dónde encontrar el stack trace

El error `java.lang.String cannot be cast to java.lang.Boolean` puede aparecer en varios lugares:

### 1. **Terminal de Expo (Metro Bundler)**
   - Abre la terminal donde ejecutaste `npx expo start`
   - El stack trace aparecerá en rojo con el mensaje completo
   - Busca líneas que digan:
     ```
     ERROR  java.lang.String cannot be cast to java.lang.Boolean
     ```

### 2. **Logcat de Android (Android Studio)**
   Si estás usando un emulador o dispositivo Android:
   
   ```bash
   # Abre Android Studio
   # Ve a: View > Tool Windows > Logcat
   # Filtra por: "ReactNativeJS" o "ERROR"
   ```

   O desde la terminal:
   ```bash
   adb logcat | grep -i "error\|exception\|string.*boolean"
   ```

### 3. **Consola del Emulador/Dispositivo**
   - En el emulador Android, presiona `Ctrl + M` (o `Cmd + M` en Mac)
   - Selecciona "Show Dev Menu"
   - Selecciona "Debug" o "Show Inspector"
   - Los errores aparecerán en la consola

### 4. **React Native Debugger**
   Si tienes React Native Debugger abierto:
   - Ve a la pestaña "Console"
   - Busca el error en rojo

## 🔧 Comandos para ver logs

### Windows PowerShell:
```powershell
# Ver logs de Android
cd Movil
adb logcat | Select-String -Pattern "error|Error|ERROR|exception|Exception|String.*Boolean"
```

### Ver logs de Expo:
```powershell
cd Movil
npx expo start --clear
# Luego presiona 'j' para abrir el debugger
```

## 📋 Qué información necesitamos

Cuando encuentres el stack trace, copia:

1. **El mensaje de error completo:**
   ```
   java.lang.String cannot be cast to java.lang.Boolean
   ```

2. **El stack trace completo:**
   ```
   at com.facebook.react.uimanager.ViewManager.updateProperties
   at com.facebook.react.uimanager.UIImplementation.updateView
   ...
   ```

3. **El componente que está causando el problema:**
   - Busca líneas que mencionen nombres de componentes como:
     - `StackView`
     - `TabBarView`
     - `TextInput`
     - `TouchableOpacity`
     - etc.

4. **La línea de código (si aparece):**
   - Busca referencias a archivos `.tsx` o `.ts`

## 🎯 Componentes sospechosos comunes

Basado en el error, estos componentes son los más probables:

1. **Navegación (React Navigation):**
   - `Stack.Navigator`
   - `Tab.Navigator`
   - Props: `headerShown`, `gestureEnabled`, `animationEnabled`

2. **TextInput:**
   - Props: `editable`, `secureTextEntry`, `autoCorrect`, `autoCapitalize`

3. **TouchableOpacity:**
   - Props: `disabled`, `activeOpacity`

4. **RefreshControl:**
   - Props: `refreshing`, `enabled`

## 📸 Captura de pantalla

Si puedes, toma una captura de pantalla del error completo y compártela.

## 🚀 Próximos pasos

Una vez que tengas el stack trace:
1. Compártelo conmigo
2. Identificaremos el componente exacto
3. Corregiremos la prop booleana problemática

