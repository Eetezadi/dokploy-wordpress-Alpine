#!/bin/bash
set -e

# Graceful shutdown handler
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Shutting down gracefully..."
    if [ -n "$PHP_FPM_PID" ]; then
        kill -TERM "$PHP_FPM_PID" 2>/dev/null || true
        wait "$PHP_FPM_PID" 2>/dev/null || true
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Shutdown complete"
    exit 0
}

# Register signal handlers
trap cleanup SIGTERM SIGINT

# Generate PHP configuration from environment variables
PHP_INI_DIR="/usr/local/etc/php/conf.d"

# Create custom PHP settings
cat > "${PHP_INI_DIR}/custom-settings.ini" << EOF
; Custom PHP Settings - Configurable via Environment Variables
upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE:-256M}
post_max_size = ${PHP_POST_MAX_SIZE:-256M}
memory_limit = ${PHP_MEMORY_LIMIT:-512M}
max_execution_time = ${PHP_MAX_EXECUTION_TIME:-300}
max_input_time = ${PHP_MAX_INPUT_TIME:-300}
max_input_vars = ${PHP_MAX_INPUT_VARS:-3000}
EOF

# Create OPcache configuration
cat > "${PHP_INI_DIR}/opcache-settings.ini" << EOF
; OPcache Settings - Configurable via Environment Variables
opcache.enable = 1
opcache.memory_consumption = ${PHP_OPCACHE_MEMORY:-128}
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = ${PHP_OPCACHE_MAX_FILES:-4000}
opcache.validate_timestamps = ${PHP_OPCACHE_VALIDATE:-0}
opcache.revalidate_freq = 60
opcache.fast_shutdown = 1
opcache.enable_cli = 0
EOF

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] PHP settings configured:"
echo "  upload_max_filesize: ${PHP_UPLOAD_MAX_FILESIZE:-256M}"
echo "  post_max_size: ${PHP_POST_MAX_SIZE:-256M}"
echo "  memory_limit: ${PHP_MEMORY_LIMIT:-512M}"
echo "  max_execution_time: ${PHP_MAX_EXECUTION_TIME:-300}s"
echo "  OPcache memory: ${PHP_OPCACHE_MEMORY:-128}MB"

# Validate PHP-FPM configuration
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Validating PHP-FPM configuration..."
if ! php-fpm -t 2>&1 | grep -q "test is successful"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] PHP-FPM configuration test failed"
    php-fpm -t
    exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] PHP-FPM configuration is valid"

# Initialize WordPress files (call original entrypoint for setup)
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Initializing WordPress files..."
docker-entrypoint.sh php-fpm -t

# Inject custom wp-config.php modifications for dynamic domain handling
if [ -f /var/www/html/wp-config.php ]; then
    if ! grep -q "wp-config-custom.php" /var/www/html/wp-config.php; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Injecting custom configuration into wp-config.php..."
        sed -i "2i\\
// Custom configuration - Dynamic domain + Redis\\
require_once('/usr/local/share/wp-config-custom.php');\\
" /var/www/html/wp-config.php
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Custom configuration injected successfully"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Custom configuration already present"
    fi
fi

# Wait for database to be ready
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Checking database connectivity..."
DB_HOST="${WORDPRESS_DB_HOST:-db}"
MAX_TRIES=30
COUNT=0

while [ $COUNT -lt $MAX_TRIES ]; do
    if mysqladmin ping -h"$DB_HOST" --silent 2>/dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Database is ready"
        break
    fi
    COUNT=$((COUNT + 1))
    if [ $COUNT -eq $MAX_TRIES ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Database not ready after $MAX_TRIES attempts, proceeding anyway..."
        break
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Waiting for database... ($COUNT/$MAX_TRIES)"
    sleep 2
done

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Starting PHP-FPM..."

# Call the original WordPress entrypoint in background to capture PID
docker-entrypoint.sh "$@" &
PHP_FPM_PID=$!

# Wait for PHP-FPM process
wait $PHP_FPM_PID
