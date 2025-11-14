export interface MenuItem {
  name: string;
  href: string;
  icon: string;
  roles?: (string | number)[];
  section?: string;
}

export const menuConfig: MenuItem[] = [
  // ========================================
  // OPERACIONES
  // ========================================
  { 
    name: 'Dashboard', 
    href: '/', 
    icon: '🏠',
    section: 'operaciones'
  },
  { 
    name: 'Tareas', 
    href: '/tareas-conteo', 
    icon: '📋',
    section: 'operaciones'
  },
  { 
    name: 'Picking', 
    href: '/tareas-conteo?tipo=picking', 
    icon: '📦',
    section: 'operaciones'
  },
  { 
    name: 'Packing', 
    href: '/tareas-conteo?tipo=packing', 
    icon: '📦',
    section: 'operaciones'
  },
  { 
    name: 'Movimiento / Reubicaciones', 
    href: '/movimiento', 
    icon: '🔄',
    section: 'operaciones'
  },
  { 
    name: 'Incidencias', 
    href: '/incidencias', 
    icon: '⚠️',
    section: 'operaciones'
  },

  // ========================================
  // PLANIFICACIÓN
  // ========================================
  { 
    name: 'Órdenes de Salida', 
    href: '/ordenes-salida', 
    icon: '📤',
    section: 'planificacion'
  },

  // ========================================
  // CONTROL Y ANÁLISIS
  // ========================================
  { 
    name: 'Historial de Tareas', 
    href: '/historial', 
    icon: '📜',
    section: 'control'
  },
  { 
    name: 'Reportes', 
    href: '/reportes', 
    icon: '📈',
    section: 'control',
    roles: [1, '1', 2, '2']
  },

  // ========================================
  // CATÁLOGOS
  // ========================================
  { 
    name: 'Productos', 
    href: '/productos', 
    icon: '📦',
    section: 'catalogos'
  },
  { 
    name: 'Lotes', 
    href: '/lotes', 
    icon: '📋',
    section: 'catalogos'
  },
  { 
    name: 'Ubicaciones', 
    href: '/ubicaciones', 
    icon: '📍',
    section: 'catalogos'
  },
  { 
    name: 'Usuarios', 
    href: '/usuarios', 
    icon: '👥',
    section: 'catalogos',
    roles: [1, '1']
  },
  { 
    name: 'Etiquetas', 
    href: '/etiquetas', 
    icon: '🏷️',
    section: 'catalogos',
    roles: [1, '1']
  },
];

export const menuSections = [
  {
    id: 'operaciones',
    name: 'OPERACIONES',
    order: 1
  },
  {
    id: 'planificacion',
    name: 'PLANIFICACIÓN',
    order: 2
  },
  {
    id: 'control',
    name: 'CONTROL Y ANÁLISIS',
    order: 3
  },
  {
    id: 'catalogos',
    name: 'CATÁLOGOS',
    order: 4
  }
];

export const getMenuItemsByRole = (userRole: string | number | undefined) => {
  // Filtrar items por rol
  const filteredItems = menuConfig.filter(item => 
    !item.roles || (userRole !== undefined && item.roles.includes(userRole))
  );

  // Agrupar por sección
  const groupedBySection: { [key: string]: MenuItem[] } = {};
  
  filteredItems.forEach(item => {
    const section = item.section || 'otros';
    if (!groupedBySection[section]) {
      groupedBySection[section] = [];
    }
    groupedBySection[section].push(item);
  });

  // Ordenar secciones según el orden definido
  const sections = menuSections.map(section => ({
    ...section,
    items: groupedBySection[section.id] || []
  }));

  return { sections };
};
