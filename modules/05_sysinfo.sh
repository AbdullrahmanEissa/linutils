#!/usr/bin/env bash

case "$1" in
    name) echo "System Information" ;;
    desc) echo "Displays CPU, RAM, Kernel, and OS details." ;;
    run)
        echo "--- Hardware Summary ---"
        echo "CPU: $(lscpu | grep 'Model name' | cut -f 2 -d ":")"
        echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
        echo "Kernel: $(uname -r)"
        echo "Uptime: $(uptime -p)"
        echo "--- Disk Usage ---"
        df -h / | awk 'NR==2 {print "Root Partition: " $3 "/" $2 " used (" $5 ")"}'
        ;;
    *) exit 1 ;;
esac