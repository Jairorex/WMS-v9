import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface ProductoDetalle {
  id_producto: number;
  nombre: string;
  descripcion?: string;
  codigo_barra?: string;
  lote: string;
  estado_producto_id: number;
  fecha_caducidad?: string;
  unidad_medida: string;
  stock_minimo: number;
  precio?: number;
  estado: {
    id_estado_producto: number;
    codigo: string;
    nombre: string;
  };
  inventario: Array<{
    id_ubicacion: number;
    cantidad_disponible: number;
    cantidad_reservada: number;
    ubicacion: {
      codigo: string;
      zona: string;
    };
  }>;
}

interface Metricas {
  stock_total: number;
  stock_reservado: number;
  stock_disponible: number;
  por_debajo_minimo: boolean;
  total_ubicaciones: number;
}

interface Existencias {
  id_ubicacion: number;
  ubicacion_codigo: string;
  zona: string;
  lote: string;
  cantidad_disponible: number;
  cantidad_reservada: number;
  cantidad_libre: number;
}

const ProductoDetalle: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const [producto, setProducto] = useState<ProductoDetalle | null>(null);
  const [metricas, setMetricas] = useState<Metricas | null>(null);
  const [existencias, setExistencias] = useState<Existencias[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showExistencias, setShowExistencias] = useState(false);

  useEffect(() => {
    if (id) {
      fetchProductoDetalle();
    }
  }, [id]);

  const fetchProductoDetalle = async () => {
    try {
      setLoading(true);
      const response = await http.get(`/api/productos/${id}`);
      setProducto(response.data.producto);
      setMetricas(response.data.metricas);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar producto');
    } finally {
      setLoading(false);
    }
  };

  const fetchExistencias = async () => {
    try {
      const response = await http.get(`/api/productos/${id}/existencias`);
      setExistencias(response.data.existencias);
      setShowExistencias(true);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar existencias');
    }
  };

  const handleActivar = async () => {
    try {
      await http.patch(`/api/productos/${id}/activar`);
      fetchProductoDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al activar producto');
    }
  };

  const handleDesactivar = async () => {
    try {
      await http.patch(`/api/productos/${id}/desactivar`);
      fetchProductoDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al desactivar producto');
    }
  };

  const getEstadoColor = (codigo: string) => {
    const colores = {
      'DISPONIBLE': 'bg-green-100 text-green-800',
      'DANADO': 'bg-red-100 text-red-800',
      'RETENIDO': 'bg-yellow-100 text-yellow-800',
      'CALIDAD': 'bg-blue-100 text-blue-800'
    };
    return colores[codigo as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const puedeGestionarProductos = () => {
    if (!user) return false;
    const esAdmin = user.rol_id === 1 || user.rol_id === '1';
    return esAdmin;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando detalles del producto...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
        <button
          onClick={() => navigate('/productos')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Productos
        </button>
      </div>
    );
  }

  if (!producto) {
    return (
      <div className="p-6">
        <div className="text-center py-8 text-gray-500">
          Producto no encontrado
        </div>
        <button
          onClick={() => navigate('/productos')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Productos
        </button>
      </div>
    );
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            {producto.nombre}
          </h1>
          <p className="text-gray-600">ID: #{producto.id_producto}</p>
        </div>
        <button
          onClick={() => navigate('/productos')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver
        </button>
      </div>

      {/* Información principal */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        {/* Información básica */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Información General</h3>
          <div className="space-y-3">
            <div>
              <label className="text-sm font-medium text-gray-500">Descripción:</label>
              <p className="text-sm text-gray-900">{producto.descripcion || 'Sin descripción'}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Código de Barra:</label>
              <p className="text-sm text-gray-900">{producto.codigo_barra || 'Sin código'}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Lote:</label>
              <p className="text-sm text-gray-900">{producto.lote}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Estado:</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(producto.estado.codigo)}`}>
                {producto.estado.nombre}
              </span>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Unidad de Medida:</label>
              <p className="text-sm text-gray-900">{producto.unidad_medida}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Stock Mínimo:</label>
              <p className="text-sm text-gray-900">{producto.stock_minimo}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Precio:</label>
              <p className="text-sm text-gray-900">
                {producto.precio ? `$${producto.precio.toFixed(2)}` : 'Sin precio'}
              </p>
            </div>
            {producto.fecha_caducidad && (
              <div>
                <label className="text-sm font-medium text-gray-500">Fecha de Caducidad:</label>
                <p className="text-sm text-gray-900">
                  {new Date(producto.fecha_caducidad).toLocaleDateString()}
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Métricas de stock */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Métricas de Stock</h3>
          {metricas && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4 text-center">
                <div>
                  <div className="text-2xl font-bold text-blue-600">{metricas.stock_total}</div>
                  <div className="text-sm text-gray-500">Total</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-green-600">{metricas.stock_disponible}</div>
                  <div className="text-sm text-gray-500">Disponible</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-orange-600">{metricas.stock_reservado}</div>
                  <div className="text-sm text-gray-500">Reservado</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-gray-600">{metricas.total_ubicaciones}</div>
                  <div className="text-sm text-gray-500">Ubicaciones</div>
                </div>
              </div>
              {metricas.por_debajo_minimo && (
                <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
                  <strong>⚠️ Alerta:</strong> Stock por debajo del mínimo
                </div>
              )}
            </div>
          )}
        </div>

        {/* Acciones */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Acciones</h3>
          <div className="space-y-3">
            <button
              onClick={fetchExistencias}
              className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
            >
              Ver Existencias
            </button>
            {puedeGestionarProductos() && (
              <>
                {producto.estado.codigo === 'RETENIDO' ? (
                  <button
                    onClick={handleActivar}
                    className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700"
                  >
                    Activar Producto
                  </button>
                ) : (
                  <button
                    onClick={handleDesactivar}
                    className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700"
                  >
                    Desactivar Producto
                  </button>
                )}
              </>
            )}
            <button
              onClick={() => window.print()}
              className="w-full bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-700"
            >
              Imprimir
            </button>
          </div>
        </div>
      </div>

      {/* Existencias por ubicación */}
      {showExistencias && (
        <div className="bg-white rounded-lg shadow overflow-hidden mb-6">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold">Existencias por Ubicación</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ubicación
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Zona
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Lote
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Disponible
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Reservado
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Libre
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {existencias.map((existencia, index) => (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {existencia.ubicacion_codigo}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {existencia.zona}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {existencia.lote}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {existencia.cantidad_disponible}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {existencia.cantidad_reservada}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {existencia.cantidad_libre}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
          {existencias.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              No hay existencias registradas para este producto
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default ProductoDetalle;
