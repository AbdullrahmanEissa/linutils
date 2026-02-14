#!/usr/bin/env bash

# Configurations
MODULES_DIR="$(dirname "$0")/modules"
LOG_FILE="/tmp/linutil.log"
GITHUB_REPO_URL="https://raw.githubusercontent.com/YOUR_GITHUB/linutil/main/linutil.sh" # Update this to your repo

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Try: sudo $0" 
   exit 1
fi

# Detect Package Manager and Export abstraction variables
detect_pkg_mgr() {
    if command -v apt-get >/dev/null; then
        export PKG_MGR="apt"
        export PKG_UPDATE="apt-get update -y && apt-get upgrade -y"
        export PKG_INSTALL="apt-get install -y"
        export PKG_CLEAN="apt-get autoremove -y && apt-get clean"
    elif command -v dnf >/dev/null; then
        export PKG_MGR="dnf"
        export PKG_UPDATE="dnf upgrade -y"
        export PKG_INSTALL="dnf install -y"
        export PKG_CLEAN="dnf autoremove -y && dnf clean all"
    elif command -v pacman >/dev/null; then
        export PKG_MGR="pacman"
        export PKG_UPDATE="pacman -Syu --noconfirm"
        export PKG_INSTALL="pacman -S --noconfirm"
        export PKG_CLEAN="pacman -Rns \$(pacman -Qtdq) --noconfirm 2>/dev/null; pacman -Sc --noconfirm"
    elif command -v zypper >/dev/null; then
        export PKG_MGR="zypper"
        export PKG_UPDATE="zypper dup -y"
        export PKG_INSTALL="zypper in -y"
        export PKG_CLEAN="zypper clean -a"
    else
        echo "Unsupported package manager. Exiting." >&2
        exit 1
    fi
}

# Self-Update Mechanism
self_update() {
    echo "Checking for updates..."
    curl -sL "$GITHUB_REPO_URL" -o /tmp/linutil_update.sh
    if [[ $? -eq 0 ]]; then
        mv /tmp/linutil_update.sh "$0"
        chmod +x "$0"
        echo "Successfully updated! Please restart the script."
        exit 0
    else
        echo "Failed to fetch update."
        sleep 2
    fi
}

# Load Modules into Whiptail Menu
declare -a MENU_OPTIONS
declare -A MODULE_PATHS

load_modules() {
    MENU_OPTIONS=()
    MENU_OPTIONS+=("Update LinUtil" "Pull the latest version from GitHub")
    
    if [[ ! -d "$MODULES_DIR" ]]; then
        echo "Modules directory not found!"
        exit 1
    fi

    # Auto-discover executable files in the modules directory
    for mod in "$MODULES_DIR"/*; do
        if [[ -x "$mod" && ! -d "$mod" ]]; then
            local mod_name=$("$mod" name)
            local mod_desc=$("$mod" desc)
            local mod_base=$(basename "$mod")
            
            MENU_OPTIONS+=("$mod_base" "$mod_name")
            MODULE_PATHS["$mod_base"]="$mod"
        fi
    done
}

# Main Loop
detect_pkg_mgr
echo "LinUtil started at $(date)" > "$LOG_FILE"

while true; do
    load_modules
    
    # Render interactive UI
    CHOICE=$(whiptail --title "LinUtil - Modular System Utility ($PKG_MGR detected)" \
                      --menu "Choose a task to run:\nLogs saved to $LOG_FILE" \
                      22 80 12 \
                      "${MENU_OPTIONS[@]}" \
                      3>&1 1>&2 2>&3)

    # Check if user pressed Cancel (exit status 1)
    if [ $? -ne 0 ]; then
        clear
        echo "Exiting LinUtil..."
        break
    fi

    # Handle Selection
    if [[ "$CHOICE" == "Update LinUtil" ]]; then
        clear
        self_update
    elif [[ -n "${MODULE_PATHS[$CHOICE]}" ]]; then
        clear
        echo "====================================================="
        echo "Running Module: ${MODULE_PATHS[$CHOICE]}"
        echo "====================================================="
        
        # Execute module, log output, and show in terminal simultaneously
        "${MODULE_PATHS[$CHOICE]}" run 2>&1 | tee -a "$LOG_FILE"
        
        echo -e "\n====================================================="
        read -p "Task complete. Press [ENTER] to return to the menu..."
    fi
done