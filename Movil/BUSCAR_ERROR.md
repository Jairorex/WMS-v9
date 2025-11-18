# 🔍 Cómo Buscar el Error en los Logs

## 📱 Pasos para encontrar el stack trace

### 1. **Abre el Debugger de React Native**
   En la terminal de Expo, presiona:
   ```
   j
   ```
   Esto abrirá el debugger en tu navegador donde verás los errores en la consola.

### 2. **Revisa la Terminal de Expo**
   Desplázate hacia arriba en la terminal para ver si hay mensajes de error en **rojo**.
   Busca líneas que contengan:
   - `ERROR`
   - `Exception`
   - `String cannot be cast to Boolean`
   - `java.lang.String`

### 3. **Abre el Dev Menu en el Emulador**
   - Presiona `Ctrl + M` (o `Cmd + M` en Mac) en el emulador Android
   - O agita el dispositivo si es físico
   - Selecciona "Show Inspector" o "Debug"
   - Los errores aparecerán en la consola

### 4. **Usa Logcat (Android)**
   Si estás usando Android, abre una nueva terminal y ejecuta:
   ```powershell
   adb logcat | Select-String -Pattern "error|Error|ERROR|exception|Exception|String.*Boolean|ReactNativeJS" -CaseSensitive:$false
   ```

## 🎯 Qué buscar específicamente

El error `java.lang.String cannot be cast to java.lang.Boolean` generalmente aparece como:

```
ERROR  Warning: java.lang.String cannot be cast to java.lang.Boolean
       at com.facebook.react.uimanager.ViewManager.updateProperties
       at com.facebook.react.uimanager.UIImplementation.updateView
       ...
```

O en formato más detallado:
```
java.lang.ClassCastException: java.lang.String cannot be cast to java.lang.Boolean
    at com.facebook.react.uimanager.ViewManager.updateProperties(ViewManager.java:XXX)
    at com.facebook.react.uimanager.UIImplementation.updateView(UIImplementation.java:XXX)
    ...
```

## 📋 Información que necesito

Cuando encuentres el error, copia:

1. **El mensaje completo del error**
2. **Todas las líneas del stack trace** (las que empiezan con `at`)
3. **Cualquier referencia a archivos** (como `TareasScreen.tsx:130`)
4. **El componente mencionado** (si aparece, como `StackView`, `TabBarView`, etc.)

## 🚀 Acción inmediata

1. **Presiona `j` en la terminal de Expo** para abrir el debugger
2. **Revisa la consola del navegador** que se abrió
3. **Busca el error en rojo**
4. **Copia todo el mensaje de error**

## 💡 Tip

Si no ves el error inmediatamente:
- **Interactúa con la app** (intenta hacer login, navegar, etc.)
- El error puede aparecer cuando se renderiza un componente específico
- **Presiona `r` en la terminal** para recargar la app y ver si aparece el error

