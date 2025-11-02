import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';

interface OrdenSalida {
  id_orden: number;
  estado: string;
  prioridad: number;
  cliente: string;
  fecha_compromiso: string;
  creado_por: number;
  creador?: {
    nombre: string;
  };
  detalles?: Array<{
    id_det: number;
    id_producto: number;
    cant_solicitada: number;
    cant_comprometida: number;
    cant_pickeada: number;
    lote_preferente?: string;
    producto?: {
      nombre: string;
      lote: string;
    };
  }>;
  pickings?: Array<{
    id_picking: number;
    estado: string;
  }>;
  created_at: string;
  updated_at: string;
}

interface Metricas {
  total_lineas: number;
  lineas_completas: number;
  porcentaje_completado: number;
  puede_asignar_picking: boolean;
  total_pickings: number;
}

const OrdenSalidaDetalle: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [orden, setOrden] = useState<OrdenSalida | null>(null);
  const [metricas, setMetricas] = useState<Metricas | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState('summary');

  useEffect(() => {
    if (id) {
      fetchOrdenDetalle();
    }
  }, [id]);

  const fetchOrdenDetalle = async () => {
    try {
      setLoading(true);
      const response = await http.get(`/api/ordenes-salida/${id}`);
      setOrden(response.data.orden);
      setMetricas(response.data.metricas);
    } catch (err: any) {
      setError('Error al cargar detalles de la orden');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleConfirmar = async () => {
    try {
      await http.patch(`/api/ordenes-salida/${id}/confirmar`);
      fetchOrdenDetalle();
    } catch (err: any) {
      setError('Error al confirmar orden');
      console.error(err);
    }
  };

  const handleCancelar = async () => {
    if (window.confirm('¿Está seguro de cancelar esta orden?')) {
      try {
        await http.patch(`/api/ordenes-salida/${id}/cancelar`);
        fetchOrdenDetalle();
      } catch (err: any) {
        setError('Error al cancelar orden');
        console.error(err);
      }
    }
  };

  const getEstadoColor = (estado: string) => {
    switch (estado) {
      case 'CREADA': return 'bg-blue-100 text-blue-800';
      case 'EN_PICKING': return 'bg-yellow-100 text-yellow-800';
      case 'PICKING_COMPLETO': return 'bg-green-100 text-green-800';
      case 'CANCELADA': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPrioridadColor = (prioridad: number) => {
    switch (prioridad) {
      case 1: return 'bg-gray-100 text-gray-800';
      case 2: return 'bg-blue-100 text-blue-800';
      case 3: return 'bg-yellow-100 text-yellow-800';
      case 4: return 'bg-orange-100 text-orange-800';
      case 5: return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPrioridadNombre = (prioridad: number) => {
    const nombres = ['', 'Muy Baja', 'Baja', 'Media', 'Alta', 'Crítica'];
    return nombres[prioridad] || `Prioridad ${prioridad}`;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error || !orden) {
    return (
      <div className="p-6">
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          {error || 'Orden no encontrada'}
        </div>
        <button
          onClick={() => navigate('/ordenes-salida')}
          className="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
        >
          Volver a Órdenes
        </button>
      </div>
    );
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="flex justify-between items-start mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Orden #{orden.id_orden}</h1>
          <p className="text-gray-600 mt-1">{orden.cliente}</p>
        </div>
        <div className="flex space-x-3">
          {orden.estado === 'CREADA' && (
            <>
              <button
                onClick={handleConfirmar}
                className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg"
              >
                Confirmar Orden
              </button>
              <button
                onClick={handleCancelar}
                className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg"
              >
                Cancelar
              </button>
            </>
          )}
          <button
            onClick={() => navigate('/ordenes-salida')}
            className="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg"
          >
            Volver
          </button>
        </div>
      </div>

      {/* Información general */}
      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Estado</label>
            <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getEstadoColor(orden.estado)}`}>
              {orden.estado}
            </span>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Prioridad</label>
            <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getPrioridadColor(orden.prioridad)}`}>
              {getPrioridadNombre(orden.prioridad)}
            </span>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Fecha Compromiso</label>
            <p className="text-sm text-gray-900">{new Date(orden.fecha_compromiso).toLocaleDateString()}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Creado por</label>
            <p className="text-sm text-gray-900">{orden.creador?.nombre || 'No disponible'}</p>
          </div>
        </div>

        {metricas && (
          <div className="mt-6 grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-blue-600">{metricas.total_lineas}</div>
              <div className="text-sm text-blue-800">Total Líneas</div>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-green-600">{metricas.lineas_completas}</div>
              <div className="text-sm text-green-800">Líneas Completas</div>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-yellow-600">{metricas.porcentaje_completado.toFixed(1)}%</div>
              <div className="text-sm text-yellow-800">Progreso</div>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <div className="text-2xl font-bold text-purple-600">{metricas.total_pickings}</div>
              <div className="text-sm text-purple-800">Pickings</div>
            </div>
          </div>
        )}
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 px-6">
            {[
              { id: 'summary', name: 'Resumen' },
              { id: 'lines', name: 'Líneas' },
              { id: 'coverage', name: 'Cobertura' },
              { id: 'history', name: 'Historial' }
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.name}
              </button>
            ))}
          </nav>
        </div>

        <div className="p-6">
          {/* Tab: Resumen */}
          {activeTab === 'summary' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Información de la Orden</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="font-medium text-gray-900 mb-2">Detalles Generales</h4>
                    <dl className="space-y-2">
                      <div className="flex justify-between">
                        <dt className="text-sm text-gray-500">ID Orden:</dt>
                        <dd className="text-sm text-gray-900">#{orden.id_orden}</dd>
                      </div>
                      <div className="flex justify-between">
                        <dt className="text-sm text-gray-500">Cliente:</dt>
                        <dd className="text-sm text-gray-900">{orden.cliente}</dd>
                      </div>
                      <div className="flex justify-between">
                        <dt className="text-sm text-gray-500">Fecha Compromiso:</dt>
                        <dd className="text-sm text-gray-900">{new Date(orden.fecha_compromiso).toLocaleDateString()}</dd>
                      </div>
                      <div className="flex justify-between">
                        <dt className="text-sm text-gray-500">Creado:</dt>
                        <dd className="text-sm text-gray-900">{new Date(orden.created_at).toLocaleString()}</dd>
                      </div>
                    </dl>
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900 mb-2">Estado y Prioridad</h4>
                    <dl className="space-y-2">
                      <div className="flex justify-between">
                        <dt className="text-sm text-gray-500">Estado:</dt>
                        <dd>
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(orden.estado)}`}>
                            {orden.estado}
                          </span>
                        </dd>
                      </div>
                      <div className="flex justify-between">
                        <dt className="text-sm text-gray-500">Prioridad:</dt>
                        <dd>
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrioridadColor(orden.prioridad)}`}>
                            {getPrioridadNombre(orden.prioridad)}
                          </span>
                        </dd>
                      </div>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Tab: Líneas */}
          {activeTab === 'lines' && (
            <div>
              <h3 className="text-lg font-medium text-gray-900 mb-4">Líneas de la Orden</h3>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Producto</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Lote Preferente</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Solicitado</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Comprometido</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Pickeado</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Progreso</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {orden.detalles?.map((detalle) => {
                      const progreso = detalle.cant_solicitada > 0 ? (detalle.cant_pickeada / detalle.cant_solicitada) * 100 : 0;
                      return (
                        <tr key={detalle.id_det}>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div>
                              <div className="text-sm font-medium text-gray-900">{detalle.producto?.nombre}</div>
                              <div className="text-sm text-gray-500">Lote: {detalle.producto?.lote}</div>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {detalle.lote_preferente || '-'}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {detalle.cant_solicitada}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {detalle.cant_comprometida}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {detalle.cant_pickeada}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <div className="w-full bg-gray-200 rounded-full h-2 mr-2">
                                <div
                                  className="bg-blue-600 h-2 rounded-full"
                                  style={{ width: `${Math.min(progreso, 100)}%` }}
                                ></div>
                              </div>
                              <span className="text-sm text-gray-600">{progreso.toFixed(1)}%</span>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* Tab: Cobertura */}
          {activeTab === 'coverage' && (
            <div>
              <h3 className="text-lg font-medium text-gray-900 mb-4">Cobertura de Stock</h3>
              <p className="text-gray-600 mb-4">Verificación de disponibilidad de stock para esta orden.</p>
              <button
                onClick={async () => {
                  try {
                    const response = await http.get(`/ordenes-salida/${id}/cobertura`);
                    // Aquí podrías mostrar los resultados en un modal o en la misma página
                    console.log('Cobertura:', response.data);
                  } catch (err) {
                    console.error('Error al obtener cobertura:', err);
                  }
                }}
                className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
              >
                Verificar Cobertura
              </button>
            </div>
          )}

          {/* Tab: Historial */}
          {activeTab === 'history' && (
            <div>
              <h3 className="text-lg font-medium text-gray-900 mb-4">Historial de Cambios</h3>
              <p className="text-gray-600">El historial de cambios se implementará en futuras versiones.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default OrdenSalidaDetalle;
