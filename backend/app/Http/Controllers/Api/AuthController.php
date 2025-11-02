<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Usuario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
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
            throw ValidationException::withMessages([
                'usuario' => ['Las credenciales proporcionadas son incorrectas.'],
            ]);
        }

        if (!$usuario->activo) {
            throw ValidationException::withMessages([
                'usuario' => ['El usuario está desactivado.'],
            ]);
        }

        // Actualizar último login
        $usuario->update(['ultimo_login' => now()]);

        // Crear token
        $token = $usuario->createToken('auth-token')->plainTextToken;

        return response()->json([
            'usuario' => $usuario->load('rol'),
            'token' => $token,
            'message' => 'Login exitoso'
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout exitoso'
        ]);
    }

    public function me(Request $request)
    {
        $usuario = $request->user()->load('rol');
        
        return response()->json([
            'usuario' => $usuario
        ]);
    }
}