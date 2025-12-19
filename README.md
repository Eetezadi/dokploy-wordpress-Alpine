# Dokploy WordPress Stack

Production-ready WordPress deployment stack optimized for Dokploy with Redis caching, Nginx, and management tools.

## Stack Components

| Service | Description |
|---------|-------------|
| **WordPress** | PHP 8.3 FPM with Redis extension, OPcache, and WP-CLI |
| **Nginx** | Optimized reverse proxy with caching and security headers |
| **MariaDB 10.6** | Database server with health checks |
| **Redis** | Object caching for improved performance |
| **FileBrowser** | Web-based file manager |
| **phpMyAdmin** | Database administration interface |
| **Plugin Installer** | Automatically installs Redis Object Cache plugin |

## Quick Start

### 1. Create a Compose Service in Dokploy

1. Go to your Dokploy dashboard
2. Create a new project (or use existing)
3. Add a new **Compose** service
4. Set the **Compose Path** to `./docker-compose.yml`
5. Point to this repository (or upload the files)

### 2. Deploy

Click **Deploy** - passwords are **auto-generated** by Dokploy's template system.

The `template.toml` file defines variables that Dokploy automatically generates:
- Random 32-character database passwords
- Domain configuration

### 3. View Generated Passwords

After deployment, check the **Environment** tab in Dokploy to see the auto-generated passwords for:
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD` / `WORDPRESS_DB_PASSWORD`

**Default Credentials:**
| Service | Username | Password |
|---------|----------|----------|
| FileBrowser | admin | `admin` |
| phpMyAdmin | wordpress | (your MYSQL_PASSWORD) |

### 4. Configure Domains

Go to the **Domains** tab in Dokploy and add:

| Domain | Service | Port |
|--------|---------|------|
| yourdomain.com | nginx | 80 |
| files.yourdomain.com | filebrowser | 80 |
| pma.yourdomain.com | phpmyadmin | 80 |

### 4. Deploy

Click **Deploy** and wait for all services to start.

### 5. Activate Redis Cache

1. Log in to WordPress admin (`yourdomain.com/wp-admin`)
2. Go to **Plugins > Installed Plugins**
3. Activate **Redis Object Cache**
4. Go to **Settings > Redis**
5. Click **Enable Object Cache**

## Environment Variables

### Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | - | **Required.** MariaDB root password |
| `MYSQL_DATABASE` | wordpress | Database name |
| `MYSQL_USER` | wordpress | Database user |
| `MYSQL_PASSWORD` | - | **Required.** Database password |
| `WORDPRESS_DB_HOST` | db | Database host |
| `WORDPRESS_DB_USER` | wordpress | WordPress database user |
| `WORDPRESS_DB_PASSWORD` | - | **Required.** WordPress database password |
| `WORDPRESS_DB_NAME` | wordpress | WordPress database name |

### PHP Settings (No Rebuild Required)

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_UPLOAD_MAX_FILESIZE` | 256M | Maximum upload file size |
| `PHP_POST_MAX_SIZE` | 256M | Maximum POST data size |
| `PHP_MEMORY_LIMIT` | 256M | PHP memory limit |
| `PHP_MAX_EXECUTION_TIME` | 300 | Script timeout in seconds |
| `PHP_MAX_INPUT_TIME` | 300 | Input parsing timeout |
| `PHP_MAX_INPUT_VARS` | 3000 | Maximum input variables |

### OPcache Settings

| Variable | Default | Description |
|----------|---------|-------------|
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

### Resource Limits (No Rebuild Required)

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_CPU_LIMIT` | 0.5 | Nginx CPU limit |
| `NGINX_MEMORY_LIMIT` | 256M | Nginx memory limit |
| `WORDPRESS_CPU_LIMIT` | 1.0 | WordPress CPU limit |
| `WORDPRESS_MEMORY_LIMIT` | 1G | WordPress memory limit |
| `DB_CPU_LIMIT` | 1.0 | MariaDB CPU limit |
| `DB_MEMORY_LIMIT` | 1G | MariaDB memory limit |
| `REDIS_CPU_LIMIT` | 0.5 | Redis CPU limit |
| `REDIS_MEMORY_LIMIT` | 512M | Redis memory limit |
| `FILEBROWSER_CPU_LIMIT` | 0.25 | FileBrowser CPU limit |
| `FILEBROWSER_MEMORY_LIMIT` | 128M | FileBrowser memory limit |
| `PHPMYADMIN_CPU_LIMIT` | 0.5 | phpMyAdmin CPU limit |
| `PHPMYADMIN_MEMORY_LIMIT` | 256M | phpMyAdmin memory limit |

## Changing Settings After Deployment

All PHP, Nginx, Redis, and resource settings can be changed without rebuilding:

1. Go to your Compose service in Dokploy
2. Navigate to **Environment** tab
3. Update the desired variables
4. Click **Redeploy**

The containers will restart with the new settings.

## Using WP-CLI

WP-CLI is pre-installed in the WordPress container. To use it:

```bash
# Access the WordPress container
docker exec -it <wordpress-container-name> bash

# Run WP-CLI commands
wp plugin list
wp cache flush
wp core update
```

## FileBrowser Default Credentials

- **Username:** admin
- **Password:** admin

**Important:** Change these credentials immediately after first login.

## Volumes

| Volume | Purpose |
|--------|---------|
| `wordpress_data` | WordPress files (/var/www/html) |
| `db_data` | MariaDB data |
| `redis_data` | Redis persistence |
| `filebrowser_data` | FileBrowser database |

## Security Recommendations

1. Set strong passwords for all database credentials
2. Change FileBrowser default password
3. Consider restricting access to phpMyAdmin and FileBrowser subdomains
4. Enable Dokploy's built-in SSL/TLS
5. Keep WordPress and plugins updated

## Troubleshooting

### WordPress not loading

1. Check if all containers are running in Dokploy
2. Verify database credentials match between services
3. Check container logs for errors

### Upload size issues

Make sure both PHP and Nginx limits are set:

```env
PHP_UPLOAD_MAX_FILESIZE=512M
PHP_POST_MAX_SIZE=512M
NGINX_CLIENT_MAX_BODY_SIZE=512M
```

### Redis not connecting

1. Verify Redis container is healthy
2. Activate the Redis Object Cache plugin in WordPress
3. Check Redis settings in WordPress admin

## License

MIT
