import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { getMenuItemsByRole } from '../config/menu';

const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { user, logout } = useAuth();
  const location = useLocation();

  const { sections } = getMenuItemsByRole(user?.rol_id);

  const handleLogout = async () => {
    await logout();
  };

  return (
    <div className="h-screen flex overflow-hidden bg-green-50">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'block' : 'hidden'} fixed inset-0 z-40 lg:hidden`}>
        <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)}></div>
      </div>

      <div className={`${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} fixed inset-y-0 left-0 z-50 w-64 bg-green-800 transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0`}>
        <div className="flex items-center justify-center h-20 bg-white border-b border-green-200">
          <img 
            src="/logo-escasan.svg" 
            alt="ESCASAN Logo" 
            className="h-16 w-auto object-contain"
            onError={(e) => {
              // Fallback si la imagen no se carga
              const target = e.currentTarget as HTMLImageElement;
              target.style.display = 'none';
              const nextSibling = target.nextElementSibling as HTMLElement | null;
              if (nextSibling) {
                nextSibling.style.display = 'flex';
              }
            }}
          />
          <div className="flex items-center space-x-3" style={{display: 'none'}}>
            {/* Logo placeholder - fallback si la imagen no se carga */}
            <div className="w-8 h-8 bg-gradient-to-br from-orange-400 to-green-500 rounded-full flex items-center justify-center">
              <span className="text-white font-bold text-sm">E</span>
            </div>
            <h1 className="text-green-600 text-xl font-bold">ESCASAN</h1>
          </div>
        </div>
        
        <nav className="mt-5 px-2 space-y-6 overflow-y-auto max-h-[calc(100vh-5rem)]">
          {sections.map((section) => {
            if (section.items.length === 0) return null;
            
            return (
              <div key={section.id} className="space-y-1">
                <h3 className="px-2 text-xs font-semibold text-green-300 uppercase tracking-wider mb-2">
                  {section.name}
                </h3>
                <div className="space-y-1">
                  {section.items.map((item) => {
                    // Verificar si la ruta actual coincide
                    const itemPath = item.href.split('?')[0];
                    const itemSearch = item.href.includes('?') ? item.href.split('?')[1] : '';
                    const currentSearch = location.search.replace('?', '');
                    
                    let isActive = false;
                    if (item.href.includes('?')) {
                      // Si el item tiene query params, verificar ambos
                      isActive = location.pathname === itemPath && currentSearch === itemSearch;
                    } else {
                      // Si no tiene query params, solo verificar el path
                      isActive = location.pathname === itemPath;
                    }
                    
                    return (
                      <Link
                        key={item.name}
                        to={item.href}
                        className={`${
                          isActive
                            ? 'bg-green-600 text-white'
                            : 'text-green-100 hover:bg-green-700 hover:text-white'
                        } group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors duration-200`}
                      >
                        <span className="mr-3 text-base">{item.icon}</span>
                        {item.name}
                      </Link>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </nav>
      </div>

      {/* Main content */}
      <div className="flex-1 overflow-hidden">
        {/* Top bar */}
        <div className="bg-gradient-to-r from-orange-500 to-orange-600 shadow-sm">
          <div className="flex items-center justify-between px-4 py-3">
            {/* Botón de menú móvil (solo visible en pantallas pequeñas) */}
            <button
              className="lg:hidden text-white hover:text-orange-200"
              onClick={() => setSidebarOpen(true)}
            >
              <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>

            {/* Espaciador para empujar el contenido a la derecha */}
            <div className="flex-1"></div>

            {/* Información del usuario y botón cerrar sesión (alineados a la derecha) */}
            <div className="flex items-center space-x-4">
              <span className="text-sm text-white hidden sm:inline">
                Bienvenido, <strong>{user?.nombre}</strong>
              </span>
              <span className="text-xs text-orange-100 bg-orange-700 px-2 py-1 rounded hidden sm:inline-block">
                {user?.rol?.nombre}
              </span>
              <button
                onClick={handleLogout}
                className="text-sm text-white hover:text-orange-200 transition-colors duration-200 px-3 py-1 rounded hover:bg-orange-700"
              >
                Cerrar Sesión
              </button>
            </div>
          </div>
        </div>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto p-6 bg-white">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;
