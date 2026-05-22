ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-apache AS build

# System dependencies
RUN apt-get update && apt-get install -y \
    nano \
    unzip \
    libzip-dev \
    zip \
    libicu-dev \
    libxml2-dev \
    libmagickwand-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# PECL extensions (Imagick, Xdebug, Redis)
RUN pecl install xdebug-3.3.1 imagick redis \
    && rm -r /tmp/pear/* \
    && docker-php-ext-enable imagick xdebug redis

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        bcmath \
        soap \
        opcache \
        pdo_mysql \
        mysqli \
        zip

# Download and install selected shop version
ARG JTL_VERSION
WORKDIR /var/www/html
ADD https://build.jtl-shop.de/get/shop-${JTL_VERSION}.zip .
RUN unzip shop-${JTL_VERSION}.zip \
    && rm shop-${JTL_VERSION}.zip \
    && chown www-data:www-data . -R

# Store shop files in a template directory for entrypoint to copy into the mounted volume
RUN cp -a /var/www/html/. /var/www/html-template/

# COPY JTL php.ini
COPY php.ini "$PHP_INI_DIR/php.ini"

# COPY XDEBUG INI
COPY xdebug.ini "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"

# COPY entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ENABLE apache mod_rewrite
RUN a2enmod rewrite

ENTRYPOINT ["/entrypoint.sh"]