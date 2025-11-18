-- Script para agregar usuario admin2
-- Usuario: admin2
-- Contraseña: admin (hasheada con bcrypt)

-- Verificar si el usuario ya existe
IF EXISTS (SELECT 1 FROM wms.usuarios WHERE usuario = 'admin2')
BEGIN
    PRINT 'El usuario admin2 ya existe. Actualizando contraseña...';
    UPDATE wms.usuarios 
    SET contrasena = '$2y$10$/EO/ttHAl0GXkmQB454KRutseA6un9x.YID9PouTAHVy5GTqOg7ha',
        nombre = 'Administrador 2',
        email = 'admin2@wms.com',
        activo = 1,
        updated_at = SYSDATETIME()
    WHERE usuario = 'admin2';
    PRINT '✅ Usuario admin2 actualizado exitosamente';
END
ELSE
BEGIN
    PRINT 'Creando nuevo usuario admin2...';
    INSERT INTO wms.usuarios (nombre, usuario, contrasena, rol_id, email, activo, created_at, updated_at)
    VALUES (
        N'Administrador 2',
        N'admin2',
        N'$2y$10$/EO/ttHAl0GXkmQB454KRutseA6un9x.YID9PouTAHVy5GTqOg7ha', -- password: admin
        1, -- Rol Admin
        N'admin2@wms.com',
        1, -- Activo
        SYSDATETIME(),
        SYSDATETIME()
    );
    PRINT '✅ Usuario admin2 creado exitosamente';
END
GO

-- Verificar que el usuario fue creado
SELECT 
    id_usuario,
    nombre,
    usuario,
    email,
    rol_id,
    activo,
    created_at
FROM wms.usuarios
WHERE usuario = 'admin2';
GO

