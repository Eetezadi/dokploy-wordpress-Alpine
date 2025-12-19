#!/bin/bash
set -e

FB_BIN="/usr/local/bin/filebrowser"

# If database doesn't exist, create it with default user
if [ ! -f /database/filebrowser.db ]; then
    echo "Initializing FileBrowser database..."
    $FB_BIN config init --database /database/filebrowser.db
    $FB_BIN config set --database /database/filebrowser.db --root /srv --address 0.0.0.0 --port 80
    $FB_BIN users add admin admin --database /database/filebrowser.db --perm.admin
    echo "FileBrowser initialized with user: admin / password: admin"
fi

# Start FileBrowser
exec $FB_BIN --database /database/filebrowser.db
