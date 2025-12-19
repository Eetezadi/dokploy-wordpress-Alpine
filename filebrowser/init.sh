#!/bin/sh
set -e

# If database doesn't exist, create it with default user
if [ ! -f /database/filebrowser.db ]; then
    echo "Initializing FileBrowser database..."
    /filebrowser config init --database /database/filebrowser.db
    /filebrowser config set --database /database/filebrowser.db --root /srv
    /filebrowser users add admin admin --database /database/filebrowser.db --perm.admin
    echo "FileBrowser initialized with user: admin / password: admin"
fi

# Start FileBrowser
exec /filebrowser --database /database/filebrowser.db
