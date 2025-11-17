# Dockerfile para Railway con soporte para SQL Server
# Este Dockerfile debe estar en la raíz del proyecto para que Railway lo detecte
FROM php:8.2-cli

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    gnupg \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar Microsoft ODBC Driver para SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP para SQL Server
RUN pecl install sqlsrv pdo_sqlsrv-5.12.0 \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv \
    && echo "extension=sqlsrv.so" > /usr/local/etc/php/conf.d/sqlsrv.ini \
    && echo "extension=pdo_sqlsrv.so" > /usr/local/etc/php/conf.d/pdo_sqlsrv.ini

# Instalar otras extensiones PHP necesarias
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de composer del backend
COPY backend/composer.json backend/composer.lock ./

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Copiar el resto de los archivos del backend
COPY backend/ .

# Configurar permisos
RUN chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Exponer puerto (Railway usa variable de entorno PORT)
EXPOSE $PORT

# Comando para iniciar el servidor (Railway proporciona PORT como variable de entorno)
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}

