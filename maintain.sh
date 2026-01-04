#!/bin/bash

################################################################################
# SCRIPT NAME: maintain.sh
# DESCRIPTION: Automates Ubuntu OS updates and Docker container updates.
#              - Updates APT packages and cleans up unused dependencies.
#              - Pulls latest Docker images and restarts containers if needed.
#              - Logs all output to maintenance.log (managed by logrotate).
#              - Automatically reboots if a kernel update is detected.
#
# SETUP:
#   1. Place this script in your home directory: /home/USERNAME/maintain.sh
#   2. Ensure your docker-compose.yml is in:    /home/USERNAME/compose
#   3. Make script executable: chmod +x maintain.sh
################################################################################

# --- CONFIGURATION ---
# Replace 'compose' with your actual directory name if different
DOCKER_PROJECT_DIR="compose"
# ---------------------

# Prevent interactive prompts from stalling the script
export DEBIAN_FRONTEND=noninteractive

# Dynamically set paths based on the user running the script
USER_HOME="/home/$USER"
LOG_FILE="$USER_HOME/maintenance.log"
DOCKER_DIR="$USER_HOME/$DOCKER_PROJECT_DIR"

# Redirect all output to both terminal and log file (append mode)
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================================="
echo "MAINTENANCE START: $(date)"
echo "=========================================================="

# 1. Update Ubuntu System
echo "[1/3] Updating Ubuntu packages..."
if sudo apt-get update && sudo apt-get full-upgrade -y -o Dpkg::Options::="--force-confold"; then
    echo "SUCCESS: System packages updated."
    sudo apt-get autoremove -y
    sudo apt-get clean
    echo "SUCCESS: Unused packages removed and cache cleaned."
else
    echo "ERROR: Ubuntu update/upgrade failed."
fi

# 2. Update Docker Containers
echo "[2/3] Updating Docker containers..."
if [ -d "$DOCKER_DIR" ]; then
    cd "$DOCKER_DIR"
    if /usr/bin/docker compose pull && \
       /usr/bin/docker compose up -d --remove-orphans && \
       /usr/bin/docker image prune -f; then
        echo "SUCCESS: Docker stack updated and pruned."
    else
        echo "ERROR: One or more Docker commands failed."
    fi
else
    echo "ERROR: Directory not found: $DOCKER_DIR"
    echo "Please ensure your docker-compose.yml is in $DOCKER_DIR"
fi

# 3. Check if reboot is required
echo "[3/3] Checking for reboot requirement..."
if [ -f /var/run/reboot-required ]; then
    REASON=$(cat /var/run/reboot-required.pkgs 2>/dev/null | sed 's/^/ due to: /' || echo "")
    echo "REBOOT REQUIRED$REASON. Restarting in 30 seconds..."
    echo "=========================================================="
    sleep 30
    sudo /usr/sbin/reboot
else
    echo "No reboot required."
fi

echo "=========================================================="
echo "MAINTENANCE COMPLETE: $(date)"
echo ""
