import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Lote {
  id: number;
  codigo_lote: string;
  producto_id: number;
  cantidad_inicial: number;
  cantidad_disponible: number;
  fecha_fabricacion: string;
  fecha_caducidad?: string;
  fecha_vencimiento?: string;
  proveedor?: string;
  numero_serie?: string;
  estado: string;
  observaciones?: string;
  activo: boolean;
  producto?: {
    id_producto: number;
    nombre: string;
    codigo_barra?: string;
  };
  inventario?: Array<{
    id_inventario: number;
    cantidad: number;
    ubicacion: {
      id_ubicacion: number;
      codigo: string;
    };
  }>;
}

interface Producto {
  id_producto: number;
  nombre: string;
  codigo_barra?: string;
}

const Lotes: React.FC = () => {
  const [lotes, setLotes] = useState<Lote[]>([]);
  const [productos, setProductos] = useState<Producto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: '',
    producto_id: '',
    estado: '',
    proveedor: '',
    caducados: false,
    por_caducar: false,
    activos: false
  });
  const [showModal, setShowModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingLote, setEditingLote] = useState<Lote | null>(null);
  const [formData, setFormData] = useState({
    codigo_lote: '',
    producto_id: '',
    cantidad_inicial: 0,
    cantidad_disponible: 0,
    fecha_fabricacion: '',
    fecha_caducidad: '',
    fecha_vencimiento: '',
    proveedor: '',
    numero_serie: '',
    estado: 'DISPONIBLE',
    observaciones: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchLotes();
    fetchProductos();
  }, [filtros]);

  const fetchLotes = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      const response = await http.get(`/api/lotes?${params.toString()}`);
      setLotes(response.data.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar lotes');
    } finally {
      setLoading(false);
    }
  };

  const fetchProductos = async () => {
    try {
      const response = await http.get('/api/productos');
      setProductos(response.data.data);
    } catch (err: any) {
      console.error('Error al cargar productos:', err);
    }
  };

  const handleCrearLote = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    try {
      const dataToSend = {
        ...formData,
        cantidad_inicial: parseFloat(formData.cantidad_inicial.toString()),
        cantidad_disponible: parseFloat(formData.cantidad_disponible.toString()),
        producto_id: parseInt(formData.producto_id),
        fecha_fabricacion: formData.fecha_fabricacion || null,
        fecha_caducidad: formData.fecha_caducidad || null,
        fecha_vencimiento: formData.fecha_vencimiento || null
      };
      
      await http.post('/api/lotes', dataToSend);
      setShowModal(false);
      resetForm();
      fetchLotes();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear lote');
    } finally {
      setSubmitting(false);
    }
  };

  const handleEditarLote = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingLote) return;
    
    setSubmitting(true);
    
    try {
      const dataToSend = {
        ...formData,
        cantidad_inicial: parseFloat(formData.cantidad_inicial.toString()),
        cantidad_disponible: parseFloat(formData.cantidad_disponible.toString()),
        producto_id: parseInt(formData.producto_id),
        fecha_fabricacion: formData.fecha_fabricacion || null,
        fecha_caducidad: formData.fecha_caducidad || null,
        fecha_vencimiento: formData.fecha_vencimiento || null
      };
      
      await http.put(`/api/lotes/${editingLote.id}`, dataToSend);
      setShowEditModal(false);
      setEditingLote(null);
      resetForm();
      fetchLotes();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al actualizar lote');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      codigo_lote: '',
      producto_id: '',
      cantidad_inicial: 0,
      cantidad_disponible: 0,
      fecha_fabricacion: '',
      fecha_caducidad: '',
      fecha_vencimiento: '',
      proveedor: '',
      numero_serie: '',
      estado: 'DISPONIBLE',
      observaciones: ''
    });
  };

  const openEditModal = (lote: Lote) => {
    setEditingLote(lote);
    setFormData({
      codigo_lote: lote.codigo_lote,
      producto_id: lote.producto_id.toString(),
      cantidad_inicial: lote.cantidad_inicial,
      cantidad_disponible: lote.cantidad_disponible,
      fecha_fabricacion: lote.fecha_fabricacion,
      fecha_caducidad: lote.fecha_caducidad || '',
      fecha_vencimiento: lote.fecha_vencimiento || '',
      proveedor: lote.proveedor || '',
      numero_serie: lote.numero_serie || '',
      estado: lote.estado,
      observaciones: lote.observaciones || ''
    });
    setShowEditModal(true);
  };

  const handleVerDetalle = (id: number) => {
    navigate(`/lotes/${id}`);
  };

  const handleAjustarCantidad = async (loteId: number, cantidad: number, motivo: string) => {
    try {
      await http.patch(`/api/lotes/${loteId}/ajustar-cantidad`, {
        cantidad,
        motivo
      });
      fetchLotes();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al ajustar cantidad');
    }
  };

  const handleCambiarEstado = async (loteId: number, nuevoEstado: string) => {
    try {
      await http.patch(`/api/lotes/${loteId}/cambiar-estado`, {
        estado: nuevoEstado
      });
      fetchLotes();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cambiar estado');
    }
  };

  const getEstadoColor = (estado: string) => {
    const colores = {
      'DISPONIBLE': 'bg-green-100 text-green-800',
      'RESERVADO': 'bg-yellow-100 text-yellow-800',
      'CADUCADO': 'bg-red-100 text-red-800',
      'RETIRADO': 'bg-gray-100 text-gray-800'
    };
    return colores[estado as keyof typeof colores] || 'bg-gray-100 text-gray-800';
  };

  const getDiasParaCaducar = (fechaCaducidad: string) => {
    if (!fechaCaducidad) return null;
    const hoy = new Date();
    const caducidad = new Date(fechaCaducidad);
    const diffTime = caducidad.getTime() - hoy.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const getCaducidadColor = (dias: number) => {
    if (dias < 0) return 'text-red-600 font-bold';
    if (dias <= 7) return 'text-red-500 font-semibold';
    if (dias <= 30) return 'text-yellow-600 font-semibold';
    return 'text-green-600';
  };

  const puedeGestionarLotes = () => {
    if (!user) return false;
    const esAdmin = user.rol_id === 1;
    return esAdmin;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando lotes...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Gestión de Lotes</h1>
        {puedeGestionarLotes() && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
          >
            Nuevo Lote
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
              placeholder="Buscar por código, proveedor..."
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
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
              {productos.map((producto) => (
                <option key={producto.id_producto} value={producto.id_producto}>
                  {producto.nombre}
                </option>
              ))}
            </select>
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
              <option value="">Todos</option>
              <option value="DISPONIBLE">Disponible</option>
              <option value="RESERVADO">Reservado</option>
              <option value="CADUCADO">Caducado</option>
              <option value="RETIRADO">Retirado</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Proveedor
            </label>
            <input
              type="text"
              placeholder="Filtrar por proveedor"
              value={filtros.proveedor}
              onChange={(e) => setFiltros({ ...filtros, proveedor: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>
        
        <div className="mt-4 flex flex-wrap gap-4">
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.caducados}
              onChange={(e) => setFiltros({ ...filtros, caducados: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Caducados</span>
          </label>
          
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.por_caducar}
              onChange={(e) => setFiltros({ ...filtros, por_caducar: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Por caducar (30 días)</span>
          </label>
          
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.activos}
              onChange={(e) => setFiltros({ ...filtros, activos: e.target.checked })}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <span className="ml-2 text-sm text-gray-700">Solo activos</span>
          </label>
          
          <button
            onClick={() => setFiltros({ 
              q: '', 
              producto_id: '', 
              estado: '', 
              proveedor: '',
              caducados: false,
              por_caducar: false,
              activos: false
            })}
            className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>

      {/* Tabla de lotes */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Código Lote
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Producto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cantidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha Fabricación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha Caducidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Proveedor
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
              {lotes.map((lote) => {
                const diasCaducidad = lote.fecha_caducidad ? getDiasParaCaducar(lote.fecha_caducidad) : null;
                return (
                  <tr key={lote.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {lote.codigo_lote}
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">
                        {lote.producto?.nombre || 'Producto no encontrado'}
                      </div>
                      {lote.producto?.codigo_barra && (
                        <div className="text-xs text-gray-500">
                          Código: {lote.producto.codigo_barra}
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <div>
                        <span className="font-semibold">{lote.cantidad_disponible}</span>
                        <span className="text-gray-500"> / {lote.cantidad_inicial}</span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                        <div 
                          className="bg-blue-600 h-2 rounded-full" 
                          style={{ width: `${(lote.cantidad_disponible / lote.cantidad_inicial) * 100}%` }}
                        ></div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {new Date(lote.fecha_fabricacion).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      {lote.fecha_caducidad ? (
                        <div>
                          <div className="text-gray-900">
                            {new Date(lote.fecha_caducidad).toLocaleDateString()}
                          </div>
                          {diasCaducidad !== null && (
                            <div className={`text-xs ${getCaducidadColor(diasCaducidad)}`}>
                              {diasCaducidad < 0 ? 'Caducado' : `${diasCaducidad} días`}
                            </div>
                          )}
                        </div>
                      ) : (
                        <span className="text-gray-500">Sin fecha</span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {lote.proveedor || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(lote.estado)}`}>
                        {lote.estado}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                      <button
                        onClick={() => handleVerDetalle(lote.id)}
                        className="text-blue-600 hover:text-blue-900"
                      >
                        Detalle
                      </button>
                      {puedeGestionarLotes() && (
                        <>
                          <button
                            onClick={() => openEditModal(lote)}
                            className="text-orange-600 hover:text-orange-900"
                          >
                            Editar
                          </button>
                          <button
                            onClick={() => {
                              const cantidad = prompt('Cantidad a ajustar (positiva para sumar, negativa para restar):');
                              const motivo = prompt('Motivo del ajuste:');
                              if (cantidad && motivo) {
                                handleAjustarCantidad(lote.id, parseFloat(cantidad), motivo);
                              }
                            }}
                            className="text-purple-600 hover:text-purple-900"
                          >
                            Ajustar
                          </button>
                          {lote.estado === 'DISPONIBLE' && (
                            <button
                              onClick={() => handleCambiarEstado(lote.id, 'RESERVADO')}
                              className="text-yellow-600 hover:text-yellow-900"
                            >
                              Reservar
                            </button>
                          )}
                          {lote.estado === 'RESERVADO' && (
                            <button
                              onClick={() => handleCambiarEstado(lote.id, 'DISPONIBLE')}
                              className="text-green-600 hover:text-green-900"
                            >
                              Liberar
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
        
        {lotes.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No se encontraron lotes con los filtros aplicados
          </div>
        )}
      </div>

      {/* Modal para crear lote */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Nuevo Lote
              </h3>
              <form onSubmit={handleCrearLote} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Código de Lote *
                    </label>
                    <input
                      type="text"
                      value={formData.codigo_lote}
                      onChange={(e) => setFormData({ ...formData, codigo_lote: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Producto *
                    </label>
                    <select
                      value={formData.producto_id}
                      onChange={(e) => setFormData({ ...formData, producto_id: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    >
                      <option value="">Seleccionar producto</option>
                      {productos.map((producto) => (
                        <option key={producto.id_producto} value={producto.id_producto}>
                          {producto.nombre}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Cantidad Inicial *
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      value={formData.cantidad_inicial}
                      onChange={(e) => setFormData({ ...formData, cantidad_inicial: parseFloat(e.target.value) || 0 })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Cantidad Disponible *
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      value={formData.cantidad_disponible}
                      onChange={(e) => setFormData({ ...formData, cantidad_disponible: parseFloat(e.target.value) || 0 })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Fecha de Fabricación *
                    </label>
                    <input
                      type="date"
                      value={formData.fecha_fabricacion}
                      onChange={(e) => setFormData({ ...formData, fecha_fabricacion: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Fecha de Caducidad
                    </label>
                    <input
                      type="date"
                      value={formData.fecha_caducidad}
                      onChange={(e) => setFormData({ ...formData, fecha_caducidad: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Fecha de Vencimiento
                    </label>
                    <input
                      type="date"
                      value={formData.fecha_vencimiento}
                      onChange={(e) => setFormData({ ...formData, fecha_vencimiento: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Proveedor
                    </label>
                    <input
                      type="text"
                      value={formData.proveedor}
                      onChange={(e) => setFormData({ ...formData, proveedor: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Número de Serie
                    </label>
                    <input
                      type="text"
                      value={formData.numero_serie}
                      onChange={(e) => setFormData({ ...formData, numero_serie: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Estado
                    </label>
                    <select
                      value={formData.estado}
                      onChange={(e) => setFormData({ ...formData, estado: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="DISPONIBLE">Disponible</option>
                      <option value="RESERVADO">Reservado</option>
                      <option value="CADUCADO">Caducado</option>
                      <option value="RETIRADO">Retirado</option>
                    </select>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Observaciones
                  </label>
                  <textarea
                    value={formData.observaciones}
                    onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                  />
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
                    {submitting ? 'Creando...' : 'Crear Lote'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Modal para editar lote */}
      {showEditModal && editingLote && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Editar Lote: {editingLote.codigo_lote}
              </h3>
              <form onSubmit={handleEditarLote} className="space-y-4">
                {/* Formulario similar al de crear, pero con datos prellenados */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Código de Lote *
                    </label>
                    <input
                      type="text"
                      value={formData.codigo_lote}
                      onChange={(e) => setFormData({ ...formData, codigo_lote: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Cantidad Disponible *
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      min="0"
                      value={formData.cantidad_disponible}
                      onChange={(e) => setFormData({ ...formData, cantidad_disponible: parseFloat(e.target.value) || 0 })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Estado
                    </label>
                    <select
                      value={formData.estado}
                      onChange={(e) => setFormData({ ...formData, estado: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="DISPONIBLE">Disponible</option>
                      <option value="RESERVADO">Reservado</option>
                      <option value="CADUCADO">Caducado</option>
                      <option value="RETIRADO">Retirado</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Proveedor
                    </label>
                    <input
                      type="text"
                      value={formData.proveedor}
                      onChange={(e) => setFormData({ ...formData, proveedor: e.target.value })}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Observaciones
                  </label>
                  <textarea
                    value={formData.observaciones}
                    onChange={(e) => setFormData({ ...formData, observaciones: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                  />
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => {
                      setShowEditModal(false);
                      setEditingLote(null);
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
                    {submitting ? 'Actualizando...' : 'Actualizar Lote'}
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

export default Lotes;
