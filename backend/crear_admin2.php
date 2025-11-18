<?php

/**
 * Script para crear usuario admin2
 * Ejecutar desde la raíz del proyecto: php backend/crear_admin2.php
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Usuario;
use Illuminate\Support\Facades\Hash;

try {
    // Verificar si el usuario ya existe
    $usuarioExistente = Usuario::where('usuario', 'admin2')->first();
    
    if ($usuarioExistente) {
        echo "⚠️  El usuario 'admin2' ya existe. Actualizando contraseña...\n";
        
        $usuarioExistente->update([
            'contrasena' => Hash::make('admin'),
            'nombre' => 'Administrador 2',
            'email' => 'admin2@wms.com',
            'activo' => true,
        ]);
        
        echo "✅ Usuario 'admin2' actualizado exitosamente!\n";
        echo "   ID: {$usuarioExistente->id_usuario}\n";
        echo "   Nombre: {$usuarioExistente->nombre}\n";
        echo "   Usuario: {$usuarioExistente->usuario}\n";
        echo "   Email: {$usuarioExistente->email}\n";
        echo "   Rol ID: {$usuarioExistente->rol_id}\n";
    } else {
        echo "📝 Creando nuevo usuario 'admin2'...\n";
        
        $nuevoUsuario = Usuario::create([
            'nombre' => 'Administrador 2',
            'usuario' => 'admin2',
            'contrasena' => Hash::make('admin'),
            'rol_id' => 1, // Rol Admin
            'email' => 'admin2@wms.com',
            'activo' => true,
        ]);
        
        echo "✅ Usuario 'admin2' creado exitosamente!\n";
        echo "   ID: {$nuevoUsuario->id_usuario}\n";
        echo "   Nombre: {$nuevoUsuario->nombre}\n";
        echo "   Usuario: {$nuevoUsuario->usuario}\n";
        echo "   Email: {$nuevoUsuario->email}\n";
        echo "   Rol ID: {$nuevoUsuario->rol_id}\n";
    }
    
    echo "\n📋 Credenciales:\n";
    echo "   Usuario: admin2\n";
    echo "   Contraseña: admin\n";
    
} catch (\Exception $e) {
    echo "❌ Error al crear/actualizar el usuario: " . $e->getMessage() . "\n";
    echo "   Archivo: " . $e->getFile() . "\n";
    echo "   Línea: " . $e->getLine() . "\n";
    exit(1);
}

