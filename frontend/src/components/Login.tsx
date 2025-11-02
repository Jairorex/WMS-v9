import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

const Login: React.FC = () => {
  const [formData, setFormData] = useState({
    login: '',
    password: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(formData.login, formData.password);
      navigate('/');
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <div className="min-h-screen flex">
      {/* Sidebar verde */}
      <div className="w-16 bg-green-500"></div>
      
      {/* Contenido principal */}
      <div className="flex-1 flex flex-col">
        {/* Header naranja */}
        <div className="h-20 bg-orange-500"></div>
        
        {/* Área de contenido blanco */}
        <div className="flex-1 bg-white flex items-center justify-center">
          <div className="max-w-md w-full px-8">
            {/* Logo y branding */}
            <div className="text-center mb-8">
              <div className="flex items-center justify-center mb-4">
                {/* Logo ESCASAN */}
                <div className="flex items-center">
                  <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-orange-500 rounded-lg flex items-center justify-center mr-3">
                    <span className="text-white font-bold text-xl">E</span>
                  </div>
                  <div>
                    <h1 className="text-3xl font-bold text-green-600">ESCASAN</h1>
                    <p className="text-sm text-gray-500">Escalante Sánchez S.A.</p>
                  </div>
                </div>
              </div>
              
              <h2 className="text-2xl font-semibold text-gray-900 mb-8">
                Inicio de sesión
              </h2>
            </div>

            {/* Formulario */}
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Campo Email */}
              <div className="flex items-center space-x-4">
                <label htmlFor="login" className="w-20 text-sm font-medium text-gray-700">
                  Email:
                </label>
                <input
                  id="login"
                  name="login"
                  type="text"
                  required
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  placeholder=""
                  value={formData.login}
                  onChange={handleChange}
                />
              </div>

              {/* Campo Password */}
              <div className="flex items-center space-x-4">
                <label htmlFor="password" className="w-20 text-sm font-medium text-gray-700">
                  Password:
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  required
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  placeholder=""
                  value={formData.password}
                  onChange={handleChange}
                />
              </div>

              {/* Checkbox Recordarme */}
              <div className="flex items-center">
                <input
                  id="remember"
                  name="remember"
                  type="checkbox"
                  className="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300 rounded"
                />
                <label htmlFor="remember" className="ml-2 block text-sm text-gray-700">
                  Recordarme
                </label>
              </div>

              {error && (
                <div className="text-red-600 text-sm text-center bg-red-50 p-3 rounded-md">
                  {error}
                </div>
              )}

              {/* Botón y enlace */}
              <div className="flex items-center justify-between">
                <button
                  type="submit"
                  disabled={loading}
                  className="px-6 py-2 bg-gray-500 text-white rounded-md shadow-sm hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 disabled:opacity-50 transition-colors"
                >
                  {loading ? 'Iniciando sesión...' : 'Iniciar sesión'}
                </button>
                
                <a href="#" className="text-sm text-blue-600 hover:text-blue-800 underline">
                  Recuperar contraseña
                </a>
              </div>
            </form>

            {/* Información de demo */}
            <div className="mt-8 text-center text-sm text-gray-600 bg-gray-50 p-4 rounded-md">
              <p><strong>Usuario demo:</strong> admin</p>
              <p><strong>Contraseña:</strong> admin123</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
