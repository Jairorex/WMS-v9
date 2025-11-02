import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Packing {
  id_packing?: number;
  id_orden_salida: number;
  estado: string;
  asignado_a?: number;
  fecha_inicio?: string;
  fecha_fin?: string;
  observaciones?: string;
  orden_salida?: {
    id_orden: number;
    cliente: string;
    fecha_compromiso: string;
  };
  asignadoA?: {
    id_usuario: number;
    nombre: string;
  };
  detalles?: Array<{
    id_producto: number;
    cantidad: number;
    producto: {
      nombre: string;
    };
  }>;
}

interface Catalogos {
  ordenes_salida: Array<{ id_orden: number; cliente: string; fecha_compromiso: string }>;
  usuarios: Array<{ id_usuario: number; nombre: string }>;
}

const Packing: React.FC = () => {
  const [packings, setPackings] = useState<Packing[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: '',
    estado: '',
    asignado_a: '',
    fecha_desde: '',
    fecha_hasta: ''
  });
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    id_orden_salida: '',
    asignado_a: '',
    observaciones: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchPackings();
    fetchCatalogos();
  }, [filtros]);

  const fetchPackings = async () => {
    try {
      setLoading(true);
      // Usar órdenes de salida como base para packing
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      const response = await http.get(`/api/ordenes-salida?${params.toString()}`);
      const ordenes = response.data.data || response.data;
      
      // Convertir órdenes de salida a formato packing
      const packingsData = ordenes.map((orden: any) => ({
        id_packing: orden.id_orden,
        id_orden_salida: orden.id_orden,
        estado: orden.estado || 'PENDIENTE',
        fecha_inicio: orden.fecha_creacion,
        fecha_fin: orden.fecha_cierre,
        orden_salida: orden,
        detalles: orden.detalles || []
      }));
      
      setPackings(packingsData);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar packings');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const [ordenesRes, usuariosRes] = await Promise.all([
        http.get('/api/ordenes-salida?per_page=1000'),
        http.get('/api/usuarios?activo=true&per_page=1000')
      ]);

      setCatalogos({
        ordenes_salida: ordenesRes.data.data || ordenesRes.data || [],
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
        ordenes_salida: [],
        usuarios: []
      });
    }
  };

  const handleCrearPacking = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    try {
      // Crear packing basado en orden de salida
      await http.post('/api/packing', {
        id_orden_salida: parseInt(formData.id_orden_salida),
        asignado_a: formData.asignado_a ? parseInt(formData.asignado_a) : null,
        observaciones: formData.observaciones || null
      });
      setShowModal(false);
      resetForm();
      fetchPackings();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear packing');
    } finally {
      setSubmitting(false);
    }
  };

  const handleCambiarEstado = async (id: number, nuevoEstado: string) => {
    try {
      await http.patch(`/api/packing/${id}/estado`, { estado: nuevoEstado });
      fetchPackings();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cambiar estado');
    }
  };

  const resetForm = () => {
    setFormData({
      id_orden_salida: '',
      asignado_a: '',
      observaciones: ''
    });
  };

  const getEstadoColor = (estado: string) => {
    const colores: { [key: string]: string } = {
      'PENDIENTE': 'bg-yellow-100 text-yellow-800 border-yellow-200',
      'EN_PROCESO': 'bg-blue-100 text-blue-800 border-blue-200',
      'COMPLETADO': 'bg-green-100 text-green-800 border-green-200',
      'CANCELADO': 'bg-red-100 text-red-800 border-red-200'
    };
    return colores[estado] || 'bg-gray-100 text-gray-800 border-gray-200';
  };

  const formatFecha = (fecha: string) => {
    if (!fecha) return '-';
    const date = new Date(fecha);
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading && packings.length === 0) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando packings...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">PACKING</h1>
        {(user?.rol_id === 1 || user?.rol_id === '1' || user?.rol_id === 2 || user?.rol_id === '2') && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Nuevo Packing
          </button>
        )}
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {/* Filtros */}
      <div className="mb-6 p-4 bg-white rounded-lg shadow border border-gray-200">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Búsqueda
            </label>
            <input
              type="text"
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
              placeholder="Buscar por cliente..."
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
              <option value="PENDIENTE">Pendiente</option>
              <option value="EN_PROCESO">En Proceso</option>
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
              value={filtros.fecha_desde}
              onChange={(e) => setFiltros({ ...filtros, fecha_desde: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Fecha Hasta
            </label>
            <input
              type="date"
              value={filtros.fecha_hasta}
              onChange={(e) => setFiltros({ ...filtros, fecha_hasta: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
      </div>

      {/* Tabla de packings */}
      <div className="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Orden</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cliente</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Asignado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha Inicio</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha Fin</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {packings.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    No se encontraron packings
                  </td>
                </tr>
              ) : (
                packings.map((packing) => (
                  <tr key={packing.id_packing || Math.random()} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      #{packing.id_orden_salida}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {packing.orden_salida?.cliente || 'No disponible'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getEstadoColor(packing.estado)}`}>
                        {packing.estado}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {packing.asignadoA?.nombre || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatFecha(packing.fecha_inicio || '')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatFecha(packing.fecha_fin || '')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      {packing.estado === 'PENDIENTE' && (
                        <button
                          onClick={() => handleCambiarEstado(packing.id_packing!, 'EN_PROCESO')}
                          className="text-blue-600 hover:text-blue-800 mr-2"
                        >
                          Iniciar
                        </button>
                      )}
                      {packing.estado === 'EN_PROCESO' && (
                        <button
                          onClick={() => handleCambiarEstado(packing.id_packing!, 'COMPLETADO')}
                          className="text-green-600 hover:text-green-800"
                        >
                          Completar
                        </button>
                      )}
                      <button
                        onClick={() => navigate(`/ordenes-salida/${packing.id_orden_salida}`)}
                        className="text-gray-600 hover:text-gray-800 ml-2"
                      >
                        Ver Detalle
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal de creación */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
            <h2 className="text-2xl font-bold mb-4">Nuevo Packing</h2>
            <form onSubmit={handleCrearPacking}>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Orden de Salida *
                  </label>
                  <select
                    value={formData.id_orden_salida}
                    onChange={(e) => setFormData({ ...formData, id_orden_salida: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="">Seleccionar orden</option>
                    {catalogos?.ordenes_salida.map((orden) => (
                      <option key={orden.id_orden} value={orden.id_orden}>
                        #{orden.id_orden} - {orden.cliente}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Asignado a
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

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Observaciones
                  </label>
                  <textarea
                    value={formData.observaciones}
                    onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2 mt-6">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    resetForm();
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
                  {submitting ? 'Guardando...' : 'Guardar'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Packing;

