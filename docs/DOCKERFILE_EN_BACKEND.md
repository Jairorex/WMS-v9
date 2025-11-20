# 📁 Dockerfile en backend/

## ✅ Solución

El Dockerfile está ahora en `backend/Dockerfile` porque Railway está configurado para buscarlo ahí.

## 📋 Estructura

```
WMS-v9/
├── backend/
│   ├── Dockerfile      ← Aquí está ahora
│   ├── .dockerignore
│   ├── app/
│   ├── config/
│   └── ...
├── frontend/
└── ...
```

## 🚀 Railway Debería Detectar el Dockerfile

Railway ahora debería:
- Detectar el Dockerfile en `backend/Dockerfile`
- Iniciar un nuevo build automáticamente
- Instalar las extensiones PHP necesarias

## ⚠️ IMPORTANTE: Agregar APP_KEY

Después del build, **agrega APP_KEY** en Railway Variables:

1. Ve a **Railway Dashboard → Variables**
2. Busca o crea `APP_KEY`
3. Valor:
   ```
   base64:LSwBIyVM57dKA+LizwnmcdU1nM/yDJyph4id45/H+84=
   ```
4. **Guarda**

## 📝 Notas

- El Dockerfile está en `backend/Dockerfile` (no en la raíz)
- Railway está configurado para buscar el Dockerfile en `backend/`
- Las rutas dentro del Dockerfile son relativas a `backend/`

