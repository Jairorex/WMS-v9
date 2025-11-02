export interface MenuItem {
  name: string;
  href: string;
  icon: string;
  roles?: (string | number)[];
  section?: string;
}

export const menuConfig: MenuItem[] = [
  // Sección principal
  { name: 'Dashboard', href: '/', icon: '🏠' },
  { name: 'Órdenes de Salida', href: '/ordenes-salida', icon: '📦' },
  { name: 'Picking', href: '/picking', icon: '📋' },
  { name: 'Packing', href: '/packing', icon: '📦' },
  { name: 'Movimiento', href: '/movimiento', icon: '🔄' },
  { name: 'TAREAS', href: '/tareas-conteo', icon: '🔢' },
  { name: 'Productos', href: '/productos', icon: '📦' },
  { name: 'Ubicaciones', href: '/ubicaciones', icon: '📍' },
  { name: 'Lotes', href: '/lotes', icon: '📋' },
  { name: 'Incidencias', href: '/incidencias', icon: '⚠️' },
  { name: 'Existencias', href: '/existencias', icon: '📊' },
  { name: 'Historial', href: '/historial', icon: '📜' },
  
  // Sección de administración (solo Admin)
  { 
    name: 'Usuarios', 
    href: '/usuarios', 
    icon: '👥', 
    roles: [1, '1'], 
    section: 'admin' 
  },
  { 
    name: 'Etiquetas', 
    href: '/etiquetas', 
    icon: '🏷️', 
    roles: [1, '1'], 
    section: 'admin' 
  },
  
  // Sección de reportes (Admin y Supervisor)
  { 
    name: 'Reportes', 
    href: '/reportes', 
    icon: '📊', 
    roles: [1, '1', 2, '2'], 
    section: 'admin' 
  },
];

export const getMenuItemsByRole = (userRole: string | number | undefined) => {
  const mainItems = menuConfig.filter(item => !item.section);
  const adminItems = menuConfig.filter(item => 
    item.section === 'admin' && 
    (!item.roles || item.roles.includes(userRole))
  );
  
  return { mainItems, adminItems };
};
