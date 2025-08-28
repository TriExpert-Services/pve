FROM php:8.1-apache

# PHP/extensiones que necesites
RUN docker-php-ext-install mysqli && a2enmod rewrite headers

# ServerName para silenciar AH00558
RUN echo "ServerName service.triexpertservice.com" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername

# DirectoryIndex válido
RUN echo "DirectoryIndex index.php index.html" > /etc/apache2/conf-available/dirindex.conf \
 && a2enconf dirindex

# Permitir .htaccess (si el proyecto lo usa)
RUN printf '%s\n' \
  '<Directory /var/www/html>' \
  '    AllowOverride All' \
  '    Require all granted' \
  '</Directory>' \
  > /etc/apache2/conf-available/override.conf \
 && a2enconf override

# Copia el **código del repo** al webroot
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
