#!/bin/bash

# Script to check for /etc/machine-id and create it if missing
# Designed to run at system startup via cron

MACHINE_ID_FILE="/etc/machine-id"
LOG_FILE="/var/log/machine-id-check.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Start logging
log_message "Starting machine-id check"

# Check if /etc/machine-id exists and is not empty
if [ ! -f "$MACHINE_ID_FILE" ] || [ ! -s "$MACHINE_ID_FILE" ]; then
    log_message "WARNING: $MACHINE_ID_FILE is missing or empty"

    # Try to create machine-id using systemd-machine-id-setup
    if command -v systemd-machine-id-setup &> /dev/null; then
        log_message "Running systemd-machine-id-setup..."

        if systemd-machine-id-setup; then
            log_message "SUCCESS: machine-id created successfully"

            # Verify the file was created
            if [ -f "$MACHINE_ID_FILE" ] && [ -s "$MACHINE_ID_FILE" ]; then
                log_message "Verified: $MACHINE_ID_FILE now exists and contains data"
		reboot
            else
                log_message "ERROR: machine-id file still missing after setup"
                exit 1
            fi
        else
            log_message "ERROR: systemd-machine-id-setup failed"
            exit 1
        fi
    else
        log_message "ERROR: systemd-machine-id-setup command not found"
        exit 1
    fi
else
    log_message "OK: $MACHINE_ID_FILE exists and is not empty"
fi

log_message "Machine-id check completed"
exit 0
