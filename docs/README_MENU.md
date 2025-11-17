# 📋 Guía para Agregar Nuevas Funciones al Menú

## 🎯 Cómo Agregar Nuevas Funciones

### 1. **Agregar al Archivo de Configuración del Menú**

Edita el archivo `src/config/menu.ts` y agrega tu nueva función:

```typescript
export const menuConfig: MenuItem[] = [
  // ... funciones existentes ...
  
  // Nueva función
  { 
    name: 'Mi Nueva Función', 
    href: '/mi-nueva-funcion', 
    icon: '🆕', 
    roles: [1, '1'], // Solo Admin (opcional)
    section: 'admin' // Sección donde aparecerá (opcional)
  },
];
```

### 2. **Agregar la Ruta en App.tsx**

Edita el archivo `src/App.tsx` y agrega la ruta:

```typescript
// Importar el componente
import MiNuevaFuncion from './pages/MiNuevaFuncion';

// En las rutas
<Route path="/mi-nueva-funcion" element={<MiNuevaFuncion />} />
```

### 3. **Crear el Componente de la Página**

Crea el archivo `src/pages/MiNuevaFuncion.tsx`:

```typescript
import React from 'react';

const MiNuevaFuncion: React.FC = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Mi Nueva Función</h1>
      <p>Contenido de la nueva función...</p>
    </div>
  );
};

export default MiNuevaFuncion;
```

## 🔧 Configuración de Roles

### Roles Disponibles:
- **Admin**: `1` o `'1'`
- **Supervisor**: `2` o `'2'`
- **Operario**: `3` o `'3'`

### Ejemplos de Configuración:

```typescript
// Solo Admin
{ name: 'Usuarios', href: '/usuarios', icon: '👥', roles: [1, '1'], section: 'admin' }

// Admin y Supervisor
{ name: 'Reportes', href: '/reportes', icon: '📊', roles: [1, '1', 2, '2'] }

// Todos los roles (sin roles)
{ name: 'Dashboard', href: '/', icon: '🏠' }
```

## 📁 Estructura de Archivos

```
frontend/src/
├── config/
│   └── menu.ts          # Configuración del menú
├── components/
│   └── Layout.tsx       # Componente de layout
├── pages/
│   ├── Dashboard.tsx    # Páginas existentes
│   ├── Usuarios.tsx
│   └── MiNuevaFuncion.tsx # Nueva página
└── App.tsx             # Configuración de rutas
```

## 🎨 Iconos Disponibles

Puedes usar cualquier emoji como icono:
- 🏠 Dashboard
- 📦 Productos/Órdenes
- 👥 Usuarios
- 📊 Reportes
- 🔧 Configuración
- 📋 Listas
- 🔍 Búsqueda
- ⚙️ Ajustes

## ✅ Checklist para Nueva Función

- [ ] Agregar entrada en `menu.ts`
- [ ] Crear componente en `pages/`
- [ ] Agregar ruta en `App.tsx`
- [ ] Configurar roles si es necesario
- [ ] Probar navegación
- [ ] Verificar permisos

## 🚀 Ejemplo Completo

### 1. Agregar a menu.ts:
```typescript
{ 
  name: 'Reportes', 
  href: '/reportes', 
  icon: '📊', 
  roles: [1, '1', 2, '2'], 
  section: 'admin' 
}
```

### 2. Crear Reportes.tsx:
```typescript
import React from 'react';

const Reportes: React.FC = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Reportes</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Reporte de Inventario</h3>
          <p className="text-gray-600">Generar reporte de inventario</p>
        </div>
        {/* Más contenido... */}
      </div>
    </div>
  );
};

export default Reportes;
```

### 3. Agregar ruta en App.tsx:
```typescript
import Reportes from './pages/Reportes';

// En las rutas
<Route path="/reportes" element={<Reportes />} />
```

¡Y listo! Tu nueva función aparecerá automáticamente en el menú lateral. 🎉
