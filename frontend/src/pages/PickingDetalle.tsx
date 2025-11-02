import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Picking {
  id_picking: number;
  id_orden: number;
  estado: string;
  asignado_a?: number;
  creado_por: number;
  ts_asignado?: string;
  ts_cierre?: string;
  orden: {
    id_orden: number;
    cliente: string;
    fecha_compromiso: string;
    prioridad: number;
  };
  asignadoA?: {
    id_usuario: number;
    nombre: string;
    usuario: string;
  };
  detalles?: Array<{
    id_picking_det: number;
    id_producto: number;
    id_ubicacion: number;
    cantidad_solicitada: number;
    cantidad_confirmada: number;
    estado?: string;
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
  }>;
}

interface Catalogos {
  usuarios: Array<{ id_usuario: number; nombre: string; usuario: string }>;
}

const PickingDetalle: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [picking, setPicking] = useState<Picking | null>(null);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actualizandoCantidad, setActualizandoCantidad] = useState<number | null>(null);

  useEffect(() => {
    if (id) {
      fetchPickingDetalle();
      fetchCatalogos();
    }
  }, [id]);

  const fetchPickingDetalle = async () => {
    try {
      setLoading(true);
      const response = await http.get(`/api/picking/${id}`);
      setPicking(response.data.data || response.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar detalles del picking');
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const response = await http.get('/api/usuarios?activo=true&per_page=1000');
      const usuarios = Array.isArray(response.data.data) 
        ? response.data.data 
        : Array.isArray(response.data) 
          ? response.data 
          : [];
      setCatalogos({ usuarios: usuarios });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      setCatalogos({ usuarios: [] });
    }
  };

  const handleAsignar = async (usuarioId: number) => {
    try {
      await http.patch(`/api/picking/${id}/asignar`, { usuario_id: usuarioId });
      fetchPickingDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al asignar picking');
    }
  };

  const handleActualizarCantidad = async (detalleId: number, cantidad: number) => {
    try {
      setActualizandoCantidad(detalleId);
      // Actualizar el picking completo con los detalles modificados
      if (picking) {
        // Actualizar solo el detalle específico usando el modelo PickingDetalle
        await http.put(`/api/picking/${id}`, {
          detalles: picking.detalles?.map(d => 
            d.id_picking_det === detalleId 
              ? { ...d, cantidad_confirmada: cantidad }
              : d
          )
        });
        fetchPickingDetalle();
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al actualizar cantidad');
    } finally {
      setActualizandoCantidad(null);
    }
  };

  const handleCompletarDetalle = async (detalleId: number) => {
    try {
      const detalle = picking?.detalles?.find(d => d.id_picking_det === detalleId);
      if (detalle && picking) {
        await http.put(`/api/picking/${id}`, {
          detalles: picking.detalles?.map(d => 
            d.id_picking_det === detalleId 
              ? { ...d, cantidad_confirmada: detalle.cantidad_solicitada }
              : d
          )
        });
        fetchPickingDetalle();
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al completar detalle');
    }
  };

  const handleCompletarPicking = async () => {
    if (window.confirm('¿Está seguro de marcar este picking como completado?')) {
      try {
        await http.patch(`/api/picking/${id}/completar`);
        fetchPickingDetalle();
      } catch (err: any) {
        setError(err.response?.data?.message || 'Error al completar picking');
      }
    }
  };

  const handleCancelarPicking = async () => {
    if (window.confirm('¿Está seguro de cancelar este picking?')) {
      try {
        await http.patch(`/api/picking/${id}/cancelar`);
        navigate('/picking');
      } catch (err: any) {
        setError(err.response?.data?.message || 'Error al cancelar picking');
      }
    }
  };

  const getEstadoColor = (estado: string) => {
    const colores: { [key: string]: string } = {
      'ASIGNADO': 'bg-yellow-100 text-yellow-800 border-yellow-200',
      'EN_PROCESO': 'bg-blue-100 text-blue-800 border-blue-200',
      'PAUSADO': 'bg-orange-100 text-orange-800 border-orange-200',
      'COMPLETADO': 'bg-green-100 text-green-800 border-green-200',
      'CANCELADO': 'bg-red-100 text-red-800 border-red-200',
      'Pendiente': 'bg-gray-100 text-gray-800 border-gray-200',
      'En Proceso': 'bg-blue-100 text-blue-800 border-blue-200',
      'Completado': 'bg-green-100 text-green-800 border-green-200',
      'Cancelado': 'bg-red-100 text-red-800 border-red-200'
    };
    return colores[estado] || 'bg-gray-100 text-gray-800 border-gray-200';
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
    const nombres: { [key: number]: string } = {
      1: 'Muy Baja',
      2: 'Baja',
      3: 'Media',
      4: 'Alta',
      5: 'Urgente'
    };
    return nombres[prioridad] || `Prioridad ${prioridad}`;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando detalles del picking...</div>
      </div>
    );
  }

  if (error && !picking) {
    return (
      <div className="p-6">
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
        <button
          onClick={() => navigate('/picking')}
          className="text-blue-600 hover:text-blue-800"
        >
          Volver a Picking
        </button>
      </div>
    );
  }

  if (!picking) {
    return (
      <div className="p-6">
        <div className="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded mb-4">
          Picking no encontrado
        </div>
        <button
          onClick={() => navigate('/picking')}
          className="text-blue-600 hover:text-blue-800"
        >
          Volver a Picking
        </button>
      </div>
    );
  }

  const progresoTotal = picking.detalles && picking.detalles.length > 0
    ? Math.round((picking.detalles.reduce((sum, d) => sum + (d.cantidad_confirmada || 0), 0) / 
                  picking.detalles.reduce((sum, d) => sum + d.cantidad_solicitada, 0)) * 100)
    : 0;

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <button
            onClick={() => navigate('/picking')}
            className="text-blue-600 hover:text-blue-800 mb-2"
          >
            ← Volver a Picking
          </button>
          <h1 className="text-3xl font-bold text-gray-900">Detalle de Picking</h1>
          <p className="text-gray-600 mt-1">Picking #{picking.id_picking}</p>
        </div>
        <div className="flex gap-2">
          {picking.estado !== 'COMPLETADO' && picking.estado !== 'Completado' && 
           picking.estado !== 'CANCELADO' && picking.estado !== 'Cancelado' && (
            <>
              {picking.detalles?.every(d => (d.cantidad_confirmada || 0) >= d.cantidad_solicitada) && (
                <button
                  onClick={handleCompletarPicking}
                  className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
                >
                  Completar Picking
                </button>
              )}
              {(user?.rol_id === 1 || user?.rol_id === '1' || user?.rol_id === 2 || user?.rol_id === '2') && (
                <button
                  onClick={handleCancelarPicking}
                  className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
                >
                  Cancelar
                </button>
              )}
            </>
          )}
        </div>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {/* Información General */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Estado</div>
          <div className="mt-1">
            <span className={`inline-flex px-3 py-1 text-sm font-medium rounded-full border ${getEstadoColor(picking.estado)}`}>
              {picking.estado}
            </span>
          </div>
        </div>

        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Asignado a</div>
          <div className="mt-1 text-lg font-semibold text-gray-900">
            {picking.asignadoA?.nombre || 'Sin asignar'}
          </div>
          {!picking.asignado_a && (user?.rol_id === 1 || user?.rol_id === '1' || user?.rol_id === 2 || user?.rol_id === '2') && (
            <select
              onChange={(e) => handleAsignar(parseInt(e.target.value))}
              className="mt-2 w-full px-3 py-2 border border-gray-300 rounded-md text-sm"
            >
              <option value="">Asignar a...</option>
              {Array.isArray(catalogos?.usuarios) && catalogos.usuarios.map(usuario => (
                <option key={usuario.id_usuario} value={usuario.id_usuario}>
                  {usuario.nombre}
                </option>
              ))}
            </select>
          )}
        </div>

        <div className="bg-white p-4 rounded-lg shadow border border-gray-200">
          <div className="text-sm text-gray-600">Progreso</div>
          <div className="mt-1">
            <div className="w-full bg-gray-200 rounded-full h-4">
              <div 
                className="bg-blue-600 h-4 rounded-full transition-all"
                style={{ width: `${progresoTotal}%` }}
              ></div>
            </div>
            <div className="mt-1 text-sm text-gray-600">{progresoTotal}% completado</div>
          </div>
        </div>
      </div>

      {/* Información de la Orden */}
      <div className="bg-white rounded-lg shadow mb-6 border border-gray-200 p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Información de la Orden</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Orden #</label>
            <p className="text-sm font-medium text-gray-900">{picking.orden.id_orden}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Cliente</label>
            <p className="text-sm font-medium text-gray-900">{picking.orden.cliente}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Fecha Compromiso</label>
            <p className="text-sm font-medium text-gray-900">
              {new Date(picking.orden.fecha_compromiso).toLocaleDateString()}
            </p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500 mb-1">Prioridad</label>
            <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrioridadColor(picking.orden.prioridad)}`}>
              {getPrioridadNombre(picking.orden.prioridad)}
            </span>
          </div>
        </div>
      </div>

      {/* Detalles del Picking */}
      <div className="bg-white rounded-lg shadow border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-xl font-bold text-gray-900">Detalles del Picking</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ubicación</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Lote</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Objetivo</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pickeado</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pendiente</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {picking.detalles && picking.detalles.length > 0 ? (
                picking.detalles.map((detalle) => {
                  const pendiente = detalle.cantidad_solicitada - (detalle.cantidad_confirmada || 0);
                  const completado = (detalle.cantidad_confirmada || 0) >= detalle.cantidad_solicitada;
                  
                  return (
                    <tr key={detalle.id_picking_det} className={completado ? 'bg-green-50' : 'hover:bg-gray-50'}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {detalle.producto?.nombre || 'Producto no disponible'}
                        </div>
                        {detalle.producto?.codigo_barra && (
                          <div className="text-sm text-gray-500">
                            {detalle.producto.codigo_barra}
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {detalle.ubicacion?.codigo || 'No disponible'}
                        {detalle.ubicacion?.pasillo && (
                          <div className="text-xs text-gray-500">
                            P{detalle.ubicacion.pasillo}-E{detalle.ubicacion.estanteria}-N{detalle.ubicacion.nivel}
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        -
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {detalle.cantidad_solicitada}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <input
                          type="number"
                          min="0"
                          max={detalle.cantidad_solicitada}
                          value={detalle.cantidad_confirmada || 0}
                          onChange={(e) => {
                            const nuevaCantidad = parseInt(e.target.value) || 0;
                            if (nuevaCantidad <= detalle.cantidad_solicitada && nuevaCantidad >= 0) {
                              handleActualizarCantidad(detalle.id_picking_det, nuevaCantidad);
                            }
                          }}
                          disabled={actualizandoCantidad === detalle.id_picking_det || completado}
                          className={`w-20 px-2 py-1 border rounded text-sm ${
                            completado 
                              ? 'bg-green-100 border-green-300 text-green-800' 
                              : 'border-gray-300'
                          }`}
                        />
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`text-sm font-medium ${
                          pendiente === 0 ? 'text-green-600' : pendiente > 0 ? 'text-yellow-600' : 'text-red-600'
                        }`}>
                          {pendiente}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        {!completado && (
                          <button
                            onClick={() => handleCompletarDetalle(detalle.id_picking_det)}
                            className="text-blue-600 hover:text-blue-800"
                            disabled={actualizandoCantidad === detalle.id_picking_det}
                          >
                            Completar
                          </button>
                        )}
                        {completado && (
                          <span className="text-green-600 font-semibold">✓ Completado</span>
                        )}
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-gray-500">
                    No hay detalles de picking
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default PickingDetalle;

