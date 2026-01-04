FROM wordpress:6-php8.3-fpm-alpine

# Install dependencies (Alpine packages)
# NOTE: curl is needed for WP-CLI download, fcgi for healthcheck
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    unzip \
    wget \
    curl \
    fcgi \
    bash

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip opcache

# Install Redis extension (with virtual build deps for cleanup)
RUN apk add --no-cache --virtual .build-deps autoconf gcc g++ make \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Enable PHP-FPM status page for healthcheck
RUN echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Copy configurations
COPY wp-config-custom.php /usr/local/share/wp-config-custom.php
COPY docker-entrypoint-custom.sh /usr/local/bin/docker-entrypoint-custom.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

# Set proper permissions
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["php-fpm"]
