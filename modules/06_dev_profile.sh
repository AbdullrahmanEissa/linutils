#!/usr/bin/env bash

case "$1" in
    name) echo "Developer Environment Setup" ;;
    desc) echo "Installs Docker, VS Code (via Flatpak/Snap), and Git." ;;
    run)
        echo "Installing Dev Tools..."
        eval "$PKG_INSTALL docker.io git build-essential"
        
        # Check for Flatpak and install VS Code if available
        if command -v flatpak >/dev/null; then
            echo "Installing VS Code via Flatpak..."
            flatpak install flathub com.visualstudio.code -y
        fi
        
        echo "Enabling Docker service..."
        systemctl enable --now docker
        echo "Developer environment ready."
        ;;
    *) exit 1 ;;
esac