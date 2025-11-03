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
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      {/* Fondo con imagen de Escasan - estilo abstracto con tonos rurales */}
      <div 
        className="absolute inset-0 bg-cover bg-center"
        style={{
          backgroundImage: `linear-gradient(135deg, rgba(34, 139, 34, 0.85) 0%, rgba(255, 140, 0, 0.75) 50%, rgba(34, 139, 34, 0.85) 100%), 
                           url('data:image/svg+xml,%3Csvg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg"%3E%3Cdefs%3E%3ClinearGradient id="grad1" x1="0%25" y1="0%25" x2="100%25" y2="100%25"%3E%3Cstop offset="0%25" style="stop-color:%23228B22;stop-opacity:1" /%3E%3Cstop offset="50%25" style="stop-color:%23FF8C00;stop-opacity:1" /%3E%3Cstop offset="100%25" style="stop-color:%23228B22;stop-opacity:1" /%3E%3C/linearGradient%3E%3C/defs%3E%3Crect width="100%25" height="100%25" fill="url(%23grad1)"/%3E%3C/svg%3E')`,
          backgroundSize: 'cover',
        }}
      >
        {/* Overlay con efecto de profundidad */}
        <div className="absolute inset-0 bg-gradient-to-br from-green-800/20 via-orange-600/20 to-green-800/20"></div>
        
        {/* Elementos decorativos abstractos que evocan el campo */}
        <div className="absolute inset-0">
          {/* Líneas verticales que evocan barra de crecimiento (como gráficos de campo) */}
          <div className="absolute left-0 top-0 w-1/4 h-full">
            <div className="h-full flex items-end">
              <div className="w-16 bg-orange-400/30 blur-xl h-3/4"></div>
            </div>
          </div>
          <div className="absolute right-0 top-0 w-1/4 h-full">
            <div className="h-full flex items-start">
              <div className="w-16 bg-green-400/30 blur-xl h-3/4"></div>
            </div>
          </div>
          
          {/* Círculos difuminados que evocan el atardecer */}
          <div className="absolute top-1/4 right-1/4 w-64 h-64 bg-orange-300/20 rounded-full blur-3xl"></div>
          <div className="absolute bottom-1/4 left-1/4 w-96 h-96 bg-green-300/20 rounded-full blur-3xl"></div>
        </div>
      </div>

      {/* Formulario de login centrado */}
      <div className="relative z-10 w-full max-w-md px-6">
        <div className="bg-white rounded-2xl shadow-2xl p-8 backdrop-blur-sm">
          {/* Logo ESCASAN */}
          <div className="text-center mb-8">
            {/* Texto ESCASAN */}
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-green-600 tracking-tight">ESCASAN</h1>
              <p className="text-xs text-gray-500 mt-0.5">Escalante Sánchez S.A.</p>
            </div>
            
            {/* Título */}
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              Ingrese a su cuenta
            </h2>
            <p className="text-sm text-gray-600">
              Introduzca sus credenciales a continuación
            </p>
          </div>

          {/* Formulario */}
          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Campo Usuario */}
            <div className="space-y-2">
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <input
                  id="login"
                  name="login"
                  type="text"
                  required
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all"
                  placeholder="admin"
                  value={formData.login}
                  onChange={handleChange}
                />
              </div>
            </div>

            {/* Campo Password */}
            <div className="space-y-2">
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <input
                  id="password"
                  name="password"
                  type="password"
                  required
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all"
                  placeholder="Password"
                  value={formData.password}
                  onChange={handleChange}
                />
              </div>
            </div>

            {/* Error message */}
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-600 text-sm rounded-lg p-3">
                {error}
              </div>
            )}

            {/* Botón Ingresar */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white font-semibold py-3 px-6 rounded-lg shadow-lg transform transition-all duration-200 hover:scale-105 hover:shadow-xl focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center space-x-2"
            >
              <span>{loading ? 'Ingresando...' : 'Ingresar'}</span>
              {!loading && (
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                </svg>
              )}
            </button>
          </form>

          {/* Enlace "¿Se te olvidó tu contraseña?" */}
          <div className="mt-6 text-center">
            <a 
              href="#" 
              className="text-sm text-green-600 hover:text-green-700 font-medium transition-colors"
            >
              ¿Se te olvidó tu contraseña?
            </a>
          </div>

          {/* Información de demo */}
          <div className="mt-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
            <p className="text-xs text-gray-600 text-center">
              <strong className="text-gray-700">Usuario demo:</strong> admin | 
              <strong className="text-gray-700 ml-2">Contraseña:</strong> admin123
            </p>
          </div>
        </div>

        {/* Slogan de Escasan en la parte inferior */}
        <div className="mt-8 text-center">
          <p className="text-white text-sm font-medium drop-shadow-lg">
            <span className="italic text-orange-100">Potenciando el</span>{' '}
            <span className="font-bold text-green-100">CAMPO Y LA GANADERÍA</span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
