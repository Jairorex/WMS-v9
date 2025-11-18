// Tipos para las respuestas de la API

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data: T;
  errors?: Record<string, string[]>;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  meta?: {
    total: number;
    per_page: number;
    current_page: number;
    last_page: number;
    from: number;
    to: number;
  };
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
  status?: number;
}

// Tipos de datos del dominio

export interface Usuario {
  id_usuario: number;
  nombre: string;
  usuario: string;
  email: string;
  activo: boolean;
  rol_id: number;
  rol?: {
    id_rol: number;
    nombre: string;
    codigo: string;
  };
  ultimo_login?: string;
}

export interface Tarea {
  id_tarea: number;
  tipo_tarea_id: number;
  estado_tarea_id: number;
  prioridad: string;
  descripcion: string;
  creado_por: number;
  fecha_creacion: string;
  fecha_vencimiento?: string;
  fecha_cierre?: string;
  tipo?: {
    id_tipo_tarea: number;
    codigo: string;
    nombre: string;
  };
  estado?: {
    id_estado_tarea: number;
    codigo: string;
    nombre: string;
  };
  creador?: {
    id_usuario: number;
    nombre: string;
  };
  usuarios?: Array<{
    id_usuario: number;
    nombre: string;
    usuario: string;
    pivot: {
      es_responsable: boolean;
      asignado_desde: string;
      asignado_hasta?: string;
    };
  }>;
  detalles?: Array<{
    id_detalle: number;
    id_producto: number;
    cantidad_solicitada: number;
    cantidad_confirmada: number;
    producto?: {
      nombre: string;
      codigo_barra?: string;
    };
  }>;
}

export interface Producto {
  id_producto: number;
  nombre: string;
  codigo?: string;
  descripcion?: string;
  estado: string;
  unidad_medida?: {
    id_unidad_medida: number;
    nombre: string;
    codigo: string;
  };
}

export interface LoginRequest {
  usuario: string; // Puede ser usuario o email
  password: string;
}

export interface LoginResponse {
  usuario: Usuario;
  token: string;
}

