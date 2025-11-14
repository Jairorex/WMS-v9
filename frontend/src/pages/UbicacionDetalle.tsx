import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface UbicacionDetalle {
  id_ubicacion: number;
  codigo: string;
  pasillo: string;
  estanteria: string;
  nivel: string;
  capacidad: number;
  tipo: string;
  ocupada: boolean;
  inventario: Array<{
    id_producto: number;
    cantidad_disponible: number;
    cantidad_reservada: number;
    producto: {
      nombre: string;
      lote: string;
    };
  }>;
}

interface Metricas {
  ocupacion: number;
  porcentaje_ocupacion: number;
  disponible: boolean;
  total_productos: number;
}

interface Inventario {
  id_producto: number;
  producto_nombre: string;
  lote: string;
  cantidad_disponible: number;
  cantidad_reservada: number;
  cantidad_libre: number;
}

const UbicacionDetalle: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const [ubicacion, setUbicacion] = useState<UbicacionDetalle | null>(null);
  const [metricas, setMetricas] = useState<Metricas | null>(null);
  const [inventario, setInventario] = useState<Inventario[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showInventario, setShowInventario] = useState(false);

  useEffect(() => {
    if (id) {
      fetchUbicacionDetalle();
    }
  }, [id]);

  const fetchUbicacionDetalle = async () => {
    try {
      setLoading(true);
      const response = await http.get(`/api/ubicaciones/${id}`);
      setUbicacion(response.data.ubicacion);
      setMetricas(response.data.metricas);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar ubicación');
    } finally {
      setLoading(false);
    }
  };

  const fetchInventario = async () => {
    try {
      const response = await http.get(`/api/ubicaciones/${id}/inventario`);
      setInventario(response.data.inventario);
      setShowInventario(true);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar inventario');
    }
  };

  const handleActivar = async () => {
    try {
      await http.patch(`/api/ubicaciones/${id}/activar`);
      fetchUbicacionDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al activar ubicación');
    }
  };

  const handleDesactivar = async () => {
    try {
      await http.patch(`/api/ubicaciones/${id}/desactivar`);
      fetchUbicacionDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al desactivar ubicación');
    }
  };

  const getTipoColor = (tipo: string) => {
    const colores = {
      'Almacen': 'bg-blue-100 text-blue-800',
      'Picking': 'bg-green-100 text-green-800',
      'Devoluciones': 'bg-orange-100 text-orange-800'
    };
    return colores[tipo as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const puedeGestionarUbicaciones = () => {
    if (!user) return false;
    const esAdmin = user.rol_id === 1;
    return esAdmin;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando detalles de la ubicación...</div>
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
          onClick={() => navigate('/ubicaciones')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Ubicaciones
        </button>
      </div>
    );
  }

  if (!ubicacion) {
    return (
      <div className="p-6">
        <div className="text-center py-8 text-gray-500">
          Ubicación no encontrada
        </div>
        <button
          onClick={() => navigate('/ubicaciones')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Ubicaciones
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
            {ubicacion.codigo}
          </h1>
          <p className="text-gray-600">
            {ubicacion.pasillo}-{ubicacion.estanteria}-{ubicacion.nivel}
          </p>
        </div>
        <button
          onClick={() => navigate('/ubicaciones')}
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
              <label className="text-sm font-medium text-gray-500">ID:</label>
              <p className="text-sm text-gray-900">#{ubicacion.id_ubicacion}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Código:</label>
              <p className="text-sm text-gray-900">{ubicacion.codigo}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Ubicación:</label>
              <p className="text-sm text-gray-900">
                Pasillo {ubicacion.pasillo}, Estantería {ubicacion.estanteria}, Nivel {ubicacion.nivel}
              </p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Tipo:</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getTipoColor(ubicacion.tipo)}`}>
                {ubicacion.tipo}
              </span>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Capacidad:</label>
              <p className="text-sm text-gray-900">{ubicacion.capacidad} unidades</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Estado:</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${ubicacion.ocupada ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'}`}>
                {ubicacion.ocupada ? 'Ocupada' : 'Disponible'}
              </span>
            </div>
          </div>
        </div>

        {/* Métricas de ocupación */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Métricas de Ocupación</h3>
          {metricas && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4 text-center">
                <div>
                  <div className="text-2xl font-bold text-blue-600">{metricas.ocupacion}</div>
                  <div className="text-sm text-gray-500">Ocupación</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-gray-600">{ubicacion.capacidad}</div>
                  <div className="text-sm text-gray-500">Capacidad</div>
                </div>
                <div className="col-span-2">
                  <div className="text-3xl font-bold text-green-600">
                    {metricas.porcentaje_ocupacion.toFixed(1)}%
                  </div>
                  <div className="text-sm text-gray-500">Porcentaje de Ocupación</div>
                </div>
              </div>
              
              {/* Barra de progreso */}
              <div className="w-full bg-gray-200 rounded-full h-4">
                <div 
                  className={`h-4 rounded-full ${metricas.porcentaje_ocupacion > 80 ? 'bg-red-500' : metricas.porcentaje_ocupacion > 60 ? 'bg-yellow-500' : 'bg-green-500'}`}
                  style={{ width: `${Math.min(metricas.porcentaje_ocupacion, 100)}%` }}
                ></div>
              </div>
              
              <div className="text-center">
                <div className="text-sm text-gray-600">
                  Total de productos: {metricas.total_productos}
                </div>
                <div className={`text-sm font-medium ${metricas.disponible ? 'text-green-600' : 'text-red-600'}`}>
                  {metricas.disponible ? '✓ Disponible para uso' : '⚠ No disponible'}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Acciones */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Acciones</h3>
          <div className="space-y-3">
            <button
              onClick={fetchInventario}
              className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
            >
              Ver Inventario
            </button>
            {puedeGestionarUbicaciones() && (
              <>
                {ubicacion.ocupada ? (
                  <button
                    onClick={handleActivar}
                    className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700"
                  >
                    Activar Ubicación
                  </button>
                ) : (
                  <button
                    onClick={handleDesactivar}
                    className="w-full bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700"
                  >
                    Desactivar Ubicación
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

      {/* Inventario en ubicación */}
      {showInventario && (
        <div className="bg-white rounded-lg shadow overflow-hidden mb-6">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold">Inventario en Ubicación</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Producto
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
                {inventario.map((item, index) => (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {item.producto_nombre}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.lote}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.cantidad_disponible}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.cantidad_reservada}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.cantidad_libre}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
          {inventario.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              No hay inventario registrado en esta ubicación
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default UbicacionDetalle;
