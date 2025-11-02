import React from 'react';

const Reportes: React.FC = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Reportes</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Reporte de Inventario */}
        <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
          <div className="flex items-center mb-4">
            <span className="text-2xl mr-3">📦</span>
            <h3 className="text-lg font-semibold">Reporte de Inventario</h3>
          </div>
          <p className="text-gray-600 mb-4">
            Generar reporte detallado del inventario actual por ubicación y producto.
          </p>
          <button className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors">
            Generar Reporte
          </button>
        </div>

        {/* Reporte de Movimientos */}
        <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
          <div className="flex items-center mb-4">
            <span className="text-2xl mr-3">🔄</span>
            <h3 className="text-lg font-semibold">Reporte de Movimientos</h3>
          </div>
          <p className="text-gray-600 mb-4">
            Reporte de todos los movimientos de mercancía en un período específico.
          </p>
          <button className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 transition-colors">
            Generar Reporte
          </button>
        </div>

        {/* Reporte de Usuarios */}
        <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
          <div className="flex items-center mb-4">
            <span className="text-2xl mr-3">👥</span>
            <h3 className="text-lg font-semibold">Reporte de Usuarios</h3>
          </div>
          <p className="text-gray-600 mb-4">
            Reporte de actividad de usuarios y estadísticas de uso del sistema.
          </p>
          <button className="w-full bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 transition-colors">
            Generar Reporte
          </button>
        </div>

        {/* Reporte de Tareas */}
        <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
          <div className="flex items-center mb-4">
            <span className="text-2xl mr-3">📋</span>
            <h3 className="text-lg font-semibold">Reporte de Tareas</h3>
          </div>
          <p className="text-gray-600 mb-4">
            Reporte de tareas completadas, pendientes y tiempos de ejecución.
          </p>
          <button className="w-full bg-orange-600 text-white py-2 px-4 rounded-md hover:bg-orange-700 transition-colors">
            Generar Reporte
          </button>
        </div>

        {/* Reporte de Productividad */}
        <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
          <div className="flex items-center mb-4">
            <span className="text-2xl mr-3">📈</span>
            <h3 className="text-lg font-semibold">Reporte de Productividad</h3>
          </div>
          <p className="text-gray-600 mb-4">
            Análisis de productividad por operario y métricas de rendimiento.
          </p>
          <button className="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 transition-colors">
            Generar Reporte
          </button>
        </div>

        {/* Reporte Personalizado */}
        <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
          <div className="flex items-center mb-4">
            <span className="text-2xl mr-3">⚙️</span>
            <h3 className="text-lg font-semibold">Reporte Personalizado</h3>
          </div>
          <p className="text-gray-600 mb-4">
            Crear reportes personalizados con filtros y campos específicos.
          </p>
          <button className="w-full bg-gray-600 text-white py-2 px-4 rounded-md hover:bg-gray-700 transition-colors">
            Configurar Reporte
          </button>
        </div>
      </div>

      {/* Sección de filtros rápidos */}
      <div className="mt-8 bg-white p-6 rounded-lg shadow-md">
        <h3 className="text-lg font-semibold mb-4">Filtros Rápidos</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Fecha Desde
            </label>
            <input
              type="date"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Fecha Hasta
            </label>
            <input
              type="date"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tipo de Reporte
            </label>
            <select className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="">Seleccionar tipo</option>
              <option value="inventario">Inventario</option>
              <option value="movimientos">Movimientos</option>
              <option value="usuarios">Usuarios</option>
              <option value="tareas">Tareas</option>
            </select>
          </div>
        </div>
        <div className="mt-4">
          <button className="bg-blue-600 text-white py-2 px-6 rounded-md hover:bg-blue-700 transition-colors">
            Aplicar Filtros
          </button>
        </div>
      </div>
    </div>
  );
};

export default Reportes;
