import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { http } from '../lib/http';
import { useAuth } from '../contexts/AuthContext';

interface Tarea {
  id_tarea: number;
  tipo_tarea_id: number;
  estado_tarea_id: number;
  prioridad: string;
  descripcion: string;
  creado_por: number;
  fecha_creacion: string;
  fecha_cierre?: string;
  fecha_vencimiento?: string;
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
    id_usuario: number;
    nombre: string;
    usuario: string;
    pivot: {
      es_responsable: boolean;
      asignado_desde: string;
      asignado_hasta?: string;
    };
  }>;
  detalles: Array<{
    id_detalle: number;
    id_producto: number;
    cantidad_solicitada: number;
    cantidad_confirmada: number;
    producto: {
      nombre: string;
    };
  }>;
}

interface Catalogos {
  tipos: Array<{ id_tipo_tarea: number; codigo: string; nombre: string }>;
  estados: Array<{ id_estado_tarea: number; codigo: string; nombre: string }>;
  prioridades: Array<{ codigo: string; nombre: string }>;
  usuarios: Array<{ id_usuario: number; nombre: string; usuario: string }>;
}

// Interfaces unificadas para diferentes tipos
interface TareaUnificada {
  id: number;
  tipo: string; // 'tarea' | 'picking' | 'packing'
  estado: string;
  prioridad?: string | number;
  descripcion?: string;
  cliente?: string;
  orden_id?: number;
  asignado_a?: number;
  asignadoA?: { nombre: string };
  creado_por?: number;
  fecha_creacion?: string;
  fecha_vencimiento?: string;
  fecha_compromiso?: string;
  // Datos específicos de picking
  id_picking?: number;
  orden?: { id_orden: number; cliente: string; fecha_compromiso: string };
  // Datos específicos de packing
  id_packing?: number;
  orden_salida?: { id_orden: number; cliente: string; fecha_compromiso: string };
  // Datos específicos de tarea
  id_tarea?: number;
  tipo_tarea?: { codigo: string; nombre: string };
  usuarios?: Array<{ nombre: string }>;
  detalles?: Array<any>;
}

const Tareas: React.FC = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();
  
  // Leer tipo desde query params (picking, packing, o null para tareas normales)
  const tipoFiltro = searchParams.get('tipo') || '';
  
  const [tareas, setTareas] = useState<TareaUnificada[]>([]);
  const [catalogos, setCatalogos] = useState<Catalogos>({
    tipos: [],
    estados: [],
    prioridades: [],
    usuarios: []
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filtros, setFiltros] = useState({
    q: searchParams.get('q') || '',
    tipo: searchParams.get('tipo') || '',
    estado: searchParams.get('estado') || '',
    prioridad: searchParams.get('prioridad') || '',
    desde: searchParams.get('desde') || '',
    hasta: searchParams.get('hasta') || '',
    vencidas: searchParams.get('vencidas') === 'true'
  });
  const [showModal, setShowModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingTarea, setEditingTarea] = useState<Tarea | null>(null);
  const [formData, setFormData] = useState({
    tipo_tarea_id: '',
    prioridad: 'Media',
    descripcion: '',
    asignado_a: '',
    fecha_vencimiento: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();

  // Sincronizar filtros con URL (excluyendo 'tipo' que es solo para UI)
  useEffect(() => {
    const params = new URLSearchParams();
    Object.entries(filtros).forEach(([key, value]) => {
      // Solo incluir tipo en URL si viene de query params inicial, no del filtro interno
      if (value && (key !== 'tipo' || searchParams.get('tipo'))) {
        if (key === 'tipo' && (value === 'picking' || value === 'packing')) {
          params.set('tipo', value.toString());
        } else if (key !== 'tipo') {
          params.set(key, value.toString());
        }
      }
    });
    // Siempre incluir tipo en URL si viene de query params
    if (tipoFiltro) {
      params.set('tipo', tipoFiltro);
    }
    setSearchParams(params, { replace: true });
  }, [filtros, tipoFiltro]);

  useEffect(() => {
    fetchTareas();
    if (tipoFiltro !== 'picking' && tipoFiltro !== 'packing') {
      fetchCatalogos();
    }
  }, [filtros, tipoFiltro]);

  const fetchTareas = async () => {
    try {
      setLoading(true);
      setError('');
      
      let response;
      let data: TareaUnificada[] = [];

      // Decidir qué endpoint llamar según el tipo
      if (tipoFiltro === 'picking') {
        // Llamar a endpoint de picking
        const params = new URLSearchParams();
        if (filtros.estado) params.append('estado', filtros.estado);
        if (filtros.desde) params.append('desde', filtros.desde);
        if (filtros.hasta) params.append('hasta', filtros.hasta);
        if (filtros.q) params.append('q', filtros.q);

        response = await http.get(`/api/picking?${params.toString()}`);
        const pickings = response.data.data || [];
        
        // Normalizar datos de picking al formato unificado
        data = pickings.map((picking: any) => ({
          id: picking.id_picking,
          tipo: 'picking',
          estado: picking.estado,
          orden_id: picking.id_orden,
          cliente: picking.orden?.cliente,
          asignado_a: picking.asignado_a,
          asignadoA: picking.asignadoA,
          fecha_compromiso: picking.orden?.fecha_compromiso,
          orden: picking.orden,
          id_picking: picking.id_picking,
        }));
        
      } else if (tipoFiltro === 'packing') {
        // Llamar a endpoint de órdenes de salida (base para packing)
        const params = new URLSearchParams();
        if (filtros.estado) params.append('estado', filtros.estado);
        if (filtros.desde) params.append('desde', filtros.desde);
        if (filtros.hasta) params.append('hasta', filtros.hasta);
        if (filtros.q) params.append('q', filtros.q);

        response = await http.get(`/api/ordenes-salida?${params.toString()}`);
        const ordenes = response.data.data || [];
        
        // Normalizar datos de packing al formato unificado
        data = ordenes.map((orden: any) => ({
          id: orden.id_orden,
          tipo: 'packing',
          estado: orden.estado || 'PENDIENTE',
          orden_id: orden.id_orden,
          cliente: orden.cliente,
          prioridad: orden.prioridad,
          fecha_compromiso: orden.fecha_compromiso,
          orden_salida: orden,
          id_packing: orden.id_orden,
          detalles: orden.detalles || [],
        }));
        
      } else {
        // Llamar a endpoint de tareas normales
        const params = new URLSearchParams();
        Object.entries(filtros).forEach(([key, value]) => {
          // NO incluir el filtro 'tipo' con valores 'picking' o 'packing' en la llamada a /api/tareas
          // porque ese endpoint espera tipo_tarea_id (número), no códigos de tipo
          if (value && !(key === 'tipo' && (value === 'picking' || value === 'packing'))) {
            params.append(key, value.toString());
          }
        });

        response = await http.get(`/api/tareas?${params.toString()}`);
        const tareasData = response.data.data || [];
        
        // Normalizar datos de tareas al formato unificado
        data = tareasData.map((tarea: any) => ({
          id: tarea.id_tarea,
          tipo: 'tarea',
          estado: tarea.estado?.codigo || tarea.estado,
          prioridad: tarea.prioridad,
          descripcion: tarea.descripcion,
          asignado_a: tarea.usuarios?.[0]?.id_usuario,
          asignadoA: tarea.usuarios?.[0] ? { nombre: tarea.usuarios[0].nombre } : undefined,
          creado_por: tarea.creado_por,
          fecha_creacion: tarea.fecha_creacion,
          fecha_vencimiento: tarea.fecha_vencimiento,
          id_tarea: tarea.id_tarea,
          tipo_tarea: tarea.tipo,
          usuarios: tarea.usuarios,
          detalles: tarea.detalles || [],
        }));
      }

      setTareas(data);
    } catch (err: any) {
      setError(err.response?.data?.message || `Error al cargar ${tipoFiltro || 'tareas'}`);
    } finally {
      setLoading(false);
    }
  };

  const fetchCatalogos = async () => {
    try {
      const response = await http.get('/api/tareas-catalogos');
      // El API devuelve { success: true, data: { tipos, estados, prioridades, usuarios } }
      const catalogosData = response.data.data || response.data || {};
      setCatalogos({
        tipos: Array.isArray(catalogosData.tipos) ? catalogosData.tipos : [],
        estados: Array.isArray(catalogosData.estados) ? catalogosData.estados : [],
        prioridades: Array.isArray(catalogosData.prioridades) ? catalogosData.prioridades : [],
        usuarios: Array.isArray(catalogosData.usuarios) ? catalogosData.usuarios : []
      });
    } catch (err: any) {
      console.error('Error al cargar catálogos:', err);
      // Mantener valores por defecto en caso de error
      setCatalogos({
        tipos: [],
        estados: [],
        prioridades: [],
        usuarios: []
      });
    }
  };

  const handleCrearTarea = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    try {
      // Preparar datos para enviar
      const dataToSend = {
        tipo_tarea_id: formData.tipo_tarea_id,
        prioridad: formData.prioridad,
        descripcion: formData.descripcion,
        asignado_a: formData.asignado_a || null,
        fecha_vencimiento: formData.fecha_vencimiento || null
      };
      
      await http.post('/api/tareas', dataToSend);
      setShowModal(false);
      resetForm();
      fetchTareas();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al crear tarea');
    } finally {
      setSubmitting(false);
    }
  };

  const handleEditarTarea = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingTarea) return;
    
    setSubmitting(true);
    
    try {
      const dataToSend = {
        tipo_tarea_id: formData.tipo_tarea_id,
        prioridad: formData.prioridad,
        descripcion: formData.descripcion,
        asignado_a: formData.asignado_a || null,
        fecha_vencimiento: formData.fecha_vencimiento || null
      };
      
      await http.put(`/api/tareas/${editingTarea.id_tarea}`, dataToSend);
      setShowEditModal(false);
      setEditingTarea(null);
      resetForm();
      fetchTareas();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Error al actualizar tarea');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      tipo_tarea_id: '',
      prioridad: 'Media',
      descripcion: '',
      asignado_a: '',
      fecha_vencimiento: ''
    });
  };

  const openEditModal = (tarea: Tarea) => {
    setEditingTarea(tarea);
    setFormData({
      tipo_tarea_id: tarea.tipo_tarea_id.toString(),
      prioridad: tarea.prioridad,
      descripcion: tarea.descripcion,
      asignado_a: tarea.usuarios && tarea.usuarios.length > 0 ? tarea.usuarios[0].id_usuario.toString() : '',
      fecha_vencimiento: tarea.fecha_vencimiento || ''
    });
    setShowEditModal(true);
  };

  const handleVerDetalle = (id: number, tipo?: string) => {
    if (tipo === 'picking') {
      navigate(`/picking/${id}`);
    } else if (tipo === 'packing') {
      navigate(`/ordenes-salida/${id}`);
    } else {
      navigate(`/tareas/${id}`);
    }
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

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Cargando tareas...</div>
      </div>
    );
  }

  // Función para obtener título dinámico según el tipo
  const getTitulo = () => {
    if (tipoFiltro === 'picking') return 'PICKING';
    if (tipoFiltro === 'packing') return 'PACKING';
    return 'TAREAS';
  };

  // Función para obtener etiqueta de tipo
  const getTipoLabel = (tipo: string) => {
    const labels: { [key: string]: string } = {
      'picking': 'Picking',
      'packing': 'Packing',
      'tarea': 'Tarea'
    };
    return labels[tipo] || 'Tarea';
  };

  // Función para obtener color de estado unificado
  const getEstadoColor = (estado: string, tipo: string = 'tarea') => {
    // Normalizar estados
    const estadoNormalizado = estado.toUpperCase();
    
    if (tipo === 'picking') {
      const colores: { [key: string]: string } = {
        'ASIGNADO': 'bg-yellow-100 text-yellow-800 border-yellow-200',
        'EN_PROCESO': 'bg-blue-100 text-blue-800 border-blue-200',
        'PAUSADO': 'bg-orange-100 text-orange-800 border-orange-200',
        'COMPLETADO': 'bg-green-100 text-green-800 border-green-200',
        'CANCELADO': 'bg-red-100 text-red-800 border-red-200',
      };
      return colores[estadoNormalizado] || 'bg-gray-100 text-gray-800 border-gray-200';
    }
    
    if (tipo === 'packing') {
      const colores: { [key: string]: string } = {
        'CREADA': 'bg-blue-100 text-blue-800 border-blue-200',
        'EN_PICKING': 'bg-yellow-100 text-yellow-800 border-yellow-200',
        'PICKING_COMPLETO': 'bg-green-100 text-green-800 border-green-200',
        'CANCELADA': 'bg-red-100 text-red-800 border-red-200',
        'PENDIENTE': 'bg-gray-100 text-gray-800 border-gray-200',
      };
      return colores[estadoNormalizado] || 'bg-gray-100 text-gray-800 border-gray-200';
    }
    
    // Estados de tareas
    const colores: { [key: string]: string } = {
      'NUEVA': 'bg-blue-100 text-blue-800 border-blue-200',
      'ASIGNADA': 'bg-yellow-100 text-yellow-800 border-yellow-200',
      'EN_PROCESO': 'bg-blue-100 text-blue-800 border-blue-200',
      'COMPLETADA': 'bg-green-100 text-green-800 border-green-200',
      'CANCELADA': 'bg-red-100 text-red-800 border-red-200',
      'BLOQUEADA': 'bg-orange-100 text-orange-800 border-orange-200',
    };
    return colores[estadoNormalizado] || 'bg-gray-100 text-gray-800 border-gray-200';
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{getTitulo()}</h1>
          {tipoFiltro && (
            <div className="mt-1 flex items-center gap-2">
              <span className="text-sm text-gray-500">Filtro activo:</span>
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                {getTipoLabel(tipoFiltro)}
              </span>
              <button
                onClick={() => {
                  setSearchParams({});
                  setFiltros({ ...filtros, tipo: '' });
                }}
                className="text-xs text-blue-600 hover:text-blue-800"
              >
                (Limpiar)
              </button>
            </div>
          )}
        </div>
        {(String(user?.rol_id) === '1' || String(user?.rol_id) === '2') && tipoFiltro !== 'picking' && tipoFiltro !== 'packing' && (
          <button
            onClick={() => setShowModal(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700"
          >
            Nueva Tarea
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
              placeholder="Buscar en descripción..."
              value={filtros.q}
              onChange={(e) => setFiltros({ ...filtros, q: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tipo
            </label>
            <select
              value={filtros.tipo}
              onChange={(e) => setFiltros({ ...filtros, tipo: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Todos</option>
              {catalogos?.tipos && Array.isArray(catalogos.tipos) && catalogos.tipos.map((tipo) => (
                <option key={tipo.id_tipo_tarea} value={tipo.id_tipo_tarea}>
                  {tipo.nombre}
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
              {catalogos?.estados && Array.isArray(catalogos.estados) && catalogos.estados.map((estado) => (
                <option key={estado.id_estado_tarea} value={estado.id_estado_tarea}>
                  {estado.nombre}
                </option>
              ))}
            </select>
          </div>
          
          {/* Prioridad solo para tareas normales y packing */}
          {tipoFiltro === 'packing' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Prioridad
              </label>
              <select
                value={filtros.prioridad}
                onChange={(e) => setFiltros({ ...filtros, prioridad: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todas</option>
                {catalogos?.prioridades ? (
                  catalogos.prioridades.map((prioridad) => (
                    <option key={prioridad.codigo} value={prioridad.codigo}>
                      {prioridad.nombre}
                    </option>
                  ))
                ) : (
                  <>
                    <option value="1">Muy Baja</option>
                    <option value="2">Baja</option>
                    <option value="3">Media</option>
                    <option value="4">Alta</option>
                    <option value="5">Urgente</option>
                  </>
                )}
              </select>
            </div>
          )}
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Fecha Desde
            </label>
            <input
              type="date"
              value={filtros.desde}
              onChange={(e) => setFiltros({ ...filtros, desde: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Fecha Hasta
            </label>
            <input
              type="date"
              value={filtros.hasta}
              onChange={(e) => setFiltros({ ...filtros, hasta: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div className="flex items-end">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={filtros.vencidas}
                onChange={(e) => setFiltros({ ...filtros, vencidas: e.target.checked })}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <span className="ml-2 text-sm text-gray-700">Solo vencidas</span>
            </label>
          </div>
        </div>
        
        <div className="mt-4">
          <button
            onClick={() => setFiltros({ q: '', tipo: '', estado: '', prioridad: '', desde: '', hasta: '', vencidas: false })}
            className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>

      {/* Tabla de tareas */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Descripción
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Prioridad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Creado por
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Asignado a
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha Creación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {tareas.length === 0 ? (
                <tr>
                  <td colSpan={9} className="px-6 py-4 text-center text-gray-500">
                    No hay {tipoFiltro ? tipoFiltro : 'tareas'} disponibles
                  </td>
                </tr>
              ) : (
                tareas.map((tarea: TareaUnificada) => (
                  <tr key={tarea.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      #{tarea.id}
                      {tarea.tipo !== 'tarea' && (
                        <span className="ml-1 text-xs text-gray-400">({getTipoLabel(tarea.tipo)})</span>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900 max-w-xs truncate">
                        {tarea.descripcion || tarea.cliente || `Orden #${tarea.orden_id || ''}`}
                        {tarea.orden_id && (
                          <div className="text-xs text-gray-500">Orden: #{tarea.orden_id}</div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {tarea.tipo_tarea?.nombre || getTipoLabel(tarea.tipo)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full border ${getEstadoColor(tarea.estado, tarea.tipo)}`}>
                        {tarea.estado}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {tarea.prioridad && (
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrioridadColor(tarea.prioridad.toString())}`}>
                          {tarea.prioridad}
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {tarea.creado_por ? `Usuario ${tarea.creado_por}` : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {tarea.asignadoA ? (
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                          {tarea.asignadoA.nombre}
                        </span>
                      ) : tarea.usuarios && tarea.usuarios.length > 0 ? (
                        <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                          {tarea.usuarios[0].nombre}
                        </span>
                      ) : (
                        <span className="text-gray-400">Sin asignar</span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {tarea.fecha_creacion ? new Date(tarea.fecha_creacion).toLocaleDateString() : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                      {tarea.tipo === 'picking' && tarea.id_picking ? (
                        <button
                          onClick={() => navigate(`/picking/${tarea.id_picking}`)}
                          className="text-blue-600 hover:text-blue-900"
                        >
                          Detalle
                        </button>
                      ) : tarea.tipo === 'packing' ? (
                        <button
                          onClick={() => navigate(`/ordenes-salida/${tarea.orden_id}`)}
                          className="text-blue-600 hover:text-blue-900"
                        >
                          Detalle
                        </button>
                      ) : tarea.id_tarea ? (
                        <>
                          <button
                            onClick={() => handleVerDetalle(tarea.id_tarea!)}
                            className="text-blue-600 hover:text-blue-900"
                          >
                            Detalle
                          </button>
                          {(String(user?.rol_id) === '1' || String(user?.rol_id) === '2') && (
                            <button
                              onClick={() => {
                                // Convertir TareaUnificada a Tarea para editar
                                const tareaEdit: any = {
                                  id_tarea: tarea.id_tarea,
                                  tipo_tarea_id: tarea.tipo_tarea?.codigo,
                                  prioridad: tarea.prioridad,
                                  descripcion: tarea.descripcion,
                                  usuarios: tarea.usuarios,
                                  fecha_vencimiento: tarea.fecha_vencimiento
                                };
                                openEditModal(tareaEdit);
                              }}
                              className="text-orange-600 hover:text-orange-900"
                            >
                              Editar
                            </button>
                          )}
                        </>
                      ) : null}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        
        {tareas.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No se encontraron tareas con los filtros aplicados
          </div>
        )}
      </div>

      {/* Modal para crear tarea */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Nueva Tarea
              </h3>
              <form onSubmit={handleCrearTarea} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Tipo de Tarea
                  </label>
                  <select
                    value={formData.tipo_tarea_id}
                    onChange={(e) => setFormData({ ...formData, tipo_tarea_id: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar tipo</option>
                    {catalogos?.tipos && Array.isArray(catalogos.tipos) && catalogos.tipos.map((tipo) => (
                      <option key={tipo.id_tipo_tarea} value={tipo.id_tipo_tarea}>
                        {tipo.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Prioridad
                  </label>
                  <select
                    value={formData.prioridad}
                    onChange={(e) => setFormData({ ...formData, prioridad: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    {catalogos?.prioridades && Array.isArray(catalogos.prioridades) && catalogos.prioridades.map((prioridad) => (
                      <option key={prioridad.codigo} value={prioridad.codigo}>
                        {prioridad.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                
                {/* User assignment field */}
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Asignar a Usuario
                  </label>
                  <select
                    value={formData.asignado_a}
                    onChange={(e) => setFormData({ ...formData, asignado_a: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Sin asignar</option>
                    {catalogos?.usuarios && Array.isArray(catalogos.usuarios) && catalogos.usuarios.map((usuario) => (
                      <option key={usuario.id_usuario} value={usuario.id_usuario}>
                        {usuario.nombre} ({usuario.usuario})
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Descripción
                  </label>
                  <textarea
                    value={formData.descripcion}
                    onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                    required
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
                    {submitting ? 'Creando...' : 'Crear Tarea'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Modal para editar tarea */}
      {showEditModal && editingTarea && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Editar Tarea: #{editingTarea.id_tarea}
              </h3>
              <form onSubmit={handleEditarTarea} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Tipo de Tarea *
                  </label>
                  <select
                    value={formData.tipo_tarea_id}
                    onChange={(e) => setFormData({ ...formData, tipo_tarea_id: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar tipo</option>
                    {catalogos?.tipos && Array.isArray(catalogos.tipos) && catalogos.tipos.map((tipo) => (
                      <option key={tipo.id_tipo_tarea} value={tipo.id_tipo_tarea}>
                        {tipo.nombre}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Prioridad *
                  </label>
                  <select
                    value={formData.prioridad}
                    onChange={(e) => setFormData({ ...formData, prioridad: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    required
                  >
                    <option value="">Seleccionar prioridad</option>
                    {catalogos?.prioridades && Array.isArray(catalogos.prioridades) && catalogos.prioridades.map((prioridad) => (
                      <option key={prioridad.codigo} value={prioridad.codigo}>
                        {prioridad.nombre}
                      </option>
                    ))}
                  </select>
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
                    min={new Date().toISOString().split('T')[0]}
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
                    Descripción *
                  </label>
                  <textarea
                    value={formData.descripcion}
                    onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Asignar a Usuario
                  </label>
                  <select
                    value={formData.asignado_a}
                    onChange={(e) => setFormData({ ...formData, asignado_a: e.target.value })}
                    className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Sin asignar</option>
                    {catalogos?.usuarios && Array.isArray(catalogos.usuarios) && catalogos.usuarios.map((usuario) => (
                      <option key={usuario.id_usuario} value={usuario.id_usuario}>
                        {usuario.nombre} ({usuario.usuario})
                      </option>
                    ))}
                  </select>
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => {
                      setShowEditModal(false);
                      setEditingTarea(null);
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
                    {submitting ? 'Actualizando...' : 'Actualizar Tarea'}
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

export default Tareas;
