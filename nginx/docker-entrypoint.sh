#!/bin/sh
set -e

# Graceful shutdown handler
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Shutting down Nginx gracefully..."
    nginx -s quit 2>/dev/null || true
    exit 0
}

# Register signal handlers
trap cleanup SIGTERM SIGINT

# Set default values if not set
export NGINX_CLIENT_MAX_BODY_SIZE="${NGINX_CLIENT_MAX_BODY_SIZE:-256M}"
export SERVED_BY="${SERVED_BY:-Dokploy-Wordpress}"

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Nginx configuration:"
echo "  client_max_body_size: ${NGINX_CLIENT_MAX_BODY_SIZE}"
echo "  served_by: ${SERVED_BY}"

# Ensure template exists
if [ ! -f /etc/nginx/templates/default.conf.template ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Template file not found: /etc/nginx/templates/default.conf.template"
    exit 1
fi

# Process the template and generate the actual config
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Generating Nginx configuration from template..."
envsubst '${NGINX_CLIENT_MAX_BODY_SIZE} ${SERVED_BY}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Validate Nginx configuration
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Validating Nginx configuration..."
if ! nginx -t 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Nginx configuration test failed"
    exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Nginx configuration is valid"

# Wait for WordPress PHP-FPM to be ready
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Waiting for WordPress PHP-FPM to be ready..."
MAX_TRIES=30
COUNT=0

while [ $COUNT -lt $MAX_TRIES ]; do
    if nc -z wordpress 9000 2>/dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] WordPress PHP-FPM is ready"
        break
    fi
    COUNT=$((COUNT + 1))
    if [ $COUNT -eq $MAX_TRIES ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] WordPress PHP-FPM not ready after $MAX_TRIES attempts, proceeding anyway..."
        break
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Waiting for WordPress... ($COUNT/$MAX_TRIES)"
    sleep 2
done

echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Starting Nginx..."

# Execute the main command
exec "$@"
