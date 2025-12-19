FROM alpine:3.19 AS builder

# Download filebrowser binary
RUN apk add --no-cache curl && \
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | sh

FROM alpine:3.19

# Install bash for init script
RUN apk add --no-cache bash ca-certificates

# Copy filebrowser from builder
COPY --from=builder /usr/local/bin/filebrowser /usr/local/bin/filebrowser

# Copy init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 80

ENTRYPOINT ["/init.sh"]
