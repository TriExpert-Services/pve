FROM php:8.1-apache

# Paquetes necesarios para compilar/extensiones PHP
RUN apt-get update && apt-get install -y \
    pkg-config \
    libonig-dev \ 
    libzip-dev \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
 && rm -rf /var/lib/apt/lists/*

# Apache
RUN a2enmod rewrite headers \
 && echo "ServerName service.triexpertservice.com" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && echo "DirectoryIndex index.php index.html" > /etc/apache2/conf-available/dirindex.conf \
 && a2enconf dirindex \
 && printf '%s\n<Directory /var/www/html>\n  AllowOverride All\n  Require all granted\n</Directory>\n' > /etc/apache2/conf-available/override.conf \
 && a2enconf override

# Extensiones PHP: gd (jpeg/freetype), intl, zip, mysqli/pdo_mysql, mbstring
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" \
      gd intl zip mysqli pdo_mysql mbstring

# Código
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

