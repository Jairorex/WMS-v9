import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface IncidenciaDetalle {
  id_incidencia: number;
  id_tarea?: number;
  id_operario: number;
  id_producto: number;
  descripcion: string;
  estado: string;
  fecha_reporte: string;
  fecha_resolucion?: string;
  tarea?: {
    id_tarea: number;
    descripcion: string;
  };
  operario: {
    id_usuario: number;
    nombre: string;
  };
  producto: {
    id_producto: number;
    nombre: string;
    lote: string;
  };
}

const IncidenciaDetalle: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const [incidencia, setIncidencia] = useState<IncidenciaDetalle | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (id) {
      fetchIncidenciaDetalle();
    }
  }, [id]);

  const fetchIncidenciaDetalle = async () => {
    try {
      setLoading(true);
      const response = await http.get(`/api/incidencias/${id}`);
      setIncidencia(response.data.incidencia);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar incidencia');
    } finally {
      setLoading(false);
    }
  };

  const handleResolver = async () => {
    try {
      await http.patch(`/api/incidencias/${id}/resolver`);
      fetchIncidenciaDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al resolver incidencia');
    }
  };

  const handleReabrir = async () => {
    try {
      await http.patch(`/api/incidencias/${id}/reabrir`);
      fetchIncidenciaDetalle();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al reabrir incidencia');
    }
  };

  const getEstadoColor = (estado: string) => {
    const colores = {
      'Pendiente': 'bg-yellow-100 text-yellow-800',
      'Resuelta': 'bg-green-100 text-green-800'
    };
    return colores[estado as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const puedeGestionarIncidencias = () => {
    if (!user) return false;
    const esAdmin = user.rol_id === 1;
    const esSupervisor = user.rol_id === 2;
    return esAdmin || esSupervisor;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando detalles de la incidencia...</div>
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
          onClick={() => navigate('/incidencias')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Incidencias
        </button>
      </div>
    );
  }

  if (!incidencia) {
    return (
      <div className="p-6">
        <div className="text-center py-8 text-gray-500">
          Incidencia no encontrada
        </div>
        <button
          onClick={() => navigate('/incidencias')}
          className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
        >
          Volver a Incidencias
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
            Incidencia #{incidencia.id_incidencia}
          </h1>
          <p className="text-gray-600">
            Reportada el {new Date(incidencia.fecha_reporte).toLocaleDateString()}
          </p>
        </div>
        <button
          onClick={() => navigate('/incidencias')}
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
              <p className="text-sm text-gray-900">#{incidencia.id_incidencia}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Estado:</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(incidencia.estado)}`}>
                {incidencia.estado}
              </span>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Operario:</label>
              <p className="text-sm text-gray-900">{incidencia.operario.nombre}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Producto:</label>
              <p className="text-sm text-gray-900">{incidencia.producto.nombre}</p>
              <p className="text-xs text-gray-500">Lote: {incidencia.producto.lote}</p>
            </div>
            {incidencia.tarea && (
              <div>
                <label className="text-sm font-medium text-gray-500">Tarea Asociada:</label>
                <p className="text-sm text-gray-900">{incidencia.tarea.descripcion}</p>
              </div>
            )}
            <div>
              <label className="text-sm font-medium text-gray-500">Fecha de Reporte:</label>
              <p className="text-sm text-gray-900">
                {new Date(incidencia.fecha_reporte).toLocaleString()}
              </p>
            </div>
            {incidencia.fecha_resolucion && (
              <div>
                <label className="text-sm font-medium text-gray-500">Fecha de Resolución:</label>
                <p className="text-sm text-gray-900">
                  {new Date(incidencia.fecha_resolucion).toLocaleString()}
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Descripción */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Descripción</h3>
          <div className="bg-gray-50 p-4 rounded-md">
            <p className="text-sm text-gray-900 whitespace-pre-wrap">
              {incidencia.descripcion}
            </p>
          </div>
        </div>

        {/* Acciones */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Acciones</h3>
          <div className="space-y-3">
            {puedeGestionarIncidencias() && (
              <>
                {incidencia.estado === 'Pendiente' ? (
                  <button
                    onClick={handleResolver}
                    className="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700"
                  >
                    Resolver Incidencia
                  </button>
                ) : (
                  <button
                    onClick={handleReabrir}
                    className="w-full bg-orange-600 text-white px-4 py-2 rounded-md hover:bg-orange-700"
                  >
                    Reabrir Incidencia
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

      {/* Timeline de eventos */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold">Timeline de Eventos</h3>
        </div>
        <div className="p-6">
          <div className="flow-root">
            <ul className="-mb-8">
              <li>
                <div className="relative pb-8">
                  <span className="absolute top-4 left-4 -ml-px h-full w-0.5 bg-gray-200" aria-hidden="true"></span>
                  <div className="relative flex space-x-3">
                    <div>
                      <span className="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center ring-8 ring-white">
                        <svg className="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                          <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                        </svg>
                      </span>
                    </div>
                    <div className="min-w-0 flex-1 pt-1.5 flex justify-between space-x-4">
                      <div>
                        <p className="text-sm text-gray-500">
                          Incidencia reportada por <span className="font-medium text-gray-900">{incidencia.operario.nombre}</span>
                        </p>
                      </div>
                      <div className="text-right text-sm whitespace-nowrap text-gray-500">
                        <time dateTime={incidencia.fecha_reporte}>
                          {new Date(incidencia.fecha_reporte).toLocaleString()}
                        </time>
                      </div>
                    </div>
                  </div>
                </div>
              </li>
              
              {incidencia.fecha_resolucion && (
                <li>
                  <div className="relative pb-8">
                    <div className="relative flex space-x-3">
                      <div>
                        <span className="h-8 w-8 rounded-full bg-green-500 flex items-center justify-center ring-8 ring-white">
                          <svg className="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                          </svg>
                        </span>
                      </div>
                      <div className="min-w-0 flex-1 pt-1.5 flex justify-between space-x-4">
                        <div>
                          <p className="text-sm text-gray-500">
                            Incidencia resuelta
                          </p>
                        </div>
                        <div className="text-right text-sm whitespace-nowrap text-gray-500">
                          <time dateTime={incidencia.fecha_resolucion}>
                            {new Date(incidencia.fecha_resolucion).toLocaleString()}
                          </time>
                        </div>
                      </div>
                    </div>
                  </div>
                </li>
              )}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default IncidenciaDetalle;
