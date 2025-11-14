import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Layout from './components/Layout';
import Login from './components/Login';
import Dashboard from './pages/Dashboard';
import Usuarios from './pages/Usuarios';
import Inventario from './pages/Inventario';
import Tareas from './pages/Tareas';
import TareaDetalle from './pages/TareaDetalle';
import Productos from './pages/Productos';
import ProductoDetalle from './pages/ProductoDetalle';
import Ubicaciones from './pages/Ubicaciones';
import UbicacionDetalle from './pages/UbicacionDetalle';
import Lotes from './pages/Lotes';
import Incidencias from './pages/Incidencias';
import IncidenciaDetalle from './pages/IncidenciaDetalle';
import Reportes from './pages/Reportes';
import OrdenesSalida from './pages/OrdenesSalida';
import OrdenSalidaDetalle from './pages/OrdenSalidaDetalle';
import HistorialMovimientos from './pages/HistorialMovimientos';
import Movimiento from './pages/Movimiento';
import PickingDetalle from './pages/PickingDetalle';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/*"
            element={
              <ProtectedRoute>
                <Layout>
                  <Routes>
                    <Route path="/" element={<Dashboard />} />
                    <Route path="/usuarios" element={<Usuarios />} />
                    <Route path="/reportes" element={<Reportes />} />
                    {/* Redirigir /picking a /tareas con filtro */}
                    <Route path="/picking" element={<Navigate to="/tareas-conteo?tipo=picking" replace />} />
                    <Route path="/picking/:id" element={<PickingDetalle />} />
                    <Route path="/existencias" element={<Inventario />} />
                    <Route path="/tareas-conteo" element={<Tareas />} />
                    <Route path="/tareas/:id" element={<TareaDetalle />} />
                    <Route path="/productos" element={<Productos />} />
                    <Route path="/productos/:id" element={<ProductoDetalle />} />
                    <Route path="/ubicaciones" element={<Ubicaciones />} />
                    <Route path="/ubicaciones/:id" element={<UbicacionDetalle />} />
                    <Route path="/lotes" element={<Lotes />} />
                    <Route path="/incidencias" element={<Incidencias />} />
                           <Route path="/incidencias/:id" element={<IncidenciaDetalle />} />
                           <Route path="/ordenes-salida" element={<OrdenesSalida />} />
                           <Route path="/ordenes-salida/:id" element={<OrdenSalidaDetalle />} />
                           {/* Rutas de módulos */}
                    {/* Redirigir /packing a /tareas con filtro */}
                    <Route path="/packing" element={<Navigate to="/tareas-conteo?tipo=packing" replace />} />
                    <Route path="/movimiento" element={<Movimiento />} />
                    <Route path="/historial" element={<HistorialMovimientos />} />
                    <Route path="/etiquetas" element={<div className="p-6"><h1 className="text-2xl font-bold">Etiquetas</h1><p className="text-gray-600">Funcionalidad en desarrollo</p></div>} />
                    <Route path="*" element={<Navigate to="/" replace />} />
                  </Routes>
                </Layout>
              </ProtectedRoute>
            }
          />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;