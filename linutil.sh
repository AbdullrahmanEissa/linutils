#!/usr/bin/env bash

# --- Configuration ---
# IMPORTANT: Replace YOUR_USERNAME and YOUR_REPO with your actual details.
# The URL must point to the RAW file.
GITHUB_REPO_URL="https://raw.githubusercontent.com/AbdullrahmanEissa/linutils/main/linutil.sh"
MODULES_DIR="$(dirname "$0")/modules"
LOG_FILE="/tmp/linutil.log"

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root. Try: sudo $0" 
   exit 1
fi

# --- Package Manager Detection ---
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
    else
        echo "Unsupported package manager. Exiting."
        exit 1
    fi
}

# --- Safe Self-Update Mechanism ---
self_update() {
    echo "Checking connection to GitHub..."
    
    # This specifically extracts JUST the number (e.g., 200 or 404)
    HTTP_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" "$GITHUB_REPO_URL")

    if [[ "$HTTP_STATUS" != "200" ]]; then
        echo "❌ Connection Error!"
        echo "GitHub returned status: $HTTP_STATUS"
        echo "URL tried: $GITHUB_REPO_URL"
        echo "Check if repo is public and code is pushed."
        sleep 5
        return
    fi

    local temp_file="/tmp/linutil_stage.sh"
    echo "Downloading update..."
    curl -sL "$GITHUB_REPO_URL" -o "$temp_file"

    if grep -q "#!" "$temp_file" && ! grep -q "404: Not Found" "$temp_file"; then
        echo "✅ Update verified. Applying changes..."
        mv "$temp_file" "$0"
        chmod +x "$0"
        echo "Done! Please restart the script."
        exit 0
    else
        echo "❌ Critical Error: Downloaded file is invalid."
        rm -f "$temp_file"
        sleep 3
    fi
}

# --- Module Loader ---
declare -a MENU_OPTIONS
declare -A MODULE_PATHS

load_modules() {
    MENU_OPTIONS=()
    MENU_OPTIONS+=("Update_LinUtil" "Safely update this tool from GitHub")
    
    mkdir -p "$MODULES_DIR"

    for mod in "$MODULES_DIR"/*; do
        if [[ -x "$mod" && ! -d "$mod" ]]; then
            local mod_name=$("$mod" name)
            local mod_base=$(basename "$mod")
            
            MENU_OPTIONS+=("$mod_base" "$mod_name")
            MODULE_PATHS["$mod_base"]="$mod"
        fi
    done
}

# --- Main UI Loop ---
detect_pkg_mgr
echo "LinUtil Session - $(date)" > "$LOG_FILE"

while true; do
    load_modules
    
    CHOICE=$(whiptail --title "LinUtil v1.1 - Modular Engine ($PKG_MGR)" \
                      --menu "Select a task. Logs are saved to $LOG_FILE" \
                      20 75 10 \
                      "${MENU_OPTIONS[@]}" \
                      3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        clear
        echo "Exiting LinUtil. See you next time!"
        break
    fi

    case "$CHOICE" in
        Update_LinUtil)
            clear
            self_update
            ;;
        *)
            if [[ -n "${MODULE_PATHS[$CHOICE]}" ]]; then
                clear
                echo "Executing Module: $CHOICE"
                echo "----------------------------------------------------"
                "${MODULE_PATHS[$CHOICE]}" run 2>&1 | tee -a "$LOG_FILE"
                echo "----------------------------------------------------"
                read -p "Press Enter to return to the menu..."
            fi
            ;;
    esac
done