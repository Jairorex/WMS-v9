import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Picking {
  id_picking: number;
  id_orden: number;
  estado: string;
  asignado_a: number;
  creado_por: number;
  ts_asignado: string;
  ts_cierre?: string;
  orden: {
    id_orden: number;
    cliente: string;
    fecha_compromiso: string;
  };
  asignadoA: {
    id_usuario: number;
    nombre: string;
  };
}

interface PickingDetalle {
  id_picking_det: number;
  id_producto: number;
  id_ubicacion: number;
  lote: string;
  cant_objetivo: number;
  cant_pickeada: number;
  producto: {
    nombre: string;
    codigo_barras: string;
  };
  ubicacion: {
    codigo: string;
  };
}

const PickingList: React.FC = () => {
  const [pickings, setPickings] = useState<Picking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    estado: '',
    asignado_a: '',
    desde: '',
    hasta: ''
  });
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchPickings();
  }, [filtros]);

  const fetchPickings = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });

      const response = await http.get(`/api/picking?${params.toString()}`);
      setPickings(response.data.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar pickings');
    } finally {
      setLoading(false);
    }
  };

  const getEstadoColor = (estado: string) => {
    const colores = {
      'ASIGNADO': 'bg-yellow-100 text-yellow-800',
      'EN_PROCESO': 'bg-blue-100 text-blue-800',
      'PAUSADO': 'bg-orange-100 text-orange-800',
      'COMPLETADO': 'bg-green-100 text-green-800',
      'CANCELADO': 'bg-red-100 text-red-800'
    };
    return colores[estado as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const getEstadoTexto = (estado: string) => {
    const textos = {
      'ASIGNADO': 'Asignado',
      'EN_PROCESO': 'En Proceso',
      'PAUSADO': 'Pausado',
      'COMPLETADO': 'Completado',
      'CANCELADO': 'Cancelado'
    };
    return textos[estado as keyof typeof textos] || estado;
  };

  const [showModal, setShowModal] = useState(false);
  const [catalogos, setCatalogos] = useState<{
    ordenes: Array<{ id_orden: number; cliente: string; fecha_compromiso: string }>;
    usuarios: Array<{ id_usuario: number; nombre: string }>;
  } | null>(null);
  const [formData, setFormData] = useState({
    id_orden: '',
    asignado_a: ''
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (showModal) {
      fetchCatalogos();
    }
  }, [showModal]);

  const fetchCatalogos = async () => {
    try {
      const [ordenesRes, usuariosRes] = await Promise.all([
        http.get('/api/ordenes-salida?estado=CREADA&per_page=1000'),
        http.get('/api/usuarios?activo=true&per_page=1000')
      ]);

      setCatalogos({
        ordenes: ordenesRes.data.data || ordenesRes.data || [],
        usuarios: Array.isArray(usuariosRes.data.data) 
          ? usuariosRes.data.data 
          : Array.isArray(usuariosRes.data) 
            ? usuariosRes.data 
            : []
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      // Asegurar que usuarios sea siempre un array
      setCatalogos({
        ordenes: [],
        usuarios: []
      });
    }
  };

  const handleCrearPicking = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.id_orden) {
      setError('Debe seleccionar una orden');
      return;
    }

    setSubmitting(true);
    try {
      await http.post('/api/picking', {
        id_orden: parseInt(formData.id_orden),
        asignado_a: formData.asignado_a ? parseInt(formData.asignado_a) : null
      });
      setShowModal(false);
      setFormData({ id_orden: '', asignado_a: '' });
      fetchPickings();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear picking');
    } finally {
      setSubmitting(false);
    }
  };

  const handleVerDetalle = (id: number) => {
    navigate(`/picking/${id}`);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando pickings...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Gestión de Picking</h1>
        {(user?.rol_id === 1 || user?.rol_id === '1' || user?.rol_id === 2 || user?.rol_id === '2') && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
          >
            Nuevo Picking
          </button>
        )}
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {/* Filtros */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <h3 className="text-lg font-semibold mb-4">Filtros</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
              <option value="ASIGNADO">Asignado</option>
              <option value="EN_PROCESO">En Proceso</option>
              <option value="PAUSADO">Pausado</option>
              <option value="COMPLETADO">Completado</option>
              <option value="CANCELADO">Cancelado</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Fecha Desde
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
              Fecha Hasta
            </label>
            <input
              type="date"
              value={filtros.hasta}
              onChange={(e) => setFiltros({ ...filtros, hasta: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div className="flex items-end">
            <button
              onClick={() => setFiltros({ estado: '', asignado_a: '', desde: '', hasta: '' })}
              className="w-full bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
            >
              Limpiar Filtros
            </button>
          </div>
        </div>
      </div>

      {/* Tabla de pickings */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Orden
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cliente
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Asignado a
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha Compromiso
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {pickings.map((picking) => (
                <tr key={picking.id_picking} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    #{picking.id_picking}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    #{picking.orden.id_orden}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {picking.orden.cliente}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {picking.asignadoA.nombre}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(picking.estado)}`}>
                      {getEstadoTexto(picking.estado)}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {new Date(picking.orden.fecha_compromiso).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={() => handleVerDetalle(picking.id_picking)}
                      className="text-blue-600 hover:text-blue-900 mr-3"
                    >
                      Ver Detalle
                    </button>
                    {(user?.rol_id === 1 || user?.rol_id === '1' || user?.rol_id === 2 || user?.rol_id === '2') && 
                     picking.estado !== 'CANCELADO' && picking.estado !== 'Cancelado' &&
                     picking.estado !== 'COMPLETADO' && picking.estado !== 'Completado' && (
                      <button
                        onClick={async () => {
                          if (window.confirm('¿Está seguro de cancelar este picking?')) {
                            try {
                              await http.patch(`/api/picking/${picking.id_picking}/cancelar`);
                              fetchPickings();
                            } catch (err: any) {
                              setError(err.response?.data?.message || 'Error al cancelar picking');
                            }
                          }
                        }}
                        className="text-red-600 hover:text-red-900"
                      >
                        Cancelar
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {pickings.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No se encontraron pickings con los filtros aplicados
          </div>
        )}
      </div>

      {/* Modal para crear picking */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold">Nuevo Picking</h2>
              <button
                onClick={() => {
                  setShowModal(false);
                  setFormData({ id_orden: '', asignado_a: '' });
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCrearPicking} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Orden de Salida *
                </label>
                <select
                  value={formData.id_orden}
                  onChange={(e) => setFormData({ ...formData, id_orden: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                >
                  <option value="">Seleccionar orden...</option>
                  {catalogos?.ordenes.map((orden) => (
                    <option key={orden.id_orden} value={orden.id_orden}>
                      Orden #{orden.id_orden} - {orden.cliente}
                    </option>
                  ))}
                </select>
                {catalogos?.ordenes.length === 0 && (
                  <p className="mt-1 text-sm text-gray-500">No hay órdenes creadas disponibles</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Asignar a
                </label>
                <select
                  value={formData.asignado_a}
                  onChange={(e) => setFormData({ ...formData, asignado_a: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Sin asignar</option>
                  {Array.isArray(catalogos?.usuarios) && catalogos.usuarios.map((usuario) => (
                    <option key={usuario.id_usuario} value={usuario.id_usuario}>
                      {usuario.nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div className="flex justify-end gap-2 mt-6">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    setFormData({ id_orden: '', asignado_a: '' });
                  }}
                  className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  {submitting ? 'Creando...' : 'Crear Picking'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default PickingList;
