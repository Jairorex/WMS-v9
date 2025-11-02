import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';

interface ProductoExistencia {
  id_producto: number;
  nombre: string;
  descripcion?: string;
  codigo_barra?: string;
  stock_minimo: number;
  precio?: number;
  estado: {
    id_estado_producto: number;
    codigo: string;
    nombre: string;
  };
  unidadMedida?: {
    id: number;
    codigo: string;
    nombre: string;
  };
  inventario?: Array<{
    id_inventario: number;
    cantidad: number;
    cantidad_disponible: number;
    cantidad_reservada: number;
    ubicacion: {
      id_ubicacion: number;
      codigo: string;
      pasillo?: string;
      estanteria?: string;
      nivel?: string;
    };
    lote?: {
      id: number;
      codigo_lote: string;
      fecha_caducidad?: string;
    };
  }>;
  total_existencia?: number;
  total_disponible?: number;
  total_reservado?: number;
  ubicaciones_count?: number;
}

const Inventario: React.FC = () => {
  const [productos, setProductos] = useState<ProductoExistencia[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [filtros, setFiltros] = useState({
    estado: '',
    stock_bajo: false,
    sin_stock: false
  });
  const navigate = useNavigate();

  useEffect(() => {
    fetchProductos();
  }, [filtros, search]);

  const fetchProductos = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      if (search) params.append('q', search);
      if (filtros.estado) params.append('estado', filtros.estado);
      params.append('per_page', '1000');

      const response = await http.get(`/api/productos?${params.toString()}`);
      const productosData = response.data.data || response.data;

      // Obtener detalles de inventario para cada producto
      const productosConInventario = await Promise.all(
        productosData.map(async (producto: ProductoExistencia) => {
          try {
            const inventarioRes = await http.get(`/api/productos/${producto.id_producto}`);
            const inventario = inventarioRes.data.producto?.inventario || [];
            
            // Calcular totales
            const total_existencia = inventario.reduce((sum: number, inv: any) => sum + (inv.cantidad || 0), 0);
            const total_disponible = inventario.reduce((sum: number, inv: any) => sum + (inv.cantidad_disponible || inv.cantidad || 0), 0);
            const total_reservado = inventario.reduce((sum: number, inv: any) => sum + (inv.cantidad_reservada || 0), 0);

            return {
              ...producto,
              inventario,
              total_existencia,
              total_disponible,
              total_reservado,
              ubicaciones_count: inventario.length
            };
          } catch (err) {
            return {
              ...producto,
              inventario: [],
              total_existencia: 0,
              total_disponible: 0,
              total_reservado: 0,
              ubicaciones_count: 0
            };
          }
        })
      );

      // Aplicar filtros adicionales
      let productosFiltrados = productosConInventario;

      if (filtros.stock_bajo) {
        productosFiltrados = productosFiltrados.filter(p => 
          p.total_disponible !== undefined && 
          p.stock_minimo > 0 && 
          p.total_disponible <= p.stock_minimo
        );
      }

      if (filtros.sin_stock) {
        productosFiltrados = productosFiltrados.filter(p => 
          (p.total_disponible || 0) === 0
        );
      }

      setProductos(productosFiltrados);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar existencias');
    } finally {
      setLoading(false);
    }
  };

  const getEstadoColor = (codigo: string) => {
    switch (codigo?.toLowerCase()) {
      case 'disponible':
        return 'bg-green-100 text-green-800';
      case 'retenido':
      case 'reservado':
        return 'bg-yellow-100 text-yellow-800';
      case 'bloqueado':
      case 'danado':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getStockColor = (disponible: number, minimo: number) => {
    if (disponible === 0) return 'text-red-600 font-bold';
    if (minimo > 0 && disponible <= minimo) return 'text-yellow-600 font-semibold';
    return 'text-green-600';
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando existencias...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">EXISTENCIAS</h1>
          <p className="text-gray-600 mt-1">Vista detallada de todos los productos disponibles</p>
        </div>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {/* Filtros */}
      <div className="mb-6 p-4 bg-white rounded-lg shadow border border-gray-200">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Búsqueda
            </label>
            <input
              type="text"
              placeholder="Buscar por nombre, código o descripción..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
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
              <option value="">Todos los estados</option>
              <option value="disponible">Disponible</option>
              <option value="retenido">Retenido</option>
              <option value="bloqueado">Bloqueado</option>
            </select>
          </div>
          <div className="flex items-end gap-2">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={filtros.stock_bajo}
                onChange={(e) => setFiltros({ ...filtros, stock_bajo: e.target.checked })}
                className="mr-2"
              />
              <span className="text-sm text-gray-700">Stock bajo mínimo</span>
            </label>
          </div>
        </div>
      </div>

      {/* Estadísticas rápidas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Total Productos</div>
          <div className="text-2xl font-bold text-gray-900">{productos.length}</div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Con Stock</div>
          <div className="text-2xl font-bold text-green-600">
            {productos.filter(p => (p.total_disponible || 0) > 0).length}
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Stock Bajo</div>
          <div className="text-2xl font-bold text-yellow-600">
            {productos.filter(p => p.stock_minimo > 0 && (p.total_disponible || 0) <= p.stock_minimo).length}
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Sin Stock</div>
          <div className="text-2xl font-bold text-red-600">
            {productos.filter(p => (p.total_disponible || 0) === 0).length}
          </div>
        </div>
      </div>

      {/* Tabla de productos */}
      <div className="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock Total</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Disponible</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Reservado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock Mínimo</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ubicaciones</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {productos.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-6 py-4 text-center text-gray-500">
                    No se encontraron productos
                  </td>
                </tr>
              ) : (
                productos.map((producto) => (
                  <tr key={producto.id_producto} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div>
                        <div className="text-sm font-medium text-gray-900">{producto.nombre}</div>
                        {producto.codigo_barra && (
                          <div className="text-sm text-gray-500">Código: {producto.codigo_barra}</div>
                        )}
                        {producto.descripcion && (
                          <div className="text-xs text-gray-400 mt-1">{producto.descripcion}</div>
                        )}
                        {producto.unidadMedida && (
                          <div className="text-xs text-gray-400">Unidad: {producto.unidadMedida.nombre}</div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(producto.estado?.codigo || '')}`}>
                        {producto.estado?.nombre || 'No disponible'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {producto.total_existencia || 0}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`text-sm font-medium ${getStockColor(producto.total_disponible || 0, producto.stock_minimo)}`}>
                        {producto.total_disponible || 0}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {producto.total_reservado || 0}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {producto.stock_minimo || 0}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {producto.ubicaciones_count || 0} ubicación(es)
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <button
                        onClick={() => navigate(`/productos/${producto.id_producto}`)}
                        className="text-blue-600 hover:text-blue-800"
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

      {/* Modal de detalles de ubicaciones (expandible) */}
      {productos.length > 0 && (
        <div className="mt-6 bg-white rounded-lg shadow border border-gray-200 p-4">
          <h3 className="text-lg font-semibold mb-4">Desglose por Ubicaciones</h3>
          <div className="space-y-4">
            {productos.map((producto) => (
              producto.inventario && producto.inventario.length > 0 && (
                <details key={producto.id_producto} className="border-b border-gray-200 pb-4 last:border-b-0">
                  <summary className="cursor-pointer font-medium text-gray-900 hover:text-blue-600">
                    {producto.nombre} - {producto.inventario.length} ubicación(es)
                  </summary>
                  <div className="mt-2 ml-4">
                    <table className="min-w-full text-sm">
                      <thead>
                        <tr className="border-b">
                          <th className="text-left py-2 px-2">Ubicación</th>
                          <th className="text-left py-2 px-2">Cantidad</th>
                          <th className="text-left py-2 px-2">Disponible</th>
                          <th className="text-left py-2 px-2">Reservado</th>
                          <th className="text-left py-2 px-2">Lote</th>
                          <th className="text-left py-2 px-2">Vencimiento</th>
                        </tr>
                      </thead>
                      <tbody>
                        {producto.inventario.map((inv) => (
                          <tr key={inv.id_inventario} className="border-b">
                            <td className="py-2 px-2">
                              {inv.ubicacion.codigo}
                              {inv.ubicacion.pasillo && (
                                <span className="text-gray-500 ml-1">
                                  (P{inv.ubicacion.pasillo}-E{inv.ubicacion.estanteria}-N{inv.ubicacion.nivel})
                                </span>
                              )}
                            </td>
                            <td className="py-2 px-2">{inv.cantidad}</td>
                            <td className="py-2 px-2 text-green-600">{inv.cantidad_disponible || inv.cantidad}</td>
                            <td className="py-2 px-2 text-yellow-600">{inv.cantidad_reservada || 0}</td>
                            <td className="py-2 px-2">{inv.lote?.codigo_lote || '-'}</td>
                            <td className="py-2 px-2">
                              {inv.lote?.fecha_caducidad ? new Date(inv.lote.fecha_caducidad).toLocaleDateString() : '-'}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </details>
              )
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default Inventario;
