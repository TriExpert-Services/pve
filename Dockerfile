FROM php:8.1-apache

# Paquetes de sistema para extensiones comunes
RUN apt-get update && apt-get install -y \
    libzip-dev libpng-dev libjpeg-dev libonig-dev libicu-dev \
  && rm -rf /var/lib/apt/lists/*

# Habilitar módulos de Apache usados por Proxmoxrobo (.htaccess, headers)
RUN a2enmod rewrite headers

# Instalar extensiones PHP necesarias (incluye PDO MySQL)
RUN docker-php-ext-configure gd --with-jpeg=/usr \
  && docker-php-ext-install -j$(nproc) \
     pdo_mysql mysqli gd zip mbstring intl

# Quitar el warning AH00558 de Apache
RUN echo "ServerName service.triexpertservice.com" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername

# Asegurar DirectoryIndex y permitir .htaccess en el webroot
RUN echo "DirectoryIndex index.php index.html" > /etc/apache2/conf-available/dirindex.conf \
 && a2enconf dirindex \
 && printf '%s\n' \
    '<Directory /var/www/html>' \
    '  AllowOverride All' \
    '  Require all granted' \
    '</Directory>' \
   > /etc/apache2/conf-available/override.conf \
 && a2enconf override

# Copia del código al webroot
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
