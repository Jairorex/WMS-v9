import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface TareaDetalle {
  id_tarea: number;
  tipo_tarea_id: number;
  estado_tarea_id: number;
  prioridad: string;
  descripcion: string;
  creado_por: number;
  fecha_creacion: string;
  fecha_cierre?: string;
  tipo: {
    id_tipo_tarea: number;
    codigo: string;
    nombre: string;
  };
  estado: {
    id_estado_tarea: number;
    codigo: string;
    nombre: string;
  };
  creador: {
    id_usuario: number;
    nombre: string;
  };
  usuarios: Array<{
    id_tarea: number;
    id_usuario: number;
    es_responsable: boolean;
    asignado_desde: string;
    asignado_hasta?: string;
    usuario: {
      id_usuario: number;
      nombre: string;
      usuario: string;
    };
  }>;
  detalles: Array<{
    id_detalle: number;
    id_producto: number;
    cantidad_solicitada: number;
    cantidad_confirmada: number;
    notas?: string;
    producto: {
      nombre: string;
    };
    ubicacionOrigen?: {
      codigo: string;
      descripcion: string;
    };
    ubicacionDestino?: {
      codigo: string;
      descripcion: string;
    };
  }>;
}

interface Metricas {
  porcentaje_avance: number;
  checklist_completo: boolean;
  total_detalles: number;
  detalles_completados: number;
}

interface Catalogos {
  tipos: Array<{ id_tipo_tarea: number; codigo: string; nombre: string }>;
  estados: Array<{ id_estado_tarea: number; codigo: string; nombre: string }>;
  prioridades: Array<{ codigo: string; nombre: string }>;
  usuarios: Array<{ id_usuario: number; nombre: string }>;
}

const TareaDetalle: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const [tarea, setTarea] = useState<TareaDetalle | null>(null);
  const [metricas, setMetricas] = useState<Metricas | null>(null);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showEstadoModal, setShowEstadoModal] = useState(false);
  const [showDetalleModal, setShowDetalleModal] = useState(false);
  const [showAsignarModal, setShowAsignarModal] = useState(false);
  const [selectedDetalle, setSelectedDetalle] = useState<any>(null);
  const [nuevoEstado, setNuevoEstado] = useState('');
  const [motivoCambio, setMotivoCambio] = useState('');
  const [cantidadConfirmada, setCantidadConfirmada] = useState(0);
  const [usuarioAsignar, setUsuarioAsignar] = useState('');
  const [esResponsable, setEsResponsable] = useState(false);

  useEffect(() => {
    if (id) {
      fetchTareaDetalle();
      fetchCatalogos();
    }
  }, [id]);

  const fetchTareaDetalle = async () => {
    try {
      setLoading(true);
      const response = await http.get(`/api/tareas/${id}`);
      setTarea(response.data.tarea);
      setMetricas(response.data.metricas);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar tarea');
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const [catalogosRes, usuariosRes] = await Promise.all([
        http.get('/api/tareas-catalogos'),
        http.get('/api/usuarios?activo=true&per_page=1000')
      ]);
      
      const usuarios = Array.isArray(usuariosRes.data.data) 
        ? usuariosRes.data.data 
        : Array.isArray(usuariosRes.data) 
          ? usuariosRes.data 
          : [];
      
      setCatalogos({
        ...catalogosRes.data,
        usuarios: usuarios.map((u: any) => ({
          id_usuario: u.id_usuario,
          nombre: u.nombre
        }))
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      setCatalogos({
        tipos: [],
        estados: [],
        prioridades: [],
        usuarios: []
      });
    }
  };

  const handleCambiarEstado = async () => {
    try {
      await http.patch(`/api/tareas/${id}/cambiar-estado`, {
        estado_tarea_id: nuevoEstado,
        motivo: motivoCambio
      });
      setShowEstadoModal(false);
      setNuevoEstado('');
      setMotivoCambio('');
      fetchTareaDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cambiar estado');
    }
  };

  const handleConfirmarCantidad = async () => {
    try {
      await http.put(`/api/tareas-detalle/${selectedDetalle.id_detalle}`, {
        cantidad_confirmada: cantidadConfirmada,
        notas: selectedDetalle.notas
      });
      setShowDetalleModal(false);
      setSelectedDetalle(null);
      setCantidadConfirmada(0);
      fetchTareaDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al confirmar cantidad');
    }
  };

  const handleAsignarUsuario = async () => {
    try {
      await http.post(`/api/tareas/${id}/asignar-usuario`, {
        id_usuario: usuarioAsignar,
        es_responsable: esResponsable
      });
      setShowAsignarModal(false);
      setUsuarioAsignar('');
      setEsResponsable(false);
      fetchTareaDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al asignar usuario');
    }
  };

  const getEstadoColor = (codigo: string) => {
    const colores = {
      'NUEVA': 'bg-gray-100 text-gray-800',
      'ASIGNADA': 'bg-yellow-100 text-yellow-800',
      'EN_PROCESO': 'bg-blue-100 text-blue-800',
      'PAUSADA': 'bg-orange-100 text-orange-800',
      'COMPLETADA': 'bg-green-100 text-green-800',
      'CANCELADA': 'bg-red-100 text-red-800',
      'VENCIDA': 'bg-purple-100 text-purple-800'
    };
    return colores[codigo as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const getPrioridadColor = (prioridad: string) => {
    const colores = {
      'Critica': 'bg-red-100 text-red-800',
      'Alta': 'bg-orange-100 text-orange-800',
      'Media': 'bg-blue-100 text-blue-800',
      'Baja': 'bg-gray-100 text-gray-800'
    };
    return colores[prioridad as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const puedeCambiarEstado = () => {
    if (!tarea || !user) return false;
    const esAdmin = user.rol_id === 1;
    const esSupervisor = user.rol_id === 2;
    return esAdmin || esSupervisor;
  };

  const puedeConfirmarDetalle = () => {
    if (!tarea || !user) return false;
    const esOperario = user.rol_id === 3;
    const esSupervisor = user.rol_id === 2;
    return esOperario || esSupervisor;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando detalles de la tarea...</div>
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
          onClick={() => navigate('/tareas')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Tareas
        </button>
      </div>
    );
  }

  if (!tarea) {
    return (
      <div className="p-6">
        <div className="text-center py-8 text-gray-500">
          Tarea no encontrada
        </div>
        <button
          onClick={() => navigate('/tareas')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Tareas
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
            Tarea #{tarea.id_tarea}
          </h1>
          <p className="text-gray-600">{tarea.tipo.nombre}</p>
        </div>
        <button
          onClick={() => navigate('/tareas')}
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
              <p className="text-sm text-gray-900">{tarea.descripcion}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Estado:</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(tarea.estado.codigo)}`}>
                {tarea.estado.nombre}
              </span>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Prioridad:</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrioridadColor(tarea.prioridad)}`}>
                {tarea.prioridad}
              </span>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Creado por:</label>
              <p className="text-sm text-gray-900">{tarea.creador.nombre}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Fecha creación:</label>
              <p className="text-sm text-gray-900">
                {new Date(tarea.fecha_creacion).toLocaleString()}
              </p>
            </div>
            {tarea.fecha_cierre && (
              <div>
                <label className="text-sm font-medium text-gray-500">Fecha cierre:</label>
                <p className="text-sm text-gray-900">
                  {new Date(tarea.fecha_cierre).toLocaleString()}
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Métricas */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Progreso</h3>
          {metricas && (
            <div className="space-y-4">
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span>Progreso General</span>
                  <span>{metricas.porcentaje_avance.toFixed(1)}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full"
                    style={{ width: `${metricas.porcentaje_avance}%` }}
                  ></div>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4 text-center">
                <div>
                  <div className="text-2xl font-bold text-blue-600">{metricas.detalles_completados}</div>
                  <div className="text-sm text-gray-500">Completados</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-gray-600">{metricas.total_detalles}</div>
                  <div className="text-sm text-gray-500">Total</div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Acciones */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Acciones</h3>
          <div className="space-y-3">
            {puedeCambiarEstado() && (
              <button
                onClick={() => setShowEstadoModal(true)}
                className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
              >
                Cambiar Estado
              </button>
            )}
            {puedeCambiarEstado() && (
              <button
                onClick={() => setShowAsignarModal(true)}
                className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700"
              >
                Asignar Usuario
              </button>
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

      {/* Usuarios asignados */}
      {tarea.usuarios && tarea.usuarios.length > 0 && (
        <div className="bg-white rounded-lg shadow overflow-hidden mb-6">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold">Usuarios Asignados</h3>
          </div>
          <div className="p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {tarea.usuarios.map((asignacion) => (
                <div key={`${asignacion.id_tarea}-${asignacion.id_usuario}`} className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="font-medium">{asignacion.usuario.nombre}</h4>
                    {asignacion.es_responsable && (
                      <span className="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded-full">
                        Responsable
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-gray-600">{asignacion.usuario.usuario}</p>
                  <p className="text-xs text-gray-500 mt-1">
                    Asignado: {new Date(asignacion.asignado_desde).toLocaleDateString()}
                  </p>
                  {asignacion.asignado_hasta && (
                    <p className="text-xs text-gray-500">
                      Hasta: {new Date(asignacion.asignado_hasta).toLocaleDateString()}
                    </p>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Detalles de la tarea */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold">Detalles de la Tarea</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Producto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ubicación Origen
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ubicación Destino
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Solicitado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Confirmado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Progreso
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {tarea.detalles.map((detalle) => (
                <tr key={detalle.id_detalle} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {detalle.producto.nombre}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {detalle.ubicacionOrigen?.codigo || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {detalle.ubicacionDestino?.codigo || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {detalle.cantidad_solicitada}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {detalle.cantidad_confirmada}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                        <div
                          className="bg-green-600 h-2 rounded-full"
                          style={{
                            width: `${(detalle.cantidad_confirmada / detalle.cantidad_solicitada) * 100}%`
                          }}
                        ></div>
                      </div>
                      <span className="text-xs text-gray-500">
                        {((detalle.cantidad_confirmada / detalle.cantidad_solicitada) * 100).toFixed(0)}%
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    {puedeConfirmarDetalle() && (
                      <button
                        onClick={() => {
                          setSelectedDetalle(detalle);
                          setCantidadConfirmada(detalle.cantidad_confirmada);
                          setShowDetalleModal(true);
                        }}
                        className="text-blue-600 hover:text-blue-900"
                      >
                        Confirmar
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal para cambiar estado */}
      {showEstadoModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Cambiar Estado
              </h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Nuevo Estado
                  </label>
                  <select
                    value={nuevoEstado}
                    onChange={(e) => setNuevoEstado(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar estado</option>
                    {catalogos?.estados.map((estado) => (
                      <option key={estado.id_estado_tarea} value={estado.id_estado_tarea}>
                        {estado.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Motivo (opcional)
                  </label>
                  <textarea
                    value={motivoCambio}
                    onChange={(e) => setMotivoCambio(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                  />
                </div>
              </div>
              <div className="flex justify-end space-x-3 pt-4">
                <button
                  onClick={() => setShowEstadoModal(false)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                >
                  Cancelar
                </button>
                <button
                  onClick={handleCambiarEstado}
                  disabled={!nuevoEstado}
                  className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  Cambiar Estado
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal para confirmar detalle */}
      {showDetalleModal && selectedDetalle && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Confirmar Cantidad
              </h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Producto
                  </label>
                  <p className="text-sm text-gray-900">{selectedDetalle.producto.nombre}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Cantidad Solicitada
                  </label>
                  <p className="text-sm text-gray-900">{selectedDetalle.cantidad_solicitada}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Cantidad Confirmada
                  </label>
                  <input
                    type="number"
                    min="0"
                    max={selectedDetalle.cantidad_solicitada}
                    value={cantidadConfirmada}
                    onChange={(e) => setCantidadConfirmada(parseInt(e.target.value) || 0)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
              <div className="flex justify-end space-x-3 pt-4">
                <button
                  onClick={() => setShowDetalleModal(false)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                >
                  Cancelar
                </button>
                <button
                  onClick={handleConfirmarCantidad}
                  className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
                >
                  Confirmar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal para asignar usuario */}
      {showAsignarModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Asignar Usuario
              </h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Usuario
                  </label>
                  <select
                    value={usuarioAsignar}
                    onChange={(e) => setUsuarioAsignar(e.target.value)}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar usuario</option>
                    {catalogos?.usuarios && Array.isArray(catalogos.usuarios) && catalogos.usuarios.map((usuario: { id_usuario: number; nombre: string }) => (
                      <option key={usuario.id_usuario} value={usuario.id_usuario}>
                        {usuario.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={esResponsable}
                      onChange={(e) => setEsResponsable(e.target.checked)}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <span className="ml-2 text-sm text-gray-700">Es responsable</span>
                  </label>
                </div>
              </div>
              <div className="flex justify-end space-x-3 pt-4">
                <button
                  onClick={() => setShowAsignarModal(false)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                >
                  Cancelar
                </button>
                <button
                  onClick={handleAsignarUsuario}
                  disabled={!usuarioAsignar}
                  className="px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700 disabled:opacity-50"
                >
                  Asignar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TareaDetalle;
