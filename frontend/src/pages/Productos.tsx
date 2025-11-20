import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Producto {
  id_producto: number;
  nombre: string;
  descripcion?: string;
  codigo_barra?: string;
  lote: string;
  estado_producto_id: number;
  fecha_caducidad?: string;
  unidad_medida: string;
  unidad_medida_id?: number;
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
}

interface Catalogos {
  estados: Array<{ id_estado_producto: number; codigo: string; nombre: string }>;
  unidades_medida: Array<{ id: number; codigo: string; nombre: string }>;
}

const Productos: React.FC = () => {
  const [productos, setProductos] = useState<Producto[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: '',
    estado: '',
    unidad_medida: '',
    stock_minimo: false
  });
  const [showModal, setShowModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [selectedProducto, setSelectedProducto] = useState<Producto | null>(null);
  const [editingProducto, setEditingProducto] = useState<Producto | null>(null);
  const [formData, setFormData] = useState({
    nombre: '',
    descripcion: '',
    codigo_barra: '',
    lote: '',
    estado_producto_id: '',
    fecha_caducidad: '',
    unidad_medida_id: '',
    stock_minimo: 0,
    precio: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchProductos();
    fetchCatalogos();
  }, [filtros]);

  const fetchProductos = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value) params.append(key, value.toString());
      });

      const response = await http.get(`/api/productos?${params.toString()}`);
      setProductos(response.data.data);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al cargar productos');
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const [estadosResponse, unidadesResponse] = await Promise.all([
        http.get('/api/estados-producto'),
        http.get('/api/unidades-medida-catalogos')
      ]);
      
      setCatalogos({
        estados: estadosResponse.data.data || [],
        unidades_medida: unidadesResponse.data || []
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      // Establecer valores por defecto en caso de error
      setCatalogos({
        estados: [],
        unidades_medida: []
      });
    }
  };

  const handleCrearProducto = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(''); // Limpiar errores anteriores
    
    try {
      const dataToSend = {
        nombre: formData.nombre,
        descripcion: formData.descripcion || null,
        codigo_barra: formData.codigo_barra || null,
        lote: formData.lote,
        estado_producto_id: parseInt(formData.estado_producto_id),
        fecha_caducidad: formData.fecha_caducidad || null,
        unidad_medida_id: formData.unidad_medida_id ? parseInt(formData.unidad_medida_id) : null,
        stock_minimo: formData.stock_minimo,
        precio: formData.precio ? parseFloat(formData.precio) : null
      };
      
      const response = await http.post('/api/productos', dataToSend);
      
      if (response.data.success !== false) {
        setShowModal(false);
        resetForm();
        fetchProductos();
      } else {
        setError(response.data.message || 'Error al crear producto');
      }
    } catch (err: any) {
      const errorMessage = err.response?.data?.message || err.response?.data?.error || 'Error al crear producto';
      setError(errorMessage);
      console.error('Error al crear producto:', err);
    } finally {
      setSubmitting(false);
    }
  };

  const handleEditarProducto = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingProducto) return;
    
    setSubmitting(true);
    setError(''); // Limpiar errores anteriores
    
    try {
      const dataToSend = {
        nombre: formData.nombre,
        descripcion: formData.descripcion || null,
        codigo_barra: formData.codigo_barra || null,
        lote: formData.lote,
        estado_producto_id: parseInt(formData.estado_producto_id),
        fecha_caducidad: formData.fecha_caducidad || null,
        unidad_medida_id: formData.unidad_medida_id ? parseInt(formData.unidad_medida_id) : null,
        stock_minimo: formData.stock_minimo,
        precio: formData.precio ? parseFloat(formData.precio) : null
      };
      
      const response = await http.put(`/api/productos/${editingProducto.id_producto}`, dataToSend);
      
      if (response.data.success !== false) {
        setShowEditModal(false);
        setEditingProducto(null);
        resetForm();
        fetchProductos();
      } else {
        setError(response.data.message || 'Error al actualizar producto');
      }
    } catch (err: any) {
      const errorMessage = err.response?.data?.message || err.response?.data?.error || 'Error al actualizar producto';
      setError(errorMessage);
      console.error('Error al actualizar producto:', err);
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      nombre: '',
      descripcion: '',
      codigo_barra: '',
      lote: '',
      estado_producto_id: '',
      fecha_caducidad: '',
      unidad_medida_id: '',
      stock_minimo: 0,
      precio: ''
    });
  };

  const openEditModal = (producto: Producto) => {
    setEditingProducto(producto);
    setFormData({
      nombre: producto.nombre,
      descripcion: producto.descripcion || '',
      codigo_barra: producto.codigo_barra || '',
      lote: producto.lote,
      estado_producto_id: producto.estado_producto_id.toString(),
      fecha_caducidad: producto.fecha_caducidad || '',
      unidad_medida_id: producto.unidad_medida_id ? producto.unidad_medida_id.toString() : '',
      stock_minimo: producto.stock_minimo,
      precio: producto.precio ? producto.precio.toString() : ''
    });
    setShowEditModal(true);
  };

  const handleVerDetalle = (id: number) => {
    const producto = productos.find(p => p.id_producto === id);
    if (producto) {
      setSelectedProducto(producto);
      setShowDetailModal(true);
    } else {
      navigate(`/productos/${id}`);
    }
  };

  const handleActivar = async (id: number) => {
    try {
      await http.patch(`/api/productos/${id}/activar`);
      fetchProductos();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al activar producto');
    }
  };

  const handleDesactivar = async (id: number) => {
    try {
      await http.patch(`/api/productos/${id}/desactivar`);
      fetchProductos();
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
    const esAdmin = user.rol_id === 1;
    const esSupervisor = user.rol_id === 2;
    return esAdmin || esSupervisor;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando productos...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Gestión de Productos</h1>
        {puedeGestionarProductos() && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
          >
            Nuevo Producto
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
              placeholder="Buscar por nombre, descripción, código..."
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
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
              <option value="">Todos</option>
              {catalogos?.estados.map((estado) => (
                <option key={estado.id_estado_producto} value={estado.id_estado_producto}>
                  {estado.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Unidad de Medida
            </label>
            <select
              value={filtros.unidad_medida}
              onChange={(e) => setFiltros({ ...filtros, unidad_medida: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todas</option>
              {catalogos?.unidades_medida.map((unidad) => (
                <option key={unidad.id} value={unidad.codigo}>
                  {unidad.nombre}
                </option>
              ))}
            </select>
          </div>
          
          <div className="flex items-end">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={filtros.stock_minimo}
                onChange={(e) => setFiltros({ ...filtros, stock_minimo: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <span className="ml-2 text-sm text-gray-700">Por debajo del mínimo</span>
            </label>
          </div>
        </div>
        
        <div className="mt-4">
          <button
            onClick={() => setFiltros({ q: '', estado: '', unidad_medida: '', stock_minimo: false })}
            className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>

      {/* Tabla de productos */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Nombre
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Lote
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Unidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Stock Mín.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Precio
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {productos.map((producto) => (
                <tr key={producto.id_producto} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    #{producto.id_producto}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900 max-w-xs truncate">
                      {producto.nombre}
                    </div>
                    {producto.descripcion && (
                      <div className="text-xs text-gray-500 max-w-xs truncate">
                        {producto.descripcion}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {producto.lote}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(producto.estado.codigo)}`}>
                      {producto.estado.nombre}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {(() => {
                      try {
                        if (producto.unidadMedida && typeof producto.unidadMedida === 'object' && producto.unidadMedida.nombre) {
                          return producto.unidadMedida.nombre;
                        }
                        if (producto.unidad_medida && typeof producto.unidad_medida === 'string') {
                          return producto.unidad_medida;
                        }
                        return '-';
                      } catch (error) {
                        return '-';
                      }
                    })()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {producto.stock_minimo}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {producto.precio ? `$${Number(producto.precio).toFixed(2)}` : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                    <button
                      onClick={() => handleVerDetalle(producto.id_producto)}
                      className="text-blue-600 hover:text-blue-900 mr-2"
                      title="Ver detalles"
                    >
                      Detalle
                    </button>
                    <button
                      onClick={() => navigate(`/productos/${producto.id_producto}`)}
                      className="text-purple-600 hover:text-purple-900 text-xs"
                      title="Ver página completa"
                    >
                      Ver más
                    </button>
                    {puedeGestionarProductos() && (
                      <>
                        <button
                          onClick={() => openEditModal(producto)}
                          className="text-orange-600 hover:text-orange-900"
                        >
                          Editar
                        </button>
                        {producto.estado.codigo === 'RETENIDO' ? (
                          <button
                            onClick={() => handleActivar(producto.id_producto)}
                            className="text-green-600 hover:text-green-900"
                          >
                            Activar
                          </button>
                        ) : (
                          <button
                            onClick={() => handleDesactivar(producto.id_producto)}
                            className="text-red-600 hover:text-red-900"
                          >
                            Desactivar
                          </button>
                        )}
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {productos.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No se encontraron productos con los filtros aplicados
          </div>
        )}
      </div>

      {/* Modal para crear producto */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" style={{ zIndex: 9999 }}>
          <div className="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Nuevo Producto
              </h3>
              <form onSubmit={handleCrearProducto} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Nombre *
                  </label>
                  <input
                    type="text"
                    value={formData.nombre}
                    onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Descripción
                  </label>
                  <textarea
                    value={formData.descripcion}
                    onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={2}
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Código de Barra
                  </label>
                  <input
                    type="text"
                    value={formData.codigo_barra}
                    onChange={(e) => setFormData({ ...formData, codigo_barra: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Lote *
                  </label>
                  <input
                    type="text"
                    value={formData.lote}
                    onChange={(e) => setFormData({ ...formData, lote: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Estado *
                  </label>
                  <select
                    value={formData.estado_producto_id}
                    onChange={(e) => setFormData({ ...formData, estado_producto_id: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar estado</option>
                    {catalogos?.estados.map((estado) => (
                      <option key={estado.id_estado_producto} value={estado.id_estado_producto}>
                        {estado.nombre}
                      </option>
                    ))}
                  </select>
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
                    Unidad de Medida *
                  </label>
                  <select
                    value={formData.unidad_medida_id}
                    onChange={(e) => setFormData({ ...formData, unidad_medida_id: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar unidad</option>
                    {catalogos?.unidades_medida.map((unidad) => (
                      <option key={unidad.id} value={unidad.id}>
                        {unidad.nombre} ({unidad.codigo})
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Stock Mínimo *
                  </label>
                  <input
                    type="number"
                    min="0"
                    value={formData.stock_minimo}
                    onChange={(e) => setFormData({ ...formData, stock_minimo: parseInt(e.target.value) || 0 })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Precio
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.precio}
                    onChange={(e) => setFormData({ ...formData, precio: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
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
                    {submitting ? 'Creando...' : 'Crear Producto'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Modal para editar producto */}
      {showEditModal && editingProducto && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" style={{ zIndex: 9999 }}>
          <div className="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Editar Producto: {editingProducto.nombre}
              </h3>
              <form onSubmit={handleEditarProducto} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Nombre *
                  </label>
                  <input
                    type="text"
                    value={formData.nombre}
                    onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Descripción
                  </label>
                  <textarea
                    value={formData.descripcion}
                    onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={2}
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Código de Barra
                  </label>
                  <input
                    type="text"
                    value={formData.codigo_barra}
                    onChange={(e) => setFormData({ ...formData, codigo_barra: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Lote *
                  </label>
                  <input
                    type="text"
                    value={formData.lote}
                    onChange={(e) => setFormData({ ...formData, lote: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Estado *
                  </label>
                  <select
                    value={formData.estado_producto_id}
                    onChange={(e) => setFormData({ ...formData, estado_producto_id: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar estado</option>
                    {catalogos?.estados.map((estado) => (
                      <option key={estado.id_estado_producto} value={estado.id_estado_producto}>
                        {estado.nombre}
                      </option>
                    ))}
                  </select>
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
                    Unidad de Medida *
                  </label>
                  <select
                    value={formData.unidad_medida_id}
                    onChange={(e) => setFormData({ ...formData, unidad_medida_id: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar unidad</option>
                    {catalogos?.unidades_medida.map((unidad) => (
                      <option key={unidad.id} value={unidad.id}>
                        {unidad.nombre} ({unidad.codigo})
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Stock Mínimo *
                  </label>
                  <input
                    type="number"
                    min="0"
                    value={formData.stock_minimo}
                    onChange={(e) => setFormData({ ...formData, stock_minimo: parseInt(e.target.value) || 0 })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Precio
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.precio}
                    onChange={(e) => setFormData({ ...formData, precio: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => {
                      setShowEditModal(false);
                      setEditingProducto(null);
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
                    {submitting ? 'Actualizando...' : 'Actualizar Producto'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Modal de detalles flotante */}
      {showDetailModal && selectedProducto && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" style={{ zIndex: 9999 }}>
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium text-gray-900">
                  Detalles del Producto: {selectedProducto.nombre}
                </h3>
                <button
                  onClick={() => {
                    setShowDetailModal(false);
                    setSelectedProducto(null);
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-500">ID:</label>
                    <p className="text-sm text-gray-900">#{selectedProducto.id_producto}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Estado:</label>
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(selectedProducto.estado.codigo)}`}>
                      {selectedProducto.estado.nombre}
                    </span>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Descripción:</label>
                    <p className="text-sm text-gray-900">{selectedProducto.descripcion || 'Sin descripción'}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Código de Barra:</label>
                    <p className="text-sm text-gray-900">{selectedProducto.codigo_barra || 'Sin código'}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Lote:</label>
                    <p className="text-sm text-gray-900">{selectedProducto.lote}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Unidad de Medida:</label>
                    <p className="text-sm text-gray-900">
                      {selectedProducto.unidadMedida?.nombre || selectedProducto.unidad_medida || '-'}
                    </p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Stock Mínimo:</label>
                    <p className="text-sm text-gray-900">{selectedProducto.stock_minimo}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-500">Precio:</label>
                    <p className="text-sm text-gray-900">
                      {selectedProducto.precio ? `$${Number(selectedProducto.precio).toFixed(2)}` : 'Sin precio'}
                    </p>
                  </div>
                  {selectedProducto.fecha_caducidad && (
                    <div>
                      <label className="block text-sm font-medium text-gray-500">Fecha de Caducidad:</label>
                      <p className="text-sm text-gray-900">
                        {new Date(selectedProducto.fecha_caducidad).toLocaleDateString()}
                      </p>
                    </div>
                  )}
                </div>
                
                <div className="flex justify-end space-x-3 pt-4 border-t">
                  <button
                    onClick={() => {
                      setShowDetailModal(false);
                      setSelectedProducto(null);
                    }}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                  >
                    Cerrar
                  </button>
                  <button
                    onClick={() => {
                      setShowDetailModal(false);
                      openEditModal(selectedProducto);
                    }}
                    className="px-4 py-2 text-sm font-medium text-white bg-orange-600 rounded-md hover:bg-orange-700"
                  >
                    Editar
                  </button>
                  <button
                    onClick={() => {
                      setShowDetailModal(false);
                      setSelectedProducto(null);
                      navigate(`/productos/${selectedProducto.id_producto}`);
                    }}
                    className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
                  >
                    Ver Página Completa
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Productos;
