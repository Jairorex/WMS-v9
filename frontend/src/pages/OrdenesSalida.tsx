import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
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
    producto?: {
      nombre: string;
    };
  }>;
  created_at: string;
  updated_at: string;
}

interface Catalogos {
  productos: Array<{
    id_producto: number;
    nombre: string;
    lote: string;
  }>;
  prioridades: Array<{
    codigo: number;
    nombre: string;
  }>;
  estados: Array<{
    codigo: string;
    nombre: string;
  }>;
}

const OrdenesSalida: React.FC = () => {
  const navigate = useNavigate();
  const [ordenes, setOrdenes] = useState<OrdenSalida[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    cliente: '',
    fecha_compromiso: '',
    prioridad: 3,
    detalles: [{ id_producto: 0, cant_solicitada: 1, lote_preferente: '' }]
  });

  // Filtros
  const [filtros, setFiltros] = useState({
    q: '',
    estado: '',
    prioridad: '',
    cliente: '',
    desde: '',
    hasta: '',
    vencidas: false
  });

  useEffect(() => {
    fetchOrdenes();
    fetchCatalogos();
  }, []);

  const fetchOrdenes = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      
      Object.entries(filtros).forEach(([key, value]) => {
        if (value && value !== '') {
          params.append(key, value.toString());
        }
      });

      const response = await http.get(`/api/ordenes-salida?${params.toString()}`);
      setOrdenes(response.data.data || []);
    } catch (err: any) {
      setError('Error al cargar órdenes de salida');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      // Obtener productos disponibles
      const productosRes = await http.get('/api/productos?per_page=1000');
      const productos = productosRes.data.data || productosRes.data;

      // Obtener prioridades (definidas manualmente si no hay endpoint)
      const prioridades = [
        { codigo: 1, nombre: 'Muy Baja' },
        { codigo: 2, nombre: 'Baja' },
        { codigo: 3, nombre: 'Media' },
        { codigo: 4, nombre: 'Alta' },
        { codigo: 5, nombre: 'Urgente' }
      ];

      // Obtener estados
      const estados = [
        { codigo: 'CREADA', nombre: 'Creada' },
        { codigo: 'EN_PICKING', nombre: 'En Picking' },
        { codigo: 'PICKING_COMPLETO', nombre: 'Picking Completo' },
        { codigo: 'CANCELADA', nombre: 'Cancelada' }
      ];

      setCatalogos({
        productos: productos,
        prioridades: prioridades,
        estados: estados
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      // Catálogos por defecto
      setCatalogos({
        productos: [],
        prioridades: [
          { codigo: 1, nombre: 'Muy Baja' },
          { codigo: 2, nombre: 'Baja' },
          { codigo: 3, nombre: 'Media' },
          { codigo: 4, nombre: 'Alta' },
          { codigo: 5, nombre: 'Urgente' }
        ],
        estados: [
          { codigo: 'CREADA', nombre: 'Creada' },
          { codigo: 'EN_PICKING', nombre: 'En Picking' },
          { codigo: 'PICKING_COMPLETO', nombre: 'Picking Completo' },
          { codigo: 'CANCELADA', nombre: 'Cancelada' }
        ]
      });
    }
  };

  const handleCrearOrden = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await http.post('/api/ordenes-salida', formData);
      setShowModal(false);
      setFormData({
        cliente: '',
        fecha_compromiso: '',
        prioridad: 3,
        detalles: [{ id_producto: 0, cant_solicitada: 1, lote_preferente: '' }]
      });
      fetchOrdenes();
    } catch (err: any) {
      setError('Error al crear orden de salida');
      console.error(err);
    }
  };

  const handleVerDetalle = (id: number) => {
    navigate(`/ordenes-salida/${id}`);
  };

  const handleConfirmar = async (id: number) => {
    try {
      await http.patch(`/ordenes-salida/${id}/confirmar`);
      fetchOrdenes();
    } catch (err: any) {
      setError('Error al confirmar orden');
      console.error(err);
    }
  };

  const handleCancelar = async (id: number) => {
    if (window.confirm('¿Está seguro de cancelar esta orden?')) {
      try {
        await http.patch(`/ordenes-salida/${id}/cancelar`);
        fetchOrdenes();
      } catch (err: any) {
        setError('Error al cancelar orden');
        console.error(err);
      }
    }
  };

  const agregarDetalle = () => {
    setFormData({
      ...formData,
      detalles: [...formData.detalles, { id_producto: 0, cant_solicitada: 1, lote_preferente: '' }]
    });
  };

  const eliminarDetalle = (index: number) => {
    if (formData.detalles.length > 1) {
      const nuevosDetalles = formData.detalles.filter((_, i) => i !== index);
      setFormData({ ...formData, detalles: nuevosDetalles });
    }
  };

  const actualizarDetalle = (index: number, campo: string, valor: any) => {
    const nuevosDetalles = [...formData.detalles];
    nuevosDetalles[index] = { ...nuevosDetalles[index], [campo]: valor };
    setFormData({ ...formData, detalles: nuevosDetalles });
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
    const prioridadObj = catalogos?.prioridades.find(p => p.codigo === prioridad);
    return prioridadObj?.nombre || `Prioridad ${prioridad}`;
  };

  useEffect(() => {
    fetchOrdenes();
  }, [filtros]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Órdenes de Salida</h1>
        <button
          onClick={() => setShowModal(true)}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center gap-2"
        >
          <span>+</span>
          Nueva Orden
        </button>
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {/* Filtros */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
            <input
              type="text"
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Cliente, ID..."
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Estado</label>
            <select
              value={filtros.estado}
              onChange={(e) => setFiltros({ ...filtros, estado: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.estados.map(estado => (
                <option key={estado.codigo} value={estado.codigo}>{estado.nombre}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Prioridad</label>
            <select
              value={filtros.prioridad}
              onChange={(e) => setFiltros({ ...filtros, prioridad: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todas</option>
              {catalogos?.prioridades.map(prioridad => (
                <option key={prioridad.codigo} value={prioridad.codigo}>{prioridad.nombre}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Cliente</label>
            <input
              type="text"
              value={filtros.cliente}
              onChange={(e) => setFiltros({ ...filtros, cliente: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Nombre cliente..."
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Desde</label>
            <input
              type="date"
              value={filtros.desde}
              onChange={(e) => setFiltros({ ...filtros, desde: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Hasta</label>
            <input
              type="date"
              value={filtros.hasta}
              onChange={(e) => setFiltros({ ...filtros, hasta: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        <div className="mt-4 flex items-center gap-4">
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={filtros.vencidas}
              onChange={(e) => setFiltros({ ...filtros, vencidas: e.target.checked })}
              className="mr-2"
            />
            Solo vencidas
          </label>
        </div>
      </div>

      {/* Tabla de órdenes */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Prioridad</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha Compromiso</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Detalles</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {ordenes.map((orden) => (
              <tr key={orden.id_orden} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  #{orden.id_orden}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {orden.cliente}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getEstadoColor(orden.estado)}`}>
                    {orden.estado}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrioridadColor(orden.prioridad)}`}>
                    {getPrioridadNombre(orden.prioridad)}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {new Date(orden.fecha_compromiso).toLocaleDateString()}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {orden.detalles?.length || 0} líneas
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  <button
                    onClick={() => handleVerDetalle(orden.id_orden)}
                    className="text-blue-600 hover:text-blue-900"
                  >
                    Ver
                  </button>
                  {orden.estado === 'CREADA' && (
                    <>
                      <button
                        onClick={() => handleConfirmar(orden.id_orden)}
                        className="text-green-600 hover:text-green-900"
                      >
                        Confirmar
                      </button>
                      <button
                        onClick={() => handleCancelar(orden.id_orden)}
                        className="text-red-600 hover:text-red-900"
                      >
                        Cancelar
                      </button>
                    </>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Modal para crear orden */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-11/12 md:w-3/4 lg:w-1/2 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium text-gray-900">Nueva Orden de Salida</h3>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ✕
                </button>
              </div>

              <form onSubmit={handleCrearOrden} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Cliente</label>
                    <input
                      type="text"
                      value={formData.cliente}
                      onChange={(e) => setFormData({ ...formData, cliente: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Fecha Compromiso</label>
                    <input
                      type="date"
                      value={formData.fecha_compromiso}
                      onChange={(e) => setFormData({ ...formData, fecha_compromiso: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Prioridad</label>
                    <select
                      value={formData.prioridad}
                      onChange={(e) => setFormData({ ...formData, prioridad: parseInt(e.target.value) })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                      {catalogos?.prioridades.map(prioridad => (
                        <option key={prioridad.codigo} value={prioridad.codigo}>{prioridad.nombre}</option>
                      ))}
                    </select>
                  </div>
                </div>

                <div>
                  <div className="flex justify-between items-center mb-2">
                    <label className="block text-sm font-medium text-gray-700">Detalles</label>
                    <button
                      type="button"
                      onClick={agregarDetalle}
                      className="text-blue-600 hover:text-blue-800 text-sm"
                    >
                      + Agregar línea
                    </button>
                  </div>

                  {formData.detalles.map((detalle, index) => (
                    <div key={index} className="grid grid-cols-1 md:grid-cols-4 gap-2 mb-2 p-3 border rounded">
                      <div>
                        <label className="block text-xs font-medium text-gray-700 mb-1">Producto</label>
                        <select
                          value={detalle.id_producto}
                          onChange={(e) => actualizarDetalle(index, 'id_producto', parseInt(e.target.value))}
                          className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                          required
                        >
                          <option value={0}>Seleccionar producto...</option>
                          {catalogos?.productos.map(producto => (
                            <option key={producto.id_producto} value={producto.id_producto}>
                              {producto.nombre} {producto.codigo_barra && `(${producto.codigo_barra})`}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div>
                        <label className="block text-xs font-medium text-gray-700 mb-1">Cantidad</label>
                        <input
                          type="number"
                          min="1"
                          value={detalle.cant_solicitada}
                          onChange={(e) => actualizarDetalle(index, 'cant_solicitada', parseInt(e.target.value))}
                          className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                          required
                        />
                      </div>

                      <div>
                        <label className="block text-xs font-medium text-gray-700 mb-1">Lote Preferente</label>
                        <input
                          type="text"
                          value={detalle.lote_preferente}
                          onChange={(e) => actualizarDetalle(index, 'lote_preferente', e.target.value)}
                          className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                          placeholder="Opcional"
                        />
                      </div>

                      <div className="flex items-end">
                        {formData.detalles.length > 1 && (
                          <button
                            type="button"
                            onClick={() => eliminarDetalle(index)}
                            className="text-red-600 hover:text-red-800 text-sm"
                          >
                            Eliminar
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>

                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 hover:bg-gray-300 rounded-md"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md"
                  >
                    Crear Orden
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

export default OrdenesSalida;
