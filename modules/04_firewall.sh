#!/usr/bin/env bash

case "$1" in
    name) 
        echo "Setup UFW Firewall" 
        ;;
    desc) 
        echo "Installs UFW, allows SSH, and enables the firewall." 
        ;;
    run)
        echo "Configuring UFW Firewall..."
        
        # 1. Install UFW if it is not already installed
        if ! command -v ufw >/dev/null; then
            echo "UFW not found. Installing..."
            eval "$PKG_INSTALL ufw"
        else
            echo "UFW is already installed."
        fi

        # 2. Set default deny incoming / allow outgoing policies
        echo "Setting default rules..."
        ufw default deny incoming
        ufw default allow outgoing

        # 3. Allow SSH to prevent remote lockouts
        echo "Allowing SSH (Port 22)..."
        ufw allow ssh

        # 4. Enable the firewall (using --force to bypass the interactive prompt)
        echo "Enabling UFW..."
        ufw --force enable

        # 5. Display the final status
        echo -e "\nFirewall setup complete! Current status:"
        ufw status verbose
        ;;
    *) 
        echo "Invalid argument" 
        exit 1 
        ;;
esac