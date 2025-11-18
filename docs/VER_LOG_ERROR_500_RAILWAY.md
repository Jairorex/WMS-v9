# 🔍 Cómo Ver el Error 500 Específico en Railway

## ❌ Problema

Estás viendo errores 500 pero los **HTTP Logs** solo muestran información básica (status, duración, etc.), no el error específico de PHP/Laravel.

## ✅ Solución: Ver los Logs de la Aplicación

Los **HTTP Logs** no muestran el error específico. Necesitas ver los **Deploy Logs** o **Application Logs**.

### Pasos para Ver el Error Específico:

1. **Ve a Railway Dashboard → Tu Proyecto**

2. **Haz clic en "Deployments"** (no en "Logs" que muestra HTTP logs)

3. **Haz clic en el deployment más reciente** (el que está "Active")

4. **Haz clic en "Deploy Logs"** (no "Build Logs" ni "HTTP Logs")

5. **Busca el error específico** - Deberías ver algo como:

```
production.ERROR: [mensaje del error]
Stack trace:
#0 /app/vendor/...
#1 /app/app/...
```

### Alternativa: Ver Logs en Tiempo Real

1. **Ve a Railway Dashboard → Tu Proyecto**
2. **Haz clic en "Logs"** (en el menú lateral)
3. **Filtra por "Error"** o busca líneas que contengan "ERROR"
4. **Haz una petición** desde el frontend para generar el error
5. **Observa los logs en tiempo real**

## 🔍 Qué Buscar en los Logs

### Errores Comunes:

**1. Error de Base de Datos:**
```
SQLSTATE[08001]: [Microsoft][ODBC Driver 18 for SQL Server]SSL Provider: No se pudo encontrar un certificado válido
```
**Solución:** Agregar `TrustServerCertificate=yes` en la conexión

**2. Error de Driver:**
```
could not find driver (Connection: sqlsrv, SQL: ...)
```
**Solución:** Verificar que el Dockerfile se haya usado correctamente

**3. Error de Clase:**
```
Class 'App\...' not found
```
**Solución:** Ejecutar `composer dump-autoload`

**4. Error de Variable:**
```
No application encryption key has been specified.
```
**Solución:** Agregar `APP_KEY` en Railway Variables

**5. Error de Vista:**
```
View [welcome] not found.
```
**Solución:** Ya corregido - ruta raíz ahora devuelve JSON

**6. Error de Middleware:**
```
Call to undefined method ...
```
**Solución:** Verificar que el middleware esté correctamente registrado

## 📋 Información Necesaria

Para diagnosticar el error 500, necesito:

1. **El mensaje de error completo** (primera línea del error)
2. **El stack trace** (las líneas que empiezan con `#0`, `#1`, etc.)
3. **El archivo y línea** donde ocurre el error
4. **El tipo de error** (SQLSTATE, Class not found, etc.)

## 🚀 Pasos Rápidos

1. **Railway Dashboard → Deployments → Último deployment → Deploy Logs**
2. **Busca líneas que contengan "ERROR" o "Exception"**
3. **Copia el error completo** (desde "production.ERROR" hasta el final del stack trace)
4. **Comparte el error** para diagnosticar

## 💡 Nota

Los **HTTP Logs** solo muestran:
- Status code (500)
- Duración de la petición
- Tamaño de la respuesta
- Dirección del upstream

**NO muestran** el error específico de PHP/Laravel.

Para ver el error específico, necesitas los **Deploy Logs** o **Application Logs**.

