FROM composer:latest

RUN addgroup -g 1001 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

WORKDIR /var/www/html

USER laravel

ENTRYPOINT [ "composer", "--ignore-platform-reqs" ]

# Dedicated container for running Composer commands
# - Same user setup as PHP container
# - Used for: composer install, require, update