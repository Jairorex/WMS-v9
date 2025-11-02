import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Incidencia {
  id_incidencia: number;
  id_tarea?: number;
  id_operario: number;
  id_producto: number;
  descripcion: string;
  estado: string;
  fecha_reporte: string;
  fecha_resolucion?: string;
  tarea?: {
    id_tarea: number;
    descripcion: string;
  };
  operario: {
    id_usuario: number;
    nombre: string;
  };
  producto: {
    id_producto: number;
    nombre: string;
    lote: string;
  };
}

interface Catalogos {
  estados: Array<{ codigo: string; nombre: string }>;
  operarios: Array<{ id_usuario: number; nombre: string }>;
  productos: Array<{ id_producto: number; nombre: string }>;
  tareas: Array<{ id_tarea: number; descripcion: string }>;
}

const Incidencias: React.FC = () => {
  const [incidencias, setIncidencias] = useState<Incidencia[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: '',
    estado: '',
    operario: '',
    producto: '',
    desde: '',
    hasta: '',
    pendientes: false
  });
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    id_tarea: '',
    id_operario: '',
    id_producto: '',
    descripcion: '',
    estado: 'Pendiente'
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchIncidencias();
    fetchCatalogos();
  }, [filtros]);

  const fetchIncidencias = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      const response = await http.get(`/api/incidencias?${params.toString()}`);
      setIncidencias(response.data.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar incidencias');
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const response = await http.get('/api/incidencias-catalogos');
      setCatalogos(response.data);
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
    }
  };

  const handleCrearIncidencia = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    try {
      const dataToSend = {
        ...formData,
        id_tarea: formData.id_tarea ? parseInt(formData.id_tarea) : null,
        id_operario: parseInt(formData.id_operario),
        id_producto: parseInt(formData.id_producto)
      };
      
      await http.post('/api/incidencias', dataToSend);
      setShowModal(false);
      setFormData({
        id_tarea: '',
        id_operario: '',
        id_producto: '',
        descripcion: '',
        estado: 'Pendiente'
      });
      fetchIncidencias();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear incidencia');
    } finally {
      setSubmitting(false);
    }
  };

  const handleVerDetalle = (id: number) => {
    navigate(`/incidencias/${id}`);
  };

  const handleResolver = async (id: number) => {
    try {
      await http.patch(`/api/incidencias/${id}/resolver`);
      fetchIncidencias();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al resolver incidencia');
    }
  };

  const handleReabrir = async (id: number) => {
    try {
      await http.patch(`/api/incidencias/${id}/reabrir`);
      fetchIncidencias();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al reabrir incidencia');
    }
  };

  const getEstadoColor = (estado: string) => {
    const colores = {
      'Pendiente': 'bg-yellow-100 text-yellow-800',
      'Resuelta': 'bg-green-100 text-green-800'
    };
    return colores[estado as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const puedeGestionarIncidencias = () => {
    if (!user) return false;
    const esAdmin = user.rol_id === 1 || user.rol_id === '1';
    const esSupervisor = user.rol_id === 2 || user.rol_id === '2';
    return esAdmin || esSupervisor;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando incidencias...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Gestión de Incidencias</h1>
        <button
          onClick={() => setShowModal(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
        >
          Reportar Incidencia
        </button>
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {/* Filtros */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <h3 className="text-lg font-semibold mb-4">Filtros</h3>
        <div className="grid grid-cols-1 md:grid-cols-6 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Búsqueda
            </label>
            <input
              type="text"
              placeholder="Buscar por descripción..."
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Estado
            </label>
            <select
              value={filtros.estado}
              onChange={(e) => setFiltros({ ...filtros, estado: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.estados.map((estado) => (
                <option key={estado.codigo} value={estado.codigo}>
                  {estado.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Operario
            </label>
            <select
              value={filtros.operario}
              onChange={(e) => setFiltros({ ...filtros, operario: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.operarios.map((operario) => (
                <option key={operario.id_usuario} value={operario.id_usuario}>
                  {operario.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Producto
            </label>
            <select
              value={filtros.producto}
              onChange={(e) => setFiltros({ ...filtros, producto: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.productos.map((producto) => (
                <option key={producto.id_producto} value={producto.id_producto}>
                  {producto.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Desde
            </label>
            <input
              type="date"
              value={filtros.desde}
              onChange={(e) => setFiltros({ ...filtros, desde: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Hasta
            </label>
            <input
              type="date"
              value={filtros.hasta}
              onChange={(e) => setFiltros({ ...filtros, hasta: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
        
        <div className="mt-4 flex items-center space-x-4">
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.pendientes}
              onChange={(e) => setFiltros({ ...filtros, pendientes: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Solo pendientes</span>
          </label>
          
          <button
            onClick={() => setFiltros({ q: '', estado: '', operario: '', producto: '', desde: '', hasta: '', pendientes: false })}
            className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>

      {/* Tabla de incidencias */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Descripción
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Producto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Operario
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha Reporte
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {incidencias.map((incidencia) => (
                <tr key={incidencia.id_incidencia} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    #{incidencia.id_incidencia}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900 max-w-xs truncate">
                      {incidencia.descripcion}
                    </div>
                    {incidencia.tarea && (
                      <div className="text-xs text-gray-500">
                        Tarea: {incidencia.tarea.descripcion}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <div>{incidencia.producto.nombre}</div>
                    <div className="text-xs text-gray-500">Lote: {incidencia.producto.lote}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {incidencia.operario.nombre}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(incidencia.estado)}`}>
                      {incidencia.estado}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {new Date(incidencia.fecha_reporte).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    <button
                      onClick={() => handleVerDetalle(incidencia.id_incidencia)}
                      className="text-blue-600 hover:text-blue-900"
                    >
                      Ver
                    </button>
                    {puedeGestionarIncidencias() && (
                      <>
                        {incidencia.estado === 'Pendiente' ? (
                          <button
                            onClick={() => handleResolver(incidencia.id_incidencia)}
                            className="text-green-600 hover:text-green-900"
                          >
                            Resolver
                          </button>
                        ) : (
                          <button
                            onClick={() => handleReabrir(incidencia.id_incidencia)}
                            className="text-orange-600 hover:text-orange-900"
                          >
                            Reabrir
                          </button>
                        )}
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {incidencias.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No se encontraron incidencias con los filtros aplicados
          </div>
        )}
      </div>

      {/* Modal para crear incidencia */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Reportar Incidencia
              </h3>
              <form onSubmit={handleCrearIncidencia} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Operario *
                  </label>
                  <select
                    value={formData.id_operario}
                    onChange={(e) => setFormData({ ...formData, id_operario: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar operario</option>
                    {catalogos?.operarios.map((operario) => (
                      <option key={operario.id_usuario} value={operario.id_usuario}>
                        {operario.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Producto *
                  </label>
                  <select
                    value={formData.id_producto}
                    onChange={(e) => setFormData({ ...formData, id_producto: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar producto</option>
                    {catalogos?.productos.map((producto) => (
                      <option key={producto.id_producto} value={producto.id_producto}>
                        {producto.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Tarea (opcional)
                  </label>
                  <select
                    value={formData.id_tarea}
                    onChange={(e) => setFormData({ ...formData, id_tarea: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Sin tarea asociada</option>
                    {catalogos?.tareas.map((tarea) => (
                      <option key={tarea.id_tarea} value={tarea.id_tarea}>
                        {tarea.descripcion}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Descripción *
                  </label>
                  <textarea
                    value={formData.descripcion}
                    onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                    placeholder="Describe la incidencia..."
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Estado
                  </label>
                  <select
                    value={formData.estado}
                    onChange={(e) => setFormData({ ...formData, estado: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    {catalogos?.estados.map((estado) => (
                      <option key={estado.codigo} value={estado.codigo}>
                        {estado.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                  >
                    {submitting ? 'Creando...' : 'Reportar Incidencia'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Incidencias;
