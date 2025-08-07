You can choose docker compose up targeted services

docker compose up -d --build (any service in the compose file)
in the files you can use server since in the compose file there's dependencies


Docker Configuration Files
1. docker-compose.yml
Purpose: Orchestrates multiple Docker containers to create a complete development environment.

Services Defined:

server: Nginx web server (port 8000)
php: PHP-FPM container for processing PHP code
mysql: MySQL 8.0 database (port 3306)
composer: For PHP dependency management
artisan: Laravel's command-line interface
npm: Node.js for frontend asset management

2. dockerfiles/ Directory
# Creates PHP-FPM container with:
# - Laravel user (ID 1001) for security
# - PDO MySQL extensions for database connectivity
# - Composer for dependency management
# - Working directory: /var/www/html
php
# Dedicated container for running Composer commands
# - Same user setup as PHP container
# - Used for: composer install, require, update
composer
# Node.js container for frontend tooling
# - Used for: npm install, build, dev scripts
# - Handles Vite, Tailwind CSS compilation
npm

3. nginx/nginx.conf
Purpose: Nginx server configuration for Laravel.

Key Settings:

Listens on port 80 (mapped to 8000 externally)
Document root: /var/www/html/public (Laravel's public directory)
PHP-FPM integration via fastcgi_pass php:9000
Clean URL routing for Laravel
4. env/mysql.env
Purpose: MySQL environment variables for database configuration. Contains: Database credentials, root password, database name

Laravel Application Structure (src/ directory)
Root Configuration Files
src/composer.json & src/composer.lock

APP_NAME=Laravel
APP_ENV=local                    # Development environment
APP_KEY=base64:...              # Encryption key (auto-generated)
APP_DEBUG=true                  # Shows detailed errors in development

DB_CONNECTION=mysql             # Database driver
DB_HOST=mysql                   # Docker service name
DB_DATABASE=laravel            # Database name
DB_USERNAME=laravel            # Database user
DB_PASSWORD=secret             # Database password

SESSION_DRIVER=database        # Store sessions in database
CACHE_STORE=database          # Use database for caching
QUEUE_CONNECTION=database     # Queue jobs in database


Purpose: PHP dependency management.

Defines Laravel framework version
Lists required packages (database, validation, etc.)
Lock file ensures consistent package versions
src/package.json
Purpose: Node.js dependency management for frontend assets.


# Start all services
docker-compose up -d

# Install PHP dependencies
docker-compose run --rm composer install

# Run database migrations
docker-compose run --rm artisan migrate

# Install Node.js dependencies
docker-compose run --rm npm install

# Build frontend assets
docker-compose run --rm npm run build

# Access the application
http://localhost:8000

# Artisan COmmands

# Create a controller
docker-compose run --rm artisan make:controller UserController

# Create a migration
docker-compose run --rm artisan make:migration create_posts_table

# Clear cache
docker-compose run --rm artisan cache:clear

# Generate application key
docker-compose run --rm artisan key:generate