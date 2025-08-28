FROM php:8.1-apache

# Extensiones del sistema que ayudan a compilar/extensiones PHP
RUN apt-get update && apt-get install -y libzip-dev libpng-dev libjpeg-dev libicu-dev && rm -rf /var/lib/apt/lists/*

# Apache
RUN a2enmod rewrite headers
RUN echo "ServerName service.triexpertservice.com" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && echo "DirectoryIndex index.php index.html" > /etc/apache2/conf-available/dirindex.conf \
 && a2enconf dirindex \
 && printf '%s\n<Directory /var/www/html>\n  AllowOverride All\n  Require all granted\n</Directory>\n' > /etc/apache2/conf-available/override.conf \
 && a2enconf override

# PHP: habilita PDO MySQL y demás
RUN docker-php-ext-configure gd --with-jpeg=/usr \
 && docker-php-ext-install -j$(nproc) pdo_mysql mysqli gd zip intl mbstring
# (Alternativa más sencilla para extensiones: docker-php-extension-installer). :contentReference[oaicite:2]{index=2}

# Copia del código
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
