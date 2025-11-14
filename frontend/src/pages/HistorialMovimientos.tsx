import React, { useState, useEffect } from 'react';
import { http } from '../lib/http';

interface MovimientoInventario {
  id: number;
  producto_id: number;
  ubicacion_id?: number;
  lote_id?: number;
  tipo_movimiento: string;
  cantidad: number;
  cantidad_anterior?: number;
  cantidad_nueva?: number;
  motivo?: string;
  referencia?: string;
  fecha_movimiento: string;
  observaciones?: string;
  producto?: {
    id_producto: number;
    nombre: string;
    codigo_barra?: string;
  };
  ubicacion?: {
    id_ubicacion: number;
    codigo: string;
    pasillo?: string;
    estanteria?: string;
    nivel?: string;
  };
  lote?: {
    id: number;
    codigo_lote: string;
  };
  usuario?: {
    id_usuario: number;
    nombre: string;
    usuario: string;
  };
}

interface Catalogos {
  productos: Array<{ id_producto: number; nombre: string; codigo_barra?: string }>;
  ubicaciones: Array<{ id_ubicacion: number; codigo: string }>;
  tipos_movimiento: Array<{ value: string; label: string }>;
}

const HistorialMovimientos: React.FC = () => {
  const [movimientos, setMovimientos] = useState<MovimientoInventario[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [pagination, setPagination] = useState({
    current_page: 1,
    last_page: 1,
    per_page: 15,
    total: 0
  });
  const [filtros, setFiltros] = useState({
    q: '',
    producto_id: '',
    ubicacion_id: '',
    lote_id: '',
    tipo_movimiento: '',
    fecha_desde: '',
    fecha_hasta: '',
    usuario_id: ''
  });
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    fetchMovimientos();
    fetchCatalogos();
  }, [filtros, pagination.current_page]);

  const fetchMovimientos = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      params.append('page', pagination.current_page.toString());
      params.append('per_page', pagination.per_page.toString());

      const response = await http.get(`/api/movimientos-inventario?${params.toString()}`);
      
      if (response.data.data) {
        setMovimientos(response.data.data);
        setPagination({
          current_page: response.data.current_page || 1,
          last_page: response.data.last_page || 1,
          per_page: response.data.per_page || 15,
          total: response.data.total || 0
        });
      } else {
        setMovimientos(response.data);
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar movimientos');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      // Obtener productos
      const productosRes = await http.get('/api/productos?per_page=1000');
      const productos = productosRes.data.data || productosRes.data;

      // Obtener ubicaciones
      const ubicacionesRes = await http.get('/api/ubicaciones?per_page=1000');
      const ubicaciones = ubicacionesRes.data.data || ubicacionesRes.data;

      setCatalogos({
        productos: productos,
        ubicaciones: ubicaciones,
        tipos_movimiento: [
          { value: 'ENTRADA', label: 'Entrada' },
          { value: 'SALIDA', label: 'Salida' },
          { value: 'TRASLADO', label: 'Traslado' },
          { value: 'AJUSTE', label: 'Ajuste' },
          { value: 'DEVOLUCION', label: 'Devolución' },
          { value: 'RESERVA', label: 'Reserva' },
          { value: 'LIBERACION', label: 'Liberación' }
        ]
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
    }
  };

  const getTipoMovimientoColor = (tipo: string) => {
    const colores: { [key: string]: string } = {
      'ENTRADA': 'bg-green-100 text-green-800 border-green-200',
      'SALIDA': 'bg-red-100 text-red-800 border-red-200',
      'TRASLADO': 'bg-blue-100 text-blue-800 border-blue-200',
      'AJUSTE': 'bg-yellow-100 text-yellow-800 border-yellow-200',
      'DEVOLUCION': 'bg-purple-100 text-purple-800 border-purple-200',
      'RESERVA': 'bg-orange-100 text-orange-800 border-orange-200',
      'LIBERACION': 'bg-teal-100 text-teal-800 border-teal-200'
    };
    return colores[tipo] || 'bg-gray-100 text-gray-800 border-gray-200';
  };

  const getTipoMovimientoIcon = (tipo: string) => {
    const iconos: { [key: string]: string } = {
      'ENTRADA': '📥',
      'SALIDA': '📤',
      'TRASLADO': '🔄',
      'AJUSTE': '⚙️',
      'DEVOLUCION': '↩️',
      'RESERVA': '🔒',
      'LIBERACION': '🔓'
    };
    return iconos[tipo] || '📋';
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

  const limpiarFiltros = () => {
    setFiltros({
      q: '',
      producto_id: '',
      ubicacion_id: '',
      lote_id: '',
      tipo_movimiento: '',
      fecha_desde: '',
      fecha_hasta: '',
      usuario_id: ''
    });
    setPagination({ ...pagination, current_page: 1 });
  };

  const handlePageChange = (page: number) => {
    setPagination({ ...pagination, current_page: page });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (loading && movimientos.length === 0) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando historial de movimientos...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Historial de Movimientos</h1>
          <p className="text-gray-600 mt-1">Registro completo de todos los movimientos de inventario</p>
        </div>
        <button
          onClick={() => setShowFilters(!showFilters)}
          className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
        >
          {showFilters ? 'Ocultar Filtros' : 'Mostrar Filtros'}
        </button>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {/* Filtros */}
      {showFilters && (
        <div className="mb-6 p-4 bg-white rounded-lg shadow border border-gray-200">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
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
                <option value="">Todos los productos</option>
                {catalogos?.productos.map((producto) => (
                  <option key={producto.id_producto} value={producto.id_producto}>
                    {producto.nombre} {producto.codigo_barra && `(${producto.codigo_barra})`}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Ubicación
              </label>
              <select
                value={filtros.ubicacion_id}
                onChange={(e) => setFiltros({ ...filtros, ubicacion_id: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todas las ubicaciones</option>
                {catalogos?.ubicaciones.map((ubicacion) => (
                  <option key={ubicacion.id_ubicacion} value={ubicacion.id_ubicacion}>
                    {ubicacion.codigo}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Movimiento
              </label>
              <select
                value={filtros.tipo_movimiento}
                onChange={(e) => setFiltros({ ...filtros, tipo_movimiento: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todos los tipos</option>
                {catalogos?.tipos_movimiento.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>
                    {tipo.label}
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

            <div className="flex items-end">
              <button
                onClick={limpiarFiltros}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors"
              >
                Limpiar Filtros
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Estadísticas rápidas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Total Movimientos</div>
          <div className="text-2xl font-bold text-gray-900">{pagination.total}</div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Entradas</div>
          <div className="text-2xl font-bold text-green-600">
            {movimientos.filter(m => m.tipo_movimiento === 'ENTRADA').length}
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Salidas</div>
          <div className="text-2xl font-bold text-red-600">
            {movimientos.filter(m => m.tipo_movimiento === 'SALIDA').length}
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Ajustes</div>
          <div className="text-2xl font-bold text-yellow-600">
            {movimientos.filter(m => m.tipo_movimiento === 'AJUSTE').length}
          </div>
        </div>
      </div>

      {/* Tabla de movimientos */}
      <div className="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Producto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ubicación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Lote
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cantidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Usuario
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Motivo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Referencia
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {movimientos.length === 0 ? (
                <tr>
                  <td colSpan={9} className="px-6 py-4 text-center text-gray-500">
                    No se encontraron movimientos
                  </td>
                </tr>
              ) : (
                movimientos.map((movimiento) => (
                  <tr key={movimiento.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatFecha(movimiento.fecha_movimiento)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getTipoMovimientoColor(movimiento.tipo_movimiento)}`}>
                        <span className="mr-1">{getTipoMovimientoIcon(movimiento.tipo_movimiento)}</span>
                        {movimiento.tipo_movimiento}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {movimiento.producto?.nombre || 'No disponible'}
                      </div>
                      {movimiento.producto?.codigo_barra && (
                        <div className="text-sm text-gray-500">
                          {movimiento.producto.codigo_barra}
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.ubicacion ? (
                        <div>
                          <div className="font-medium">{movimiento.ubicacion.codigo}</div>
                          {movimiento.ubicacion.pasillo && (
                            <div className="text-xs text-gray-500">
                              P{movimiento.ubicacion.pasillo}-E{movimiento.ubicacion.estanteria}-N{movimiento.ubicacion.nivel}
                            </div>
                          )}
                        </div>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.lote ? (
                        <span className="font-medium">{movimiento.lote.codigo_lote}</span>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {movimiento.cantidad.toFixed(2)}
                      </div>
                      {movimiento.cantidad_anterior !== undefined && movimiento.cantidad_nueva !== undefined && (
                        <div className="text-xs text-gray-500">
                          {movimiento.cantidad_anterior.toFixed(2)} → {movimiento.cantidad_nueva.toFixed(2)}
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.usuario?.nombre || '-'}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900 max-w-xs truncate">
                      {movimiento.motivo || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {movimiento.referencia || '-'}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Paginación */}
        {pagination.last_page > 1 && (
          <div className="bg-gray-50 px-6 py-3 border-t border-gray-200 flex items-center justify-between">
            <div className="text-sm text-gray-700">
              Mostrando {((pagination.current_page - 1) * pagination.per_page) + 1} a{' '}
              {Math.min(pagination.current_page * pagination.per_page, pagination.total)} de{' '}
              {pagination.total} movimientos
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => handlePageChange(pagination.current_page - 1)}
                disabled={pagination.current_page === 1}
                className="px-3 py-1 bg-white border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Anterior
              </button>
              <span className="px-3 py-1 bg-white border border-gray-300 rounded-md text-sm font-medium text-gray-700">
                Página {pagination.current_page} de {pagination.last_page}
              </span>
              <button
                onClick={() => handlePageChange(pagination.current_page + 1)}
                disabled={pagination.current_page === pagination.last_page}
                className="px-3 py-1 bg-white border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Siguiente
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default HistorialMovimientos;
