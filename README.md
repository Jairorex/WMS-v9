# WMS v9 - Sistema de Gestión de Almacenes

Sistema completo de gestión de almacenes desarrollado con Laravel (Backend) y React (Frontend).

## Estructura del Proyecto

```
WMS-v9/
├── backend/          # API Laravel
├── frontend/         # Aplicación React
├── docs/             # Documentación (.md)
├── sql/              # Scripts SQL
└── README.md         # Este archivo
```

## Requisitos

- PHP >= 8.1
- Composer
- Node.js >= 16
- SQL Server
- Extensiones PHP: PDO, ODBC

## Instalación Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

Configurar `.env` con las credenciales de la base de datos.

## Instalación Frontend

```bash
cd frontend
npm install
npm run dev
```

## Licencia

Propietario - Escasan

