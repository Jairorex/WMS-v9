import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Ubicacion {
  id_ubicacion: number;
  codigo: string;
  pasillo: string;
  estanteria: string;
  nivel: string;
  capacidad: number;
  tipo: string;
  ocupada: boolean;
  tipo_ubicacion_id?: number;
  zona_id?: number;
  coordenada_x?: number;
  coordenada_y?: number;
  coordenada_z?: number;
  tipo_palet?: string;
  temperatura_min?: number;
  temperatura_max?: number;
  humedad_min?: number;
  humedad_max?: number;
  activo: boolean;
  tipoUbicacion?: {
    id: number;
    codigo: string;
    nombre: string;
  };
  zona?: {
    id: number;
    codigo: string;
    nombre: string;
  };
  inventario?: any[];
}

interface Catalogos {
  tipos: Array<{ codigo: string; nombre: string }>;
  tipos_ubicacion: Array<{ id: number; codigo: string; nombre: string }>;
  zonas: Array<{ id: number; codigo: string; nombre: string }>;
  pasillos: string[];
}

const Ubicaciones: React.FC = () => {
  const [ubicaciones, setUbicaciones] = useState<Ubicacion[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: '',
    tipo: '',
    pasillo: '',
    disponibles: false,
    ocupadas: false,
    tipo_ubicacion_id: '',
    zona_id: '',
    activas: false,
    con_coordenadas: false
  });
  const [showModal, setShowModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingUbicacion, setEditingUbicacion] = useState<Ubicacion | null>(null);
  const [formData, setFormData] = useState({
    codigo: '',
    pasillo: '',
    estanteria: '',
    nivel: '',
    capacidad: 0,
    tipo: '',
    tipo_ubicacion_id: '',
    zona_id: '',
    coordenada_x: '',
    coordenada_y: '',
    coordenada_z: '',
    tipo_palet: '',
    temperatura_min: '',
    temperatura_max: '',
    humedad_min: '',
    humedad_max: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchUbicaciones();
    fetchCatalogos();
  }, [filtros]);

  const fetchUbicaciones = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      const response = await http.get(`/api/ubicaciones?${params.toString()}`);
      setUbicaciones(response.data.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar ubicaciones');
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const response = await http.get('/api/ubicaciones-catalogos');
      setCatalogos(response.data);
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      setCatalogos({
        tipos: [],
        tipos_ubicacion: [],
        zonas: [],
        pasillos: []
      });
    }
  };

  const calcularOcupacion = (ubicacion: Ubicacion) => {
    if (!ubicacion.inventario) return { ocupacion: 0, porcentaje: 0 };
    
    let ocupacion = 0;
    if (Array.isArray(ubicacion.inventario)) {
      ocupacion = ubicacion.inventario.reduce((sum: number, item: any) => {
        if (item && typeof item === 'object' && 'cantidad' in item) {
          return sum + (Number(item.cantidad) || 0);
        }
        return sum;
      }, 0);
    } else if (typeof ubicacion.inventario === 'object' && ubicacion.inventario !== null && 'cantidad' in ubicacion.inventario) {
      ocupacion = Number((ubicacion.inventario as any).cantidad) || 0;
    }
    
    const porcentaje = ubicacion.capacidad > 0 ? (ocupacion / ubicacion.capacidad) * 100 : 0;
    return { ocupacion, porcentaje: Math.round(porcentaje) };
  };

  const handleCrearUbicacion = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    try {
      const dataToSend = {
        ...formData,
        capacidad: parseInt(formData.capacidad.toString()),
        coordenada_x: formData.coordenada_x ? parseFloat(formData.coordenada_x) : null,
        coordenada_y: formData.coordenada_y ? parseFloat(formData.coordenada_y) : null,
        coordenada_z: formData.coordenada_z ? parseFloat(formData.coordenada_z) : null,
        temperatura_min: formData.temperatura_min ? parseFloat(formData.temperatura_min) : null,
        temperatura_max: formData.temperatura_max ? parseFloat(formData.temperatura_max) : null,
        humedad_min: formData.humedad_min ? parseFloat(formData.humedad_min) : null,
        humedad_max: formData.humedad_max ? parseFloat(formData.humedad_max) : null,
        tipo_ubicacion_id: formData.tipo_ubicacion_id ? parseInt(formData.tipo_ubicacion_id) : null,
        zona_id: formData.zona_id ? parseInt(formData.zona_id) : null
      };
      
      await http.post('/api/ubicaciones', dataToSend);
      setShowModal(false);
      resetForm();
      fetchUbicaciones();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear ubicación');
    } finally {
      setSubmitting(false);
    }
  };

  const handleEditarUbicacion = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingUbicacion) return;
    
    setSubmitting(true);
    
    try {
      const dataToSend = {
        ...formData,
        capacidad: parseInt(formData.capacidad.toString()),
        coordenada_x: formData.coordenada_x ? parseFloat(formData.coordenada_x) : null,
        coordenada_y: formData.coordenada_y ? parseFloat(formData.coordenada_y) : null,
        coordenada_z: formData.coordenada_z ? parseFloat(formData.coordenada_z) : null,
        temperatura_min: formData.temperatura_min ? parseFloat(formData.temperatura_min) : null,
        temperatura_max: formData.temperatura_max ? parseFloat(formData.temperatura_max) : null,
        humedad_min: formData.humedad_min ? parseFloat(formData.humedad_min) : null,
        humedad_max: formData.humedad_max ? parseFloat(formData.humedad_max) : null,
        tipo_ubicacion_id: formData.tipo_ubicacion_id ? parseInt(formData.tipo_ubicacion_id) : null,
        zona_id: formData.zona_id ? parseInt(formData.zona_id) : null
      };
      
      await http.put(`/api/ubicaciones/${editingUbicacion.id_ubicacion}`, dataToSend);
      setShowEditModal(false);
      setEditingUbicacion(null);
      resetForm();
      fetchUbicaciones();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al actualizar ubicación');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      codigo: '',
      pasillo: '',
      estanteria: '',
      nivel: '',
      capacidad: 0,
      tipo: '',
      tipo_ubicacion_id: '',
      zona_id: '',
      coordenada_x: '',
      coordenada_y: '',
      coordenada_z: '',
      tipo_palet: '',
      temperatura_min: '',
      temperatura_max: '',
      humedad_min: '',
      humedad_max: ''
    });
  };

  const openEditModal = (ubicacion: Ubicacion) => {
    setEditingUbicacion(ubicacion);
    setFormData({
      codigo: ubicacion.codigo,
      pasillo: ubicacion.pasillo,
      estanteria: ubicacion.estanteria,
      nivel: ubicacion.nivel,
      capacidad: ubicacion.capacidad,
      tipo: ubicacion.tipo,
      tipo_ubicacion_id: ubicacion.tipo_ubicacion_id ? ubicacion.tipo_ubicacion_id.toString() : '',
      zona_id: ubicacion.zona_id ? ubicacion.zona_id.toString() : '',
      coordenada_x: ubicacion.coordenada_x ? ubicacion.coordenada_x.toString() : '',
      coordenada_y: ubicacion.coordenada_y ? ubicacion.coordenada_y.toString() : '',
      coordenada_z: ubicacion.coordenada_z ? ubicacion.coordenada_z.toString() : '',
      tipo_palet: ubicacion.tipo_palet || '',
      temperatura_min: ubicacion.temperatura_min ? ubicacion.temperatura_min.toString() : '',
      temperatura_max: ubicacion.temperatura_max ? ubicacion.temperatura_max.toString() : '',
      humedad_min: ubicacion.humedad_min ? ubicacion.humedad_min.toString() : '',
      humedad_max: ubicacion.humedad_max ? ubicacion.humedad_max.toString() : ''
    });
    setShowEditModal(true);
  };

  const handleVerDetalle = (id: number) => {
    navigate(`/ubicaciones/${id}`);
  };

  const handleActivar = async (id: number) => {
    try {
      await http.patch(`/api/ubicaciones/${id}/activar`);
      fetchUbicaciones();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al activar ubicación');
    }
  };

  const handleDesactivar = async (id: number) => {
    try {
      await http.patch(`/api/ubicaciones/${id}/desactivar`);
      fetchUbicaciones();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al desactivar ubicación');
    }
  };

  const getOcupacionColor = (porcentaje: number) => {
    if (porcentaje >= 90) return 'bg-red-100 text-red-800';
    if (porcentaje >= 70) return 'bg-yellow-100 text-yellow-800';
    return 'bg-green-100 text-green-800';
  };

  const puedeGestionarUbicaciones = () => {
    if (!user) return false;
    const esAdmin = user.rol_id === 1;
    return esAdmin;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando ubicaciones...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Gestión de Ubicaciones</h1>
        {puedeGestionarUbicaciones() && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
          >
            Nueva Ubicación
          </button>
        )}
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {/* Filtros */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <h3 className="text-lg font-semibold mb-4">Filtros</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Búsqueda
            </label>
            <input
              type="text"
              placeholder="Buscar por código, pasillo..."
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tipo de Ubicación
            </label>
            <select
              value={filtros.tipo_ubicacion_id}
              onChange={(e) => setFiltros({ ...filtros, tipo_ubicacion_id: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.tipos_ubicacion.map((tipo) => (
                <option key={tipo.id} value={tipo.id}>
                  {tipo.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Zona
            </label>
            <select
              value={filtros.zona_id}
              onChange={(e) => setFiltros({ ...filtros, zona_id: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todas</option>
              {catalogos?.zonas.map((zona) => (
                <option key={zona.id} value={zona.id}>
                  {zona.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Pasillo
            </label>
            <select
              value={filtros.pasillo}
              onChange={(e) => setFiltros({ ...filtros, pasillo: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.pasillos.map((pasillo) => (
                <option key={pasillo} value={pasillo}>
                  {pasillo}
                </option>
              ))}
            </select>
          </div>
        </div>
        
        <div className="mt-4 flex flex-wrap gap-4">
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.disponibles}
              onChange={(e) => setFiltros({ ...filtros, disponibles: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Solo disponibles</span>
          </label>
          
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.ocupadas}
              onChange={(e) => setFiltros({ ...filtros, ocupadas: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Solo ocupadas</span>
          </label>
          
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.con_coordenadas}
              onChange={(e) => setFiltros({ ...filtros, con_coordenadas: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Con coordenadas</span>
          </label>
          
          <button
            onClick={() => setFiltros({ 
              q: '', 
              tipo: '', 
              pasillo: '', 
              disponibles: false, 
              ocupadas: false,
              tipo_ubicacion_id: '',
              zona_id: '',
              activas: false,
              con_coordenadas: false
            })}
            className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>

      {/* Tabla de ubicaciones */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Código
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ubicación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Zona
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Capacidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ocupación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {ubicaciones.map((ubicacion) => {
                const { ocupacion, porcentaje } = calcularOcupacion(ubicacion);
                return (
                  <tr key={ubicacion.id_ubicacion} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {ubicacion.codigo}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      P{ubicacion.pasillo}-E{ubicacion.estanteria}-N{ubicacion.nivel}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {ubicacion.tipoUbicacion?.nombre || ubicacion.tipo}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {ubicacion.zona?.nombre || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {ubicacion.capacidad}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                          <div 
                            className={`h-2 rounded-full ${porcentaje >= 90 ? 'bg-red-500' : porcentaje >= 70 ? 'bg-yellow-500' : 'bg-green-500'}`}
                            style={{ width: `${Math.min(porcentaje, 100)}%` }}
                          ></div>
                        </div>
                        <span className={`text-xs font-semibold ${getOcupacionColor(porcentaje)}`}>
                          {ocupacion}/{ubicacion.capacidad} ({porcentaje}%)
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        ubicacion.ocupada ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'
                      }`}>
                        {ubicacion.ocupada ? 'Ocupada' : 'Disponible'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                      <button
                        onClick={() => handleVerDetalle(ubicacion.id_ubicacion)}
                        className="text-blue-600 hover:text-blue-900"
                      >
                        Detalle
                      </button>
                      {puedeGestionarUbicaciones() && (
                        <>
                          <button
                            onClick={() => openEditModal(ubicacion)}
                            className="text-orange-600 hover:text-orange-900"
                          >
                            Editar
                          </button>
                          {ubicacion.activo ? (
                            <button
                              onClick={() => handleDesactivar(ubicacion.id_ubicacion)}
                              className="text-red-600 hover:text-red-900"
                            >
                              Desactivar
                            </button>
                          ) : (
                            <button
                              onClick={() => handleActivar(ubicacion.id_ubicacion)}
                              className="text-green-600 hover:text-green-900"
                            >
                              Activar
                            </button>
                          )}
                        </>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        
        {ubicaciones.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No se encontraron ubicaciones con los filtros aplicados
          </div>
        )}
      </div>

      {/* Modal para crear ubicación */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Nueva Ubicación
              </h3>
              <form onSubmit={handleCrearUbicacion} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Código *
                    </label>
                    <input
                      type="text"
                      value={formData.codigo}
                      onChange={(e) => setFormData({ ...formData, codigo: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Pasillo *
                    </label>
                    <input
                      type="text"
                      value={formData.pasillo}
                      onChange={(e) => setFormData({ ...formData, pasillo: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Estantería *
                    </label>
                    <input
                      type="text"
                      value={formData.estanteria}
                      onChange={(e) => setFormData({ ...formData, estanteria: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Nivel *
                    </label>
                    <input
                      type="text"
                      value={formData.nivel}
                      onChange={(e) => setFormData({ ...formData, nivel: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Capacidad *
                    </label>
                    <input
                      type="number"
                      min="0"
                      value={formData.capacidad}
                      onChange={(e) => setFormData({ ...formData, capacidad: parseInt(e.target.value) || 0 })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tipo de Ubicación
                    </label>
                    <select
                      value={formData.tipo_ubicacion_id}
                      onChange={(e) => setFormData({ ...formData, tipo_ubicacion_id: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Seleccionar tipo</option>
                      {catalogos?.tipos_ubicacion.map((tipo) => (
                        <option key={tipo.id} value={tipo.id}>
                          {tipo.nombre}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Zona
                    </label>
                    <select
                      value={formData.zona_id}
                      onChange={(e) => setFormData({ ...formData, zona_id: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Seleccionar zona</option>
                      {catalogos?.zonas.map((zona) => (
                        <option key={zona.id} value={zona.id}>
                          {zona.nombre}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tipo de Palé
                    </label>
                    <input
                      type="text"
                      value={formData.tipo_palet}
                      onChange={(e) => setFormData({ ...formData, tipo_palet: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>
                
                <div className="border-t pt-4">
                  <h4 className="text-md font-medium text-gray-900 mb-3">Coordenadas</h4>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Coordenada X
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.coordenada_x}
                        onChange={(e) => setFormData({ ...formData, coordenada_x: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Coordenada Y
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.coordenada_y}
                        onChange={(e) => setFormData({ ...formData, coordenada_y: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Coordenada Z
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.coordenada_z}
                        onChange={(e) => setFormData({ ...formData, coordenada_z: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                  </div>
                </div>
                
                <div className="border-t pt-4">
                  <h4 className="text-md font-medium text-gray-900 mb-3">Condiciones Ambientales</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Temperatura Mínima (°C)
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.temperatura_min}
                        onChange={(e) => setFormData({ ...formData, temperatura_min: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Temperatura Máxima (°C)
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.temperatura_max}
                        onChange={(e) => setFormData({ ...formData, temperatura_max: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Humedad Mínima (%)
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.humedad_min}
                        onChange={(e) => setFormData({ ...formData, humedad_min: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Humedad Máxima (%)
                      </label>
                      <input
                        type="number"
                        step="0.01"
                        value={formData.humedad_max}
                        onChange={(e) => setFormData({ ...formData, humedad_max: e.target.value })}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                  </div>
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                  >
                    {submitting ? 'Creando...' : 'Crear Ubicación'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Modal para editar ubicación */}
      {showEditModal && editingUbicacion && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Editar Ubicación: {editingUbicacion.codigo}
              </h3>
              <form onSubmit={handleEditarUbicacion} className="space-y-4">
                {/* Mismo formulario que el modal de crear, pero con los datos prellenados */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Código *
                    </label>
                    <input
                      type="text"
                      value={formData.codigo}
                      onChange={(e) => setFormData({ ...formData, codigo: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Capacidad *
                    </label>
                    <input
                      type="number"
                      min="0"
                      value={formData.capacidad}
                      onChange={(e) => setFormData({ ...formData, capacidad: parseInt(e.target.value) || 0 })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tipo de Ubicación
                    </label>
                    <select
                      value={formData.tipo_ubicacion_id}
                      onChange={(e) => setFormData({ ...formData, tipo_ubicacion_id: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Seleccionar tipo</option>
                      {catalogos?.tipos_ubicacion.map((tipo) => (
                        <option key={tipo.id} value={tipo.id}>
                          {tipo.nombre}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Zona
                    </label>
                    <select
                      value={formData.zona_id}
                      onChange={(e) => setFormData({ ...formData, zona_id: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Seleccionar zona</option>
                      {catalogos?.zonas.map((zona) => (
                        <option key={zona.id} value={zona.id}>
                          {zona.nombre}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => {
                      setShowEditModal(false);
                      setEditingUbicacion(null);
                      resetForm();
                    }}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="px-4 py-2 text-sm font-medium text-white bg-orange-600 rounded-md hover:bg-orange-700 disabled:opacity-50"
                  >
                    {submitting ? 'Actualizando...' : 'Actualizar Ubicación'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Ubicaciones;