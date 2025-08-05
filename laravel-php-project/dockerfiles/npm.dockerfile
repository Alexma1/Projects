FROM node:current-alpine

RUN addgroup -g 1001 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

WORKDIR /var/www/html

USER laravel

# Node.js container for frontend tooling
# - Used for: npm install, build, dev scripts
# - Handles Vite, Tailwind CSS compilation