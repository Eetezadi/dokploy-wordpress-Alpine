<?php
/**
 * Custom WordPress configuration additions
 * Injected into wp-config.php for dynamic domain handling and Redis
 */

// Force dynamic domain detection - overrides database values
if (isset($_SERVER['HTTP_HOST'])) {
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? 'https://' : 'http://';
    define('WP_HOME', $protocol . $_SERVER['HTTP_HOST']);
    define('WP_SITEURL', $protocol . $_SERVER['HTTP_HOST']);
}

// Redis configuration (for docker-compose internal network)
if (!defined('WP_REDIS_HOST')) {
    define('WP_REDIS_HOST', getenv('WP_REDIS_HOST') ?: 'redis');
    define('WP_REDIS_PORT', getenv('WP_REDIS_PORT') ?: 6379);
    define('WP_CACHE', true);
}
