# 🔑 Agregar APP_KEY en Railway - Paso a Paso

## ❌ Error Actual

```
No application encryption key has been specified.
```

Este error significa que `APP_KEY` no está configurado o está vacío en Railway.

## ✅ Solución: Agregar APP_KEY en Railway

### Paso 1: Generar un Nuevo APP_KEY

Ejecuta en tu terminal local:

```bash
cd backend
php artisan key:generate --show
```

Esto mostrará un valor como:
```
base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
```

**⚠️ IMPORTANTE:** Copia TODO el valor, incluyendo `base64:`

**🔑 NUEVO APP_KEY GENERADO:**
```
base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
```

Copia este valor exactamente como está y úsalo en Railway.

### Paso 2: Agregar APP_KEY en Railway

1. **Ve a Railway Dashboard:**
   - Abre [https://railway.app/dashboard](https://railway.app/dashboard)
   - Selecciona tu proyecto `WMS-v9`

2. **Ve a Variables:**
   - En el menú lateral, haz clic en **Variables**
   - O busca la pestaña **Variables** en la parte superior

3. **Busca APP_KEY:**
   - Busca si ya existe `APP_KEY` en la lista
   - Si existe pero está vacío o tiene un valor incorrecto, haz clic en el lápiz (✏️) para editarlo
   - Si NO existe, haz clic en **+ New Variable**

4. **Agregar/Editar la Variable:**
   - **Name:** `APP_KEY`
   - **Value:** Pega el valor completo que copiaste (ej: `base64:AgQxuh1ubEo6AYNmUD+vXmV/eqDODRCtV3+y7+DEi08=`)
   - **⚠️ IMPORTANTE:** 
     - NO agregues comillas alrededor del valor
     - NO agregues espacios antes o después
     - Debe incluir `base64:` al inicio
     - Copia TODO el valor exactamente como aparece

5. **Guardar:**
   - Haz clic en **Save** o **Add Variable**

### Paso 3: Verificar que se Guardó Correctamente

1. **Verifica en la lista de Variables:**
   - Debe aparecer `APP_KEY` con un valor que comienza con `base64:`
   - El valor debe tener aproximadamente 44 caracteres después de `base64:`

2. **Redesplegar el Servicio:**
   - Railway debería redesplegar automáticamente
   - Si no, ve a **Deployments** y haz clic en **Redeploy** en el deployment más reciente

### Paso 4: Verificar que Funciona

1. **Espera a que el despliegue termine** (puede tomar 1-2 minutos)

2. **Prueba el login nuevamente:**
   - Ve a tu aplicación en Vercel
   - Intenta hacer login
   - El error 500 debería desaparecer

3. **Verifica los logs:**
   - En Railway, ve a **Logs**
   - Ya NO debería aparecer el error "No application encryption key has been specified"

## 🚨 Problemas Comunes

### Problema 1: El valor tiene espacios
**Solución:** Asegúrate de que NO haya espacios antes o después del valor

### Problema 2: Falta "base64:"
**Solución:** El valor DEBE comenzar con `base64:`

### Problema 3: El servicio no se redesplegó
**Solución:** 
- Ve a **Deployments**
- Haz clic en **Redeploy** en el deployment más reciente

### Problema 4: El error persiste después de agregar APP_KEY
**Solución:**
1. Verifica que el valor esté correcto (sin espacios, con `base64:`)
2. Verifica que la variable se llama exactamente `APP_KEY` (mayúsculas)
3. Redesplega manualmente el servicio
4. Espera 2-3 minutos y prueba nuevamente

## 📋 Checklist

- [ ] Generé un nuevo APP_KEY con `php artisan key:generate --show`
- [ ] Copié TODO el valor (incluyendo `base64:`)
- [ ] Agregué la variable `APP_KEY` en Railway
- [ ] El valor NO tiene espacios antes o después
- [ ] El valor comienza con `base64:`
- [ ] Guardé la variable en Railway
- [ ] El servicio se redesplegó (o lo redesplegué manualmente)
- [ ] Probé el login y ya no aparece el error 500

## 💡 Nota

Si ya tenías un `APP_KEY` configurado pero el error persiste, puede ser que:
- El valor esté vacío
- Tenga caracteres invisibles o espacios
- Railway no esté leyendo la variable correctamente

En ese caso, **genera uno nuevo** y reemplázalo completamente.

