# Dokploy WordPress Stack

Production-ready WordPress deployment stack optimized for Dokploy with Redis caching, Nginx, and management tools.

## Stack Components

| Service | Description |
|---------|-------------|
| **WordPress** | PHP 8.3 FPM with Redis extension, OPcache, and WP-CLI |
| **Nginx** | Optimized reverse proxy with caching and security headers |
| **MySQL 9.4** | Database server with health checks |
| **Redis 8** | Object caching for improved performance |
| **phpMyAdmin** | Database administration interface |

## Features

**Performance**
- Redis object caching with pre-configured WordPress integration
- PHP OPcache enabled for opcode caching
- Gzip compression for text assets
- Static asset caching (30 days)
- Auto CPU detection for Nginx workers

**Security**
- Security headers (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)
- Nginx version hidden
- Blocked: PHP uploads, xmlrpc.php, wp-config.php access, hidden files
- Health checks on all containers

**Operations**
- Dynamic domain detection (no hardcoded URLs)
- All settings configurable via environment variables (no rebuild needed)
- Graceful shutdown handling (SIGTERM)
- Database connectivity checks on startup
- Configuration validation before start
- WP-CLI pre-installed

## Quick Start

1. Create a new **Compose** service in Dokploy
2. Point to: `https://github.com/Eetezadi/dokploy-wordpress-Alpine`
3. Set Compose Path: `./docker-compose.yml`
4. Go to **Environment** tab and add:
   ```
   MYSQL_ROOT_PASSWORD=YourSecureRootPass123!
   MYSQL_PASSWORD=YourSecureDbPass456!
   WORDPRESS_DB_PASSWORD=YourSecureDbPass456!
   ```
5. Click **Deploy**

### Configure Domains

Go to the **Domains** tab and add:

| Domain | Service | Port |
|--------|---------|------|
| yourdomain.com | nginx | 80 |
| pma.yourdomain.com | phpmyadmin | 80 |

**Default Credentials:**
| Service | Username | Password |
|---------|----------|----------|
| phpMyAdmin | wordpress | (your MYSQL_PASSWORD) |

### Activate Redis Cache

1. Log in to WordPress admin (`yourdomain.com/wp-admin`)
2. Go to **Plugins > Installed Plugins**
3. Activate **Redis Object Cache**
4. Go to **Settings > Redis**
5. Click **Enable Object Cache**

## Environment Variables

All environment variables can be changed at any time and take effect on redeploy without requiring a container rebuild.

### Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | - | **Required.** MySQL root password |
| `MYSQL_DATABASE` | wordpress | Database name |
| `MYSQL_USER` | wordpress | Database user |
| `MYSQL_PASSWORD` | - | **Required.** Database password |
| `WORDPRESS_DB_HOST` | db | Database host |
| `WORDPRESS_DB_USER` | wordpress | WordPress database user |
| `WORDPRESS_DB_PASSWORD` | - | **Required.** WordPress database password |
| `WORDPRESS_DB_NAME` | wordpress | WordPress database name |

### PHP & Performance Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_UPLOAD_MAX_FILESIZE` | 256M | Maximum upload file size |
| `PHP_POST_MAX_SIZE` | 256M | Maximum POST data size |
| `PHP_MEMORY_LIMIT` | 512M | PHP memory limit |
| `PHP_MAX_EXECUTION_TIME` | 300 | Script timeout in seconds |
| `PHP_MAX_INPUT_TIME` | 300 | Input parsing timeout |
| `PHP_MAX_INPUT_VARS` | 3000 | Maximum input variables |
| `PHP_OPCACHE_MEMORY` | 128 | OPcache memory in MB |
| `PHP_OPCACHE_MAX_FILES` | 4000 | Maximum cached files |
| `PHP_OPCACHE_VALIDATE` | 0 | Validate timestamps (0=off for production) |

### Nginx Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_CLIENT_MAX_BODY_SIZE` | 256M | Maximum upload size in Nginx |

### Redis Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_MAXMEMORY` | 256mb | Redis maximum memory |
| `REDIS_MAXMEMORY_POLICY` | allkeys-lru | Eviction policy |

### Resource Limits

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_CPU_LIMIT` | 0.5 | Nginx CPU limit |
| `NGINX_MEMORY_LIMIT` | 256M | Nginx memory limit |
| `WORDPRESS_CPU_LIMIT` | 1.0 | WordPress CPU limit |
| `WORDPRESS_MEMORY_LIMIT` | 1G | WordPress memory limit |
| `DB_CPU_LIMIT` | 1.0 | MySQL CPU limit |
| `DB_MEMORY_LIMIT` | 1G | MySQL memory limit |
| `REDIS_CPU_LIMIT` | 0.5 | Redis CPU limit |
| `REDIS_MEMORY_LIMIT` | 512M | Redis memory limit |
| `PHPMYADMIN_CPU_LIMIT` | 0.5 | phpMyAdmin CPU limit |
| `PHPMYADMIN_MEMORY_LIMIT` | 256M | phpMyAdmin memory limit |

## Volumes

| Volume | Purpose |
|--------|---------|
| `wordpress_data` | WordPress files (/var/www/html) |
| `db_data` | MySQL data |
| `redis_data` | Redis persistence |

## Security Recommendations

1. Set strong passwords for all database credentials
2. Consider restricting access to phpMyAdmin subdomain
3. Enable Dokploy's built-in SSL/TLS
4. Keep WordPress and plugins updated

## License

MIT
