<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use App\Models\Usuario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    use ApiResponse;

    public function login(Request $request)
    {
        $request->validate([
            'usuario' => 'required|string',
            'password' => 'required|string',
        ]);

        $usuario = Usuario::where('usuario', $request->usuario)
                         ->orWhere('email', $request->usuario)
                         ->first();

        if (!$usuario || !Hash::check($request->password, $usuario->contrasena)) {
            return $this->errorResponse(
                'Las credenciales proporcionadas son incorrectas.',
                ['usuario' => ['Las credenciales proporcionadas son incorrectas.']],
                401
            );
        }

        if (!$usuario->activo) {
            return $this->errorResponse(
                'El usuario está desactivado.',
                ['usuario' => ['El usuario está desactivado.']],
                403
            );
        }

        // Actualizar último login
        $usuario->update(['ultimo_login' => now()]);

        // Crear token
        $token = $usuario->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'usuario' => $usuario->load('rol'),
            'token' => $token,
        ], 'Login exitoso');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Logout exitoso');
    }

    public function me(Request $request)
    {
        $usuario = $request->user()->load('rol');
        
        return $this->successResponse([
            'usuario' => $usuario
        ], 'Usuario obtenido exitosamente');
    }
}