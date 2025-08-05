FROM php:8.2-fpm-alpine

RUN addgroup -g 1001 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

RUN mkdir -p /var/www/html

RUN chown laravel:laravel /var/www/html

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

RUN apk add --no-cache zip unzip curl

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

USER laravel

# Creates PHP-FPM container with:
# - Laravel user (ID 1001) for security
# - PDO MySQL extensions for database connectivity
# - Composer for dependency management
# - Working directory: /var/www/html