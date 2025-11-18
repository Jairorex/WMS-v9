# 🔍 Cómo Ver el Stack Trace del Error

## 📱 Dónde encontrar el stack trace

El error `java.lang.String cannot be cast to java.lang.Boolean` aparece en varios lugares:

### 1. **Terminal de Expo (Metro Bundler)** ⭐ MÁS COMÚN
   - Abre la terminal donde ejecutaste `npx expo start`
   - El stack trace aparecerá en **rojo** con el mensaje completo
   - Busca líneas que digan:
     ```
     ERROR  java.lang.String cannot be cast to java.lang.Boolean
     ```
   - **Ejemplo de cómo se ve:**
     ```
     ERROR  Warning: java.lang.String cannot be cast to java.lang.Boolean
            at com.facebook.react.uimanager.ViewManager.updateProperties
            at com.facebook.react.uimanager.UIImplementation.updateView
            ...
     ```

### 2. **Logcat de Android (Android Studio)**
   Si estás usando un emulador o dispositivo Android:
   
   **Opción A: Android Studio**
   - Abre Android Studio
   - Ve a: `View > Tool Windows > Logcat`
   - Filtra por: `ReactNativeJS` o `ERROR`
   
   **Opción B: Terminal (ADB)**
   ```powershell
   # En PowerShell
   adb logcat | Select-String -Pattern "error|Error|ERROR|exception|Exception|String.*Boolean"
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
# Ver logs de Android (si tienes ADB instalado)
cd Movil
adb logcat | Select-String -Pattern "error|Error|ERROR|exception|Exception|String.*Boolean" -CaseSensitive:$false
```

### Ver logs de Expo:
```powershell
cd Movil
npx expo start --clear
# Luego presiona 'j' para abrir el debugger en el navegador
# O busca el error directamente en la terminal
```

## 📋 Qué información necesitamos

Cuando encuentres el stack trace, **copia TODO**:

1. **El mensaje de error completo:**
   ```
   java.lang.String cannot be cast to java.lang.Boolean
   ```

2. **El stack trace completo (todas las líneas):**
   ```
   at com.facebook.react.uimanager.ViewManager.updateProperties
   at com.facebook.react.uimanager.UIImplementation.updateView
   at com.facebook.react.uimanager.UIManagerModule.updateView
   ...
   ```

3. **El componente que está causando el problema:**
   - Busca líneas que mencionen nombres de componentes como:
     - `StackView`
     - `TabBarView`
     - `TextInput`
     - `TouchableOpacity`
     - `RefreshControl`
     - etc.

4. **La línea de código (si aparece):**
   - Busca referencias a archivos `.tsx` o `.ts`
   - Ejemplo: `TareasScreen.tsx:130`

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

5. **LoadingSpinner:**
   - Props: `fullScreen`

## 📸 Captura de pantalla

Si puedes, toma una **captura de pantalla** del error completo y compártela. Esto es muy útil.

## 🚀 Próximos pasos

Una vez que tengas el stack trace:
1. **Copia TODO el mensaje de error**
2. **Compártelo conmigo**
3. Identificaremos el componente exacto
4. Corregiremos la prop booleana problemática

## 💡 Tip

Si no ves el error en la terminal, intenta:
1. **Limpiar el caché:**
   ```powershell
   cd Movil
   npx expo start --clear
   ```

2. **Reiniciar el emulador/dispositivo**

3. **Verificar que el error aparece al hacer una acción específica** (por ejemplo, al abrir una pantalla, al hacer login, etc.)

