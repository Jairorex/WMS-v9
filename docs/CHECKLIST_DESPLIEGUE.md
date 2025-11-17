# ✅ Checklist de Despliegue en Vercel

Usa este checklist para asegurarte de que todo esté configurado correctamente.

## 🔧 Backend (Railway)

### Configuración Inicial
- [ ] Cuenta creada en Railway
- [ ] Proyecto creado desde GitHub
- [ ] Repositorio `WMS-v9` conectado

### Configuración del Servicio
- [ ] Root Directory: `backend`
- [ ] Build Command: `composer install --no-dev --optimize-autoloader`
- [ ] Start Command: `php artisan serve --host=0.0.0.0 --port=$PORT`

### Variables de Entorno
- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `APP_KEY=` (se generará automáticamente)
- [ ] `DB_CONNECTION=sqlsrv`
- [ ] `DB_HOST=` (tu servidor SQL Server)
- [ ] `DB_PORT=1433`
- [ ] `DB_DATABASE=wms`
- [ ] `DB_USERNAME=` (tu usuario)
- [ ] `DB_PASSWORD=` (tu contraseña)
- [ ] `SESSION_DRIVER=database`
- [ ] `SESSION_LIFETIME=120`
- [ ] `CORS_ALLOWED_ORIGINS=` (se actualizará después)

### Despliegue
- [ ] Primer deployment completado
- [ ] `APP_KEY` generado y copiado
- [ ] `APP_KEY` actualizado en variables de entorno
- [ ] Servicio reiniciado
- [ ] URL del backend generada
- [ ] URL del backend anotada: `___________________________`

### Verificación
- [ ] Backend accesible en la URL de Railway
- [ ] Logs sin errores críticos
- [ ] API responde (probar endpoint `/api/health` o similar)

---

## 🎨 Frontend (Vercel)

### Configuración Inicial
- [ ] Cuenta creada en Vercel
- [ ] Proyecto importado desde GitHub
- [ ] Repositorio `WMS-v9` conectado

### Configuración del Proyecto
- [ ] Framework Preset: `Vite`
- [ ] Root Directory: `frontend` ⚠️
- [ ] Build Command: `npm run build`
- [ ] Output Directory: `dist`
- [ ] Install Command: `npm install`

### Variables de Entorno
- [ ] `VITE_API_URL=https://tu-backend-url.railway.app/api`
- [ ] Variable configurada para Production
- [ ] Variable configurada para Preview
- [ ] Variable configurada para Development

### Despliegue
- [ ] Primer deployment completado
- [ ] Build exitoso (sin errores)
- [ ] URL del frontend generada
- [ ] URL del frontend anotada: `___________________________`

### Verificación
- [ ] Frontend accesible en la URL de Vercel
- [ ] Página carga correctamente
- [ ] No hay errores en la consola del navegador

---

## 🔒 CORS

### Configuración
- [ ] URL del frontend de Vercel anotada
- [ ] `CORS_ALLOWED_ORIGINS` actualizado en Railway
- [ ] Railway reiniciado después de actualizar CORS

### Verificación
- [ ] CORS configurado correctamente
- [ ] No hay errores de CORS en la consola

---

## 🧪 Pruebas

### Funcionalidad Básica
- [ ] Página de login carga
- [ ] Login funciona con credenciales válidas
- [ ] Dashboard carga después del login
- [ ] Navegación funciona
- [ ] Logout funciona

### API
- [ ] Endpoints de API responden
- [ ] Autenticación funciona
- [ ] Datos se cargan correctamente
- [ ] No hay errores 401/403

### Interfaz
- [ ] Estilos se cargan correctamente
- [ ] Imágenes se cargan
- [ ] Responsive funciona (opcional)

---

## 📝 Notas

### URLs Importantes
- **Backend:** ________________________________
- **Frontend:** ________________________________

### Credenciales (guardar de forma segura)
- **SQL Server Host:** ________________________________
- **SQL Server User:** ________________________________
- **SQL Server Password:** ________________________________

### Problemas Encontrados
- ________________________________
- ________________________________
- ________________________________

---

## ✅ Despliegue Completado

- [ ] Todas las tareas completadas
- [ ] Aplicación funcionando en producción
- [ ] Documentación actualizada

**Fecha de despliegue:** ________________
**Versión desplegada:** ________________

---

**🎉 ¡Despliegue exitoso!**

