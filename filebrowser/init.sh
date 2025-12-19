#!/bin/bash
set -e

FB_BIN="/usr/local/bin/filebrowser"

# Ensure database directory exists
mkdir -p /database

# If database doesn't exist, create it with default user
if [ ! -f /database/filebrowser.db ]; then
    echo "Initializing FileBrowser database..."
    $FB_BIN config init --database /database/filebrowser.db
    $FB_BIN config set --database /database/filebrowser.db --root /srv --address 0.0.0.0 --port 80

    # Add admin user with password 'admin'
    echo "Creating admin user..."
    $FB_BIN users add admin admin --database /database/filebrowser.db --perm.admin

    echo "========================================="
    echo "FileBrowser initialized!"
    echo "Username: admin"
    echo "Password: admin"
    echo "========================================="
fi

# Start FileBrowser
exec $FB_BIN --database /database/filebrowser.db
