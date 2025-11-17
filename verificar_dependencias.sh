#!/bin/bash
# Script de Verificación de Dependencias - WMS v9
# Linux/macOS

echo ""
echo "========================================"
echo "  VERIFICACIÓN DE DEPENDENCIAS WMS v9"
echo "========================================"
echo ""

ERRORES=()
ADVERTENCIAS=()

# 1. Verificar PHP
echo "1. PHP:"
if command -v php &> /dev/null; then
    PHP_VERSION=$(php -v | head -n 1 | grep -oP 'PHP \K\d+\.\d+' || echo "0")
    PHP_MAJOR=$(echo $PHP_VERSION | cut -d. -f1)
    PHP_MINOR=$(echo $PHP_VERSION | cut -d. -f2)
    
    if [ "$PHP_MAJOR" -ge 8 ] && [ "$PHP_MINOR" -ge 2 ]; then
        echo "   ✅ PHP $PHP_VERSION instalado"
    else
        echo "   ⚠️  PHP $PHP_VERSION instalado (requiere 8.2+)"
        ADVERTENCIAS+=("PHP versión $PHP_VERSION es menor a la requerida (8.2+)")
    fi
else
    echo "   ❌ PHP no encontrado"
    ERRORES+=("PHP no está instalado o no está en el PATH")
fi

# 2. Verificar Extensiones PHP
echo ""
echo "2. Extensiones PHP:"
REQUIRED_EXTENSIONS=("pdo" "pdo_sqlsrv" "sqlsrv" "curl" "mbstring" "openssl" "xml" "bcmath" "fileinfo")
INSTALLED_EXTENSIONS=$(php -m)

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if echo "$INSTALLED_EXTENSIONS" | grep -q "$ext"; then
        echo "   ✅ $ext"
    else
        echo "   ❌ $ext (NO INSTALADO)"
        ERRORES+=("Extensión PHP '$ext' no está instalada")
    fi
done

# 3. Verificar Composer
echo ""
echo "3. Composer:"
if command -v composer &> /dev/null; then
    COMPOSER_VERSION=$(composer --version | grep -oP 'Composer version \K\d+' || echo "0")
    echo "   ✅ Composer $COMPOSER_VERSION instalado"
else
    echo "   ❌ Composer no encontrado"
    ERRORES+=("Composer no está instalado o no está en el PATH")
fi

# 4. Verificar Node.js
echo ""
echo "4. Node.js:"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | sed 's/v//')
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d. -f1)
    
    if [ "$NODE_MAJOR" -ge 18 ]; then
        echo "   ✅ Node.js v$NODE_VERSION instalado"
    else
        echo "   ⚠️  Node.js v$NODE_VERSION instalado (requiere 18+)"
        ADVERTENCIAS+=("Node.js versión $NODE_VERSION es menor a la requerida (18+)")
    fi
else
    echo "   ❌ Node.js no encontrado"
    ERRORES+=("Node.js no está instalado o no está en el PATH")
fi

# 5. Verificar npm
echo ""
echo "5. npm:"
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "   ✅ npm $NPM_VERSION instalado"
else
    echo "   ❌ npm no encontrado"
    ERRORES+=("npm no está instalado")
fi

# 6. Verificar ODBC Driver
echo ""
echo "6. ODBC Driver 17 for SQL Server:"
if command -v odbcinst &> /dev/null; then
    ODBC_DRIVERS=$(odbcinst -q -d 2>&1)
    if echo "$ODBC_DRIVERS" | grep -q "ODBC Driver 17 for SQL Server"; then
        echo "   ✅ ODBC Driver 17 for SQL Server instalado"
    else
        echo "   ❌ ODBC Driver 17 for SQL Server no encontrado"
        ERRORES+=("ODBC Driver 17 for SQL Server no está instalado")
        echo "      Instalar con: sudo apt install msodbcsql17"
    fi
else
    echo "   ⚠️  No se pudo verificar ODBC Driver"
    ADVERTENCIAS+=("No se pudo verificar ODBC Driver (puede estar instalado)")
fi

# 7. Verificar SQL Server (conexión)
echo ""
echo "7. SQL Server:"
if command -v sqlcmd &> /dev/null; then
    echo "   ✅ sqlcmd disponible"
else
    echo "   ⚠️  sqlcmd no encontrado (opcional para verificación)"
    ADVERTENCIAS+=("sqlcmd no está instalado (opcional)")
fi

# 8. Verificar estructura del proyecto
echo ""
echo "8. Estructura del Proyecto:"
PROJECT_FILES=("backend" "frontend" "backend/composer.json" "frontend/package.json")

for file in "${PROJECT_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file (NO ENCONTRADO)"
        ERRORES+=("Archivo/Carpeta '$file' no encontrado")
    fi
done

# Resumen
echo ""
echo "========================================"
echo "  RESUMEN"
echo "========================================"
echo ""

if [ ${#ERRORES[@]} -eq 0 ] && [ ${#ADVERTENCIAS[@]} -eq 0 ]; then
    echo "✅ Todas las dependencias están instaladas correctamente!"
    exit 0
else
    if [ ${#ERRORES[@]} -gt 0 ]; then
        echo "❌ ERRORES ENCONTRADOS (${#ERRORES[@]}):"
        for error in "${ERRORES[@]}"; do
            echo "   - $error"
        done
    fi
    
    if [ ${#ADVERTENCIAS[@]} -gt 0 ]; then
        echo ""
        echo "⚠️  ADVERTENCIAS (${#ADVERTENCIAS[@]}):"
        for warning in "${ADVERTENCIAS[@]}"; do
            echo "   - $warning"
        done
    fi
    
    echo ""
    echo "📖 Consulta REQUISITOS_INSTALACION.md para más información"
    exit 1
fi

