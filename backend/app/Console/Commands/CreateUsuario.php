<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Usuario;
use Illuminate\Support\Facades\Hash;

class CreateUsuario extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'usuario:create {nombre} {usuario} {password} {--rol=1} {--email=}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Crear un nuevo usuario en el sistema';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $nombre = $this->argument('nombre');
        $usuario = $this->argument('usuario');
        $password = $this->argument('password');
        $rolId = $this->option('rol');
        $email = $this->option('email') ?: $usuario . '@wms.com';

        // Verificar si el usuario ya existe
        if (Usuario::where('usuario', $usuario)->exists()) {
            $this->error("El usuario '{$usuario}' ya existe.");
            return 1;
        }

        try {
            $nuevoUsuario = Usuario::create([
                'nombre' => $nombre,
                'usuario' => $usuario,
                'contrasena' => Hash::make($password),
                'rol_id' => $rolId,
                'email' => $email,
                'activo' => true,
            ]);

            $this->info("✅ Usuario '{$usuario}' creado exitosamente!");
            $this->line("   ID: {$nuevoUsuario->id_usuario}");
            $this->line("   Nombre: {$nuevoUsuario->nombre}");
            $this->line("   Usuario: {$nuevoUsuario->usuario}");
            $this->line("   Email: {$nuevoUsuario->email}");
            $this->line("   Rol ID: {$nuevoUsuario->rol_id}");

            return 0;
        } catch (\Exception $e) {
            $this->error("Error al crear el usuario: " . $e->getMessage());
            return 1;
        }
    }
}
