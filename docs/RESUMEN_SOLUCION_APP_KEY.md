# 🚨 SOLUCIÓN RÁPIDA: Error APP_KEY en Railway

## ❌ Error

```
No application encryption key has been specified.
```

## ✅ Solución Inmediata

### 1. Copia este valor:

```
base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
```

### 2. En Railway:

1. Ve a **Variables**
2. Busca o crea `APP_KEY`
3. Pega el valor exacto (sin espacios, sin comillas)
4. Guarda

### 3. Espera 1-2 minutos

Railway redesplegará automáticamente.

### 4. Prueba el login

El error 500 debería desaparecer.

## 📋 Verificaciones

- ✅ Valor comienza con `base64:`
- ✅ NO hay espacios
- ✅ NO hay comillas
- ✅ Nombre exacto: `APP_KEY` (mayúsculas)

## 📖 Documentación Completa

- `docs/AGREGAR_APP_KEY_RAILWAY_PASO_A_PASO.md` - Guía paso a paso
- `docs/APP_KEY_RAILWAY_VALOR.md` - Valor del APP_KEY
- `docs/SOLUCION_ERROR_500_RAILWAY.md` - Solución completa del error 500

