# 🔧 Solución: Error "You must specify a workspaceId to create a project"

## ❌ Problema

Al intentar crear un proyecto en Railway, aparece el error:
```
You must specify a workspaceId to create a project
```

## ✅ Solución

Necesitas crear o seleccionar un **Workspace** en Railway antes de crear un proyecto.

---

## 📝 Pasos para Resolver

### Opción 1: Crear un Workspace Nuevo

1. **En Railway Dashboard:**
   - Si es tu primera vez, Railway te pedirá crear un workspace
   - Si ya tienes cuenta, ve a la esquina superior izquierda donde dice tu nombre/avatar

2. **Crear Workspace:**
   - Click en el menú desplegable (arriba a la izquierda)
   - Click en **"Create Workspace"** o **"New Workspace"**
   - Ingresa un nombre (ej: "WMS Escasan" o "Mi Empresa")
   - Click en **"Create"**

3. **Seleccionar el Workspace:**
   - Una vez creado, asegúrate de que esté seleccionado
   - Deberías ver el nombre del workspace en la parte superior

4. **Crear Proyecto:**
   - Ahora sí, click en **"New Project"**
   - Selecciona **"Deploy from GitHub repo"**
   - Continúa con el proceso normal

### Opción 2: Usar Workspace Existente

1. **Verificar Workspace Actual:**
   - En la esquina superior izquierda, verifica qué workspace está seleccionado
   - Si hay un dropdown, ábrelo

2. **Seleccionar Workspace:**
   - Si ya tienes un workspace, selecciónalo del menú
   - Si no tienes ninguno, crea uno nuevo (Opción 1)

3. **Crear Proyecto:**
   - Una vez que el workspace esté seleccionado
   - Click en **"New Project"**
   - Continúa normalmente

---

## 🎯 Pasos Detallados con Capturas

### Paso 1: Verificar/Crear Workspace

1. **Abre Railway:** https://railway.app
2. **Inicia sesión** con GitHub
3. **En el dashboard:**
   - Mira la esquina superior izquierda
   - Deberías ver un dropdown con tu nombre o "Personal" o similar
   - Si no ves nada, Railway te pedirá crear un workspace

### Paso 2: Crear Workspace (si es necesario)

1. **Click en el dropdown** (esquina superior izquierda)
2. **Click en "Create Workspace"** o **"New Workspace"**
3. **Ingresa información:**
   - **Name:** WMS Escasan (o el nombre que prefieras)
   - **Description:** (opcional)
4. **Click en "Create"**

### Paso 3: Verificar Workspace Seleccionado

1. **Verifica** que el workspace esté seleccionado
2. **Deberías ver** el nombre del workspace en la parte superior
3. **El dashboard** debería mostrar "No projects yet" o proyectos existentes

### Paso 4: Crear Proyecto

1. **Click en "New Project"** (botón grande en el centro o esquina superior derecha)
2. **Selecciona "Deploy from GitHub repo"**
3. **Autoriza Railway** si es la primera vez
4. **Selecciona tu repositorio:** `WMS-v9`
5. **Click en "Deploy Now"**

---

## 🔍 Verificación

Después de crear el workspace y proyecto, deberías ver:

- ✅ Workspace seleccionado en la parte superior
- ✅ Proyecto creado en el dashboard
- ✅ Servicio iniciándose automáticamente

---

## 🆘 Si el Problema Persiste

### Verificar Permisos de GitHub

1. Ve a: https://github.com/settings/applications
2. Busca "Railway" en las aplicaciones autorizadas
3. Verifica que tenga acceso a tus repositorios
4. Si no está, autoriza Railway nuevamente

### Limpiar Cache del Navegador

1. Cierra Railway completamente
2. Limpia cache del navegador (Ctrl+Shift+Delete)
3. Vuelve a abrir Railway
4. Intenta crear el workspace nuevamente

### Contactar Soporte

Si nada funciona:
1. Ve a: https://railway.app/help
2. O escribe a: support@railway.app

---

## ✅ Checklist

- [ ] Workspace creado en Railway
- [ ] Workspace seleccionado
- [ ] Proyecto creado exitosamente
- [ ] Repositorio conectado
- [ ] Servicio iniciándose

---

**Una vez resuelto, continúa con la configuración del backend según `GUIA_DESPLIEGUE_PASO_A_PASO.md`**

