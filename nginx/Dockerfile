FROM nginx:alpine

# Install dependencies: gettext (envsubst), wget (healthcheck), netcat-openbsd (connection checks)
RUN apk add --no-cache gettext wget netcat-openbsd

# Create nginx directories with proper ownership (Railway pattern)
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run \
    && chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/run

# Copy master nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy nginx config template and entrypoint
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY docker-entrypoint.sh /docker-entrypoint-custom.sh
RUN chmod +x /docker-entrypoint-custom.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint-custom.sh"]
CMD ["nginx", "-g", "daemon off;"]
