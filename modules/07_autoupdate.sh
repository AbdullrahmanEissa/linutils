#!/usr/bin/env bash

case "$1" in
    name) echo "Enable Auto-Maintenance" ;;
    desc) echo "Schedules a weekly system update and cleanup via Cron." ;;
    run)
        CRON_JOB="0 3 * * 1 root $PKG_UPDATE && $PKG_CLEAN"
        echo "$CRON_JOB" > /etc/cron.d/linutil-auto-update
        chmod 644 /etc/cron.d/linutil-auto-update
        echo "Weekly maintenance scheduled for Mondays at 3:00 AM."
        ;;
    *) exit 1 ;;
esac