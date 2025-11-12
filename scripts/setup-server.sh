#!/bin/bash
# Script de Configuración Inicial del Servidor - WMS v9
# Ejecutar como root: sudo bash setup-server.sh

set -e

echo "🖥️  Configurando servidor para WMS v9..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
apt update && apt upgrade -y

# Instalar herramientas básicas
echo "📦 Instalando herramientas básicas..."
apt install -y curl wget git unzip software-properties-common \
    build-essential openssl ufw

# Configurar Firewall
echo "🔥 Configurando firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Instalar PHP 8.2
echo "🐘 Instalando PHP 8.2..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-cli php8.2-fpm php8.2-common \
    php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring \
    php8.2-curl php8.2-xml php8.2-bcmath php8.2-pdo \
    php8.2-sqlite3 php8.2-redis

# Instalar drivers SQL Server
echo "🗄️  Instalando drivers SQL Server..."
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | \
    tee /etc/apt/sources.list.d/mssql-release.list
apt update
ACCEPT_EULA=Y apt install -y msodbcsql17 unixodbc-dev

# Instalar extensiones PHP SQL Server
echo "📦 Instalando extensiones PHP SQL Server..."
pecl install sqlsrv pdo_sqlsrv <<< ""

# Habilitar extensiones
echo "extension=sqlsrv.so" >> /etc/php/8.2/fpm/php.ini
echo "extension=pdo_sqlsrv.so" >> /etc/php/8.2/fpm/php.ini
echo "extension=sqlsrv.so" >> /etc/php/8.2/cli/php.ini
echo "extension=pdo_sqlsrv.so" >> /etc/php/8.2/cli/php.ini

# Instalar Composer
echo "📦 Instalando Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Instalar Node.js
echo "📦 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Instalar Nginx
echo "🌐 Instalando Nginx..."
apt install -y nginx

# Instalar Redis
echo "📦 Instalando Redis..."
apt install -y redis-server
systemctl enable redis-server
systemctl start redis-server

# Instalar Supervisor
echo "📦 Instalando Supervisor..."
apt install -y supervisor

# Instalar Certbot (Let's Encrypt)
echo "🔒 Instalando Certbot..."
apt install -y certbot python3-certbot-nginx

# Crear usuario para aplicación
echo "👤 Creando usuario de aplicación..."
if ! id "wmsuser" &>/dev/null; then
    adduser --disabled-password --gecos "" wmsuser
    usermod -aG sudo wmsuser
fi

# Crear directorio de aplicación
echo "📁 Creando directorios..."
mkdir -p /var/www/wms
mkdir -p /backups/wms
chown -R wmsuser:wmsuser /var/www/wms
chown -R wmsuser:wmsuser /backups/wms

# Configurar PHP-FPM
echo "⚙️  Configurando PHP-FPM..."
sed -i 's/;pm.max_children = 5/pm.max_children = 50/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/;pm.start_servers = 2/pm.start_servers = 10/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/;pm.min_spare_servers = 1/pm.min_spare_servers = 5/' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/;pm.max_spare_servers = 3/pm.max_spare_servers = 20/' /etc/php/8.2/fpm/pool.d/www.conf

# Reiniciar servicios
echo "🔄 Reiniciando servicios..."
systemctl restart php8.2-fpm
systemctl restart nginx
systemctl enable php8.2-fpm
systemctl enable nginx

echo "✅ Configuración del servidor completada!"
echo ""
echo "📝 Próximos pasos:"
echo "1. Clonar repositorio en /var/www/wms"
echo "2. Configurar archivo .env en backend"
echo "3. Ejecutar: composer install y npm install"
echo "4. Configurar Nginx (ver GUIA_DESPLIGUE_PRODUCCION.md)"
echo "5. Configurar SSL con Certbot"

