# Self-Healing Linux Maintenance Script
A robust Bash script designed for headless Ubuntu servers running Docker Compose. This script automates system security patches, container updates, and disk housekeeping, ensuring your server remains stable and secure without manual intervention.

## Features
- Automated OS Updates: Runs apt update and full-upgrade with non-interactive flags to prevent the script from stalling.

- Docker Compose Automation: Pulls new images, restarts containers only if changes are detected, and prunes old, dangling image layers.

- Intelligent Reboot: Detects if a kernel update or system library requires a restart and handles the reboot gracefully.

- Smart Logging: Provides real-time console output while maintaining a persistent, timestamped log file.

- Robust Error Handling: Validates directory paths and command exit codes before proceeding.

## Installation
1. Prerequisites Ensure your Docker Compose project is located in a subdirectory of your home folder (e.g., ~/compose).

2. Download and Configure Create the script in your home directory:
```bash
cd ~ nano maintain.sh
```
Paste the script content into the editor. Save and exit (Ctrl+O, Enter, Ctrl+X).

Set Permissions Make the script executable:
```bash
chmod +x maintain.sh
```

## Configuration
### Script Variables
Open maintain.sh and edit the configuration section at the top:

`DOCKER_PROJECT_DIR:compose` Change this to the name of the folder containing your docker-compose.yml (default is compose).

### Log Management
To prevent your maintenance log from growing indefinitely, configure logrotate:

1. Create a new rotation config:
```bash
sudo nano /etc/logrotate.d/maintenance
```

2. Paste the following (Replace YOUR_USERNAME with your actual Linux username):
```bash
/home/YOUR_USERNAME/maintenance.log { weekly rotate 52 missingok notifempty compress delaycompress create 0640 YOUR_USERNAME YOUR_USERNAME }
```

## Automation (Scheduling)
To run this script automatically every Sunday at 3:00 AM, add it to your user's crontab:

1. Open the crontab editor:
```bash
crontab -e
```

Add this line to the bottom (Replace YOUR_USERNAME with your actual username):
```bash
0 3 * * 0 /home/YOUR_USERNAME/maintain.sh
```

## File Manifest
- ~/maintain.sh : The main automation script.

- ~/maintenance.log : Persistent history of all maintenance runs.

- ~/compose/ : Your Docker Compose project directory.

- `/etc/logrotate.d/maintenance` : Log management rules (Keeps 1 year of history).

## Safety and Best Practices
- Snapshot First: Always take a VM snapshot or backup before running the script for the first time.

- Non-Interactive: The script uses force-confold to prioritize your existing configurations during system updates.

- Disk Space: While this script prunes old images, ensure you have set log limits in your Docker daemon.json to prevent container logs from filling the disk.

---

## ⚖️ License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
