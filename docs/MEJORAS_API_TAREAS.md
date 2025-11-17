# 🚀 Mejoras Técnicas en API de Tareas

## ✅ Cambios Implementados

### 1. **Endpoint Unificado `/api/tareas`** ✅

El endpoint `/api/tareas` ahora es el único punto de entrada para todas las tareas (picking, packing, tareas generales).

**Filtros disponibles:**
- `?tipo=picking` o `?tipo=packing` - Filtrar por tipo de tarea (acepta código string o ID numérico)
- `?estado=EN_PROCESO` - Filtrar por estado (acepta código string o ID numérico)
- `?prioridad=Alta` - Filtrar por prioridad
- `?usuario_asignado=123` - Filtrar por usuario asignado
- `?zona=A1` - Filtrar por zona (busca en ubicaciones)
- `?fecha_inicio=2024-01-01` - Filtrar desde fecha
- `?fecha_fin=2024-12-31` - Filtrar hasta fecha
- `?desde=2024-01-01` / `?hasta=2024-12-31` - Alias para compatibilidad
- `?q=busqueda` - Búsqueda general en descripción e ID
- `?vencidas=true` - Solo tareas vencidas
- `?per_page=15` - Cantidad de resultados por página (default: 15)
- `?paginate=false` - Desactivar paginación
- `?order_by=fecha_creacion` - Campo de ordenamiento
- `?order_dir=desc` - Dirección de ordenamiento (asc/desc)

**Ejemplo:**
```http
GET /api/tareas?tipo=picking&estado=EN_PROCESO&usuario_asignado=5&per_page=20
```

---

### 2. **Respuestas Estandarizadas** ✅

Todas las respuestas ahora siguen un formato uniforme:

**Respuesta exitosa:**
```json
{
  "success": true,
  "message": "Tarea completada correctamente",
  "data": {
    "id_tarea": 15,
    "estado": {
      "codigo": "COMPLETADA",
      "nombre": "Completada"
    }
  }
}
```

**Respuesta con paginación:**
```json
{
  "success": true,
  "message": "Tareas obtenidas exitosamente",
  "data": [...],
  "current_page": 1,
  "per_page": 15,
  "total": 100,
  "last_page": 7,
  "from": 1,
  "to": 15
}
```

**Respuesta de error:**
```json
{
  "success": false,
  "message": "No se pudo completar la tarea",
  "errors": {
    "estado": ["Transición inválida"]
  }
}
```

---

### 3. **Logs de Cambios de Estado** ✅

Cada cambio de estado se registra automáticamente en la tabla `tareas_log` con:
- Usuario que realizó el cambio
- Estado anterior y nuevo
- Timestamp
- Dispositivo (User-Agent)
- IP address
- Comentarios opcionales

**Modelo:** `App\Models\TareaLog`

**Tabla SQL:** Ver `backend/database/migrations/create_tareas_log_table.sql`

---

### 4. **Rutas Deprecadas con Redirección** ✅

Las rutas `/api/picking` y `/api/packing` ahora redirigen automáticamente a `/api/tareas` con el filtro aplicado:

```http
GET /api/picking
→ Redirige a: GET /api/tareas?tipo=picking

GET /api/packing?estado=EN_PROCESO
→ Redirige a: GET /api/tareas?tipo=packing&estado=EN_PROCESO
```

**Nota:** Las rutas antiguas de PickingController siguen funcionando para compatibilidad, pero se recomienda usar `/api/tareas`.

---

### 5. **Nuevos Endpoints** ✅

**Completar tarea:**
```http
PATCH /api/tareas/{id}/completar
```
Equivalente a `PATCH /api/tareas/{id}/cambiar-estado` con `estado=COMPLETADA`, pero más semántico.

---

### 6. **Scopes Mejorados en Modelo Tarea** ✅

Se agregaron scopes al modelo para facilitar consultas:

- `porTipo($tipo)` - Filtra por tipo (acepta ID o código)
- `porUsuarioAsignado($usuarioId)` - Filtra por usuario asignado
- `porFechaInicio($fecha)` - Filtra desde fecha
- `porFechaFin($fecha)` - Filtra hasta fecha
- `porZona($zona)` - Filtra por zona a través de ubicaciones
- `porEstado($estado)` - Ya existía, mejorado
- `porPrioridad($prioridad)` - Ya existía

---

### 7. **CORS Mejorado con Variables de Entorno** ✅

El middleware CORS ahora lee orígenes permitidos desde `.env`:

```env
# En .env
CORS_ALLOWED_ORIGINS=https://app.escasan.com,https://mobile.escasan.com
APP_URL=https://api.escasan.com
```

**En desarrollo:** Permite cualquier origen (incluye apps móviles)
**En producción:** Solo orígenes configurados en `.env`

---

## 📋 Archivos Modificados

1. `backend/app/Models/Tarea.php` - Scopes agregados
2. `backend/app/Http/Controllers/Api/TareaController.php` - Completamente mejorado
3. `backend/app/Traits/ApiResponse.php` - Nuevo trait para respuestas estandarizadas
4. `backend/app/Models/TareaLog.php` - Nuevo modelo para logs
5. `backend/routes/api.php` - Redirecciones agregadas
6. `backend/app/Http/Middleware/CorsMiddleware.php` - Variables de entorno
7. `backend/database/migrations/create_tareas_log_table.sql` - Script SQL nuevo

---

## 🔧 Configuración Requerida

### 1. Ejecutar Script SQL para Logs

```bash
# Ejecutar en SQL Server
sqlcmd -S servidor -d wms -i backend/database/migrations/create_tareas_log_table.sql
```

O ejecutar manualmente el contenido del archivo SQL en tu base de datos.

### 2. Configurar CORS en Producción

Agregar al `.env`:
```env
CORS_ALLOWED_ORIGINS=https://app.escasan.com,https://mobile.escasan.com
APP_URL=https://api.escasan.com
APP_ENV=production
```

---

## 🧪 Ejemplos de Uso

### Obtener todas las tareas de picking en proceso
```http
GET /api/tareas?tipo=picking&estado=EN_PROCESO
Authorization: Bearer {token}
```

### Completar una tarea
```http
PATCH /api/tareas/15/completar
Authorization: Bearer {token}
Content-Type: application/json

{
  "comentarios": "Tarea completada exitosamente"
}
```

### Filtrar tareas por usuario y zona
```http
GET /api/tareas?usuario_asignado=5&zona=A1&per_page=50
Authorization: Bearer {token}
```

### Obtener tareas vencidas con paginación
```http
GET /api/tareas?vencidas=true&per_page=10&page=2
Authorization: Bearer {token}
```

---

## 🔄 Compatibilidad

✅ **Totalmente compatible con código existente:**
- Las rutas antiguas siguen funcionando
- Los endpoints de PickingController siguen disponibles
- Los filtros antiguos (`desde`, `hasta`) siguen funcionando

✅ **Migración gradual:**
- Puedes actualizar el frontend/móvil gradualmente
- Las redirecciones aseguran que no se rompa nada

---

## 📝 Notas Importantes

1. **Tabla de Logs:** Si la tabla `tareas_log` no existe, el sistema continuará funcionando pero no registrará logs. El código maneja esto gracefully.

2. **Tokens de Sanctum:** Considera configurar expiración en `config/sanctum.php`:
```php
'expiration' => 43200, // 30 días
```

3. **Próximos Pasos Recomendados:**
   - Implementar refresh tokens
   - Agregar cache para catálogos frecuentes
   - Crear FeatureTests para los nuevos endpoints
   - Documentar todos los filtros en API_DOCUMENTATION.md

---

## ✅ Checklist de Implementación

- [x] Filtros avanzados implementados
- [x] Respuestas estandarizadas
- [x] Logs de cambios de estado
- [x] Redirecciones para picking/packing
- [x] Paginación mejorada
- [x] CORS con variables de entorno
- [x] Scopes en modelo Tarea
- [x] Script SQL para tabla de logs
- [ ] Ejecutar script SQL en base de datos
- [ ] Configurar variables de entorno en producción
- [ ] Actualizar documentación API_DOCUMENTATION.md
- [ ] Crear FeatureTests

