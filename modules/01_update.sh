#!/usr/bin/env bash
# Utilizes the $PKG_UPDATE variable exported by the core script

case "$1" in
    name) echo "System Update" ;;
    desc) echo "Updates all system packages." ;;
    run)
        echo "Starting system update using $PKG_MGR..."
        eval "$PKG_UPDATE"
        echo "Update finished!"
        ;;
    *) echo "Invalid argument" ; exit 1 ;;
esac