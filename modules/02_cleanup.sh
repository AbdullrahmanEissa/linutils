#!/usr/bin/env bash

case "$1" in
    name) echo "System Cleanup" ;;
    desc) echo "Removes orphaned packages and clears package cache." ;;
    run)
        echo "Cleaning up the system..."
        eval "$PKG_CLEAN"
        
        # Additional cross-distro cleanup tasks can go here
        rm -rf /var/cache/apt/archives/* 2>/dev/null
        rm -rf ~/.cache/thumbnails/* 2>/dev/null
        
        echo "Cleanup finished!"
        ;;
    *) echo "Invalid argument" ; exit 1 ;;
esac