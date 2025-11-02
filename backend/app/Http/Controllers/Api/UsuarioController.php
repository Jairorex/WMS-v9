<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Usuario;
use App\Models\Rol;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UsuarioController extends Controller
{
    public function index(Request $request)
    {
        $query = Usuario::with('rol');

        // Filtros
        if ($request->filled('q')) {
            $search = $request->q;
            $query->where(function($q) use ($search) {
                $q->where('nombre', 'like', "%{$search}%")
                  ->orWhere('usuario', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($request->filled('rol')) {
            $query->where('rol_id', $request->rol);
        }

        if ($request->filled('activo')) {
            $query->where('activo', $request->boolean('activo'));
        }

        $usuarios = $query->orderBy('nombre')->get();

        return response()->json([
            'data' => $usuarios
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'usuario' => 'required|string|max:50|unique:wms.usuarios,usuario',
            'email' => 'required|email|max:255|unique:wms.usuarios,email',
            'password' => 'required|string|min:6',
            'rol_id' => 'required|exists:roles,id_rol',
            'activo' => 'boolean',
        ]);

        $usuario = Usuario::create([
            'nombre' => $request->nombre,
            'usuario' => $request->usuario,
            'email' => $request->email,
            'contrasena' => Hash::make($request->password),
            'rol_id' => $request->rol_id,
            'activo' => $request->boolean('activo', true),
        ]);

        return response()->json([
            'data' => $usuario->load('rol'),
            'message' => 'Usuario creado exitosamente'
        ], 201);
    }

    public function show(Usuario $usuario)
    {
        return response()->json([
            'data' => $usuario->load('rol')
        ]);
    }

    public function update(Request $request, Usuario $usuario)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'usuario' => ['required', 'string', 'max:50', Rule::unique('usuarios', 'usuario')->ignore($usuario->id_usuario, 'id_usuario')],
            'email' => ['required', 'email', 'max:255', Rule::unique('usuarios', 'email')->ignore($usuario->id_usuario, 'id_usuario')],
            'password' => 'nullable|string|min:6',
            'rol_id' => 'required|exists:roles,id_rol',
            'activo' => 'boolean',
        ]);

        $data = [
            'nombre' => $request->nombre,
            'usuario' => $request->usuario,
            'email' => $request->email,
            'rol_id' => $request->rol_id,
            'activo' => $request->boolean('activo', true),
        ];

        if ($request->filled('password')) {
            $data['contrasena'] = Hash::make($request->password);
        }

        $usuario->update($data);

        return response()->json([
            'data' => $usuario->load('rol'),
            'message' => 'Usuario actualizado exitosamente'
        ]);
    }

    public function destroy(Usuario $usuario)
    {
        $usuario->delete();

        return response()->json([
            'message' => 'Usuario eliminado exitosamente'
        ]);
    }

    public function toggleStatus(Usuario $usuario)
    {
        $usuario->update(['activo' => !$usuario->activo]);

        return response()->json([
            'data' => $usuario->load('rol'),
            'message' => $usuario->activo ? 'Usuario activado exitosamente' : 'Usuario desactivado exitosamente'
        ]);
    }

    public function catalogos()
    {
        $roles = Rol::all();

        return response()->json([
            'roles' => $roles
        ]);
    }
}
