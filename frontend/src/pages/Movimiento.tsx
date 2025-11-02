import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Movimiento {
  id_movimiento?: number;
  producto_id: number;
  ubicacion_origen_id?: number;
  ubicacion_destino_id: number;
  cantidad: number;
  tipo_movimiento: string;
  lote_id?: number;
  motivo?: string;
  usuario_id: number;
  fecha_movimiento: string;
  observaciones?: string;
  producto?: {
    id_producto: number;
    nombre: string;
    codigo_barra?: string;
  };
  ubicacion_origen?: {
    id_ubicacion: number;
    codigo: string;
  };
  ubicacion_destino?: {
    id_ubicacion: number;
    codigo: string;
  };
  lote?: {
    id: number;
    codigo_lote: string;
  };
}

interface Catalogos {
  productos: Array<{ id_producto: number; nombre: string; codigo_barra?: string }>;
  ubicaciones: Array<{ id_ubicacion: number; codigo: string }>;
  lotes: Array<{ id: number; codigo_lote: string }>;
}

const Movimiento: React.FC = () => {
  const [movimientos, setMovimientos] = useState<Movimiento[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: '',
    tipo_movimiento: '',
    producto_id: '',
    fecha_desde: '',
    fecha_hasta: ''
  });
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    producto_id: '',
    ubicacion_origen_id: '',
    ubicacion_destino_id: '',
    cantidad: '',
    tipo_movimiento: 'TRASLADO',
    lote_id: '',
    motivo: '',
    observaciones: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchMovimientos();
    fetchCatalogos();
  }, [filtros]);

  const fetchMovimientos = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      const response = await http.get(`/api/movimientos-inventario?${params.toString()}&tipo_movimiento=TRASLADO`);
      setMovimientos(response.data.data || response.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar movimientos');
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const [productosRes, ubicacionesRes, lotesRes] = await Promise.all([
        http.get('/api/productos?per_page=1000'),
        http.get('/api/ubicaciones?per_page=1000'),
        http.get('/api/lotes?per_page=1000')
      ]);

      setCatalogos({
        productos: productosRes.data.data || productosRes.data,
        ubicaciones: ubicacionesRes.data.data || ubicacionesRes.data,
        lotes: lotesRes.data.data || lotesRes.data
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
    }
  };

  const handleCrearMovimiento = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    try {
      const dataToSend = {
        producto_id: parseInt(formData.producto_id),
        ubicacion_id: parseInt(formData.ubicacion_destino_id),
        ubicacion_origen_id: formData.ubicacion_origen_id ? parseInt(formData.ubicacion_origen_id) : null,
        cantidad: parseFloat(formData.cantidad),
        tipo_movimiento: formData.tipo_movimiento,
        lote_id: formData.lote_id ? parseInt(formData.lote_id) : null,
        motivo: formData.motivo || null,
        observaciones: formData.observaciones || null,
        fecha_movimiento: new Date().toISOString()
      };
      
      await http.post('/api/movimientos-inventario', dataToSend);
      setShowModal(false);
      resetForm();
      fetchMovimientos();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear movimiento');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      producto_id: '',
      ubicacion_origen_id: '',
      ubicacion_destino_id: '',
      cantidad: '',
      tipo_movimiento: 'TRASLADO',
      lote_id: '',
      motivo: '',
      observaciones: ''
    });
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

  if (loading && movimientos.length === 0) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando movimientos...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">MOVIMIENTO</h1>
        {(user?.rol_id === 1 || user?.rol_id === '1' || user?.rol_id === 2 || user?.rol_id === '2') && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Nuevo Movimiento
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
              placeholder="Buscar..."
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Producto
            </label>
            <select
              value={filtros.producto_id}
              onChange={(e) => setFiltros({ ...filtros, producto_id: e.target.value })}
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

      {/* Tabla de movimientos */}
      <div className="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Origen</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Destino</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cantidad</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lote</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Motivo</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {movimientos.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    No se encontraron movimientos
                  </td>
                </tr>
              ) : (
                movimientos.map((movimiento) => (
                  <tr key={movimiento.id_movimiento || Math.random()} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatFecha(movimiento.fecha_movimiento)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {movimiento.producto?.nombre || 'No disponible'}
                      </div>
                      {movimiento.producto?.codigo_barra && (
                        <div className="text-sm text-gray-500">{movimiento.producto.codigo_barra}</div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.ubicacion_origen?.codigo || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.ubicacion_destino?.codigo || movimiento.ubicacion_origen?.codigo || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {movimiento.cantidad}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.lote?.codigo_lote || '-'}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate">
                      {movimiento.motivo || '-'}
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
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold mb-4">Nuevo Movimiento</h2>
            <form onSubmit={handleCrearMovimiento}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Producto *
                  </label>
                  <select
                    value={formData.producto_id}
                    onChange={(e) => setFormData({ ...formData, producto_id: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Ubicación Origen
                  </label>
                  <select
                    value={formData.ubicacion_origen_id}
                    onChange={(e) => setFormData({ ...formData, ubicacion_origen_id: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Ninguna</option>
                    {catalogos?.ubicaciones.map((ubicacion) => (
                      <option key={ubicacion.id_ubicacion} value={ubicacion.id_ubicacion}>
                        {ubicacion.codigo}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Ubicación Destino *
                  </label>
                  <select
                    value={formData.ubicacion_destino_id}
                    onChange={(e) => setFormData({ ...formData, ubicacion_destino_id: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="">Seleccionar ubicación</option>
                    {catalogos?.ubicaciones.map((ubicacion) => (
                      <option key={ubicacion.id_ubicacion} value={ubicacion.id_ubicacion}>
                        {ubicacion.codigo}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cantidad *
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={formData.cantidad}
                    onChange={(e) => setFormData({ ...formData, cantidad: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Lote
                  </label>
                  <select
                    value={formData.lote_id}
                    onChange={(e) => setFormData({ ...formData, lote_id: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Ninguno</option>
                    {catalogos?.lotes.map((lote) => (
                      <option key={lote.id} value={lote.id}>
                        {lote.codigo_lote}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Motivo
                  </label>
                  <input
                    type="text"
                    value={formData.motivo}
                    onChange={(e) => setFormData({ ...formData, motivo: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>

                <div className="md:col-span-2">
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

export default Movimiento;

