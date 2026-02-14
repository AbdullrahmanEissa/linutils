#!/usr/bin/env bash

case "$1" in
    name) echo "Install Essential CLI Tools" ;;
    desc) echo "Installs curl, git, htop, and neofetch." ;;
    run)
        echo "Installing essential packages..."
        # You can append to the PKG_INSTALL command dynamically
        eval "$PKG_INSTALL curl git htop neofetch ufw"
        echo "Installation finished! Run 'neofetch' to see system specs."
        ;;
    *) echo "Invalid argument" ; exit 1 ;;
esac