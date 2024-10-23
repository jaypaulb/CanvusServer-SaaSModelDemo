#!/bin/bash

# Script to remove the CanvusServer-SaaSModelDemo setup
# Deletes virtual environment, systemd service, log files, and other related configurations

# Variables
INSTALL_DIR="/home/azureuser/CanvusServer-SaaSModelDemo"
VENV_DIR="/home/azureuser/user_subscription_venv"
SERVICE_FILE="/etc/systemd/system/SaaSDemo.service"
LOGROTATE_CONFIG="/etc/logrotate.d/SaaSDemo"

# Stop and disable the systemd service
echo "Stopping and disabling SaaSDemo service..."
sudo systemctl stop SaaSDemo.service
sudo systemctl disable SaaSDemo.service

# Remove the systemd service file
echo "Removing systemd service file..."
if [ -f "$SERVICE_FILE" ]; then
  sudo rm "$SERVICE_FILE"
  sudo systemctl daemon-reload
else
  echo "Service file does not exist. Skipping..."
fi

# Remove the virtual environment
echo "Removing virtual environment..."
if [ -d "$VENV_DIR" ]; then
  rm -rf "$VENV_DIR"
else
  echo "Virtual environment directory does not exist. Skipping..."
fi

# Remove logrotate configuration
echo "Removing logrotate configuration..."
if [ -f "$LOGROTATE_CONFIG" ]; then
  sudo rm "$LOGROTATE_CONFIG"
else
  echo "Logrotate configuration does not exist. Skipping..."
fi

# Remove log files
echo "Removing log files..."
LOG_FILES="/home/azureuser/SaaSDemo_*.log"
rm -f $LOG_FILES

# Remove the daily restart cron job
echo "Removing cron job for daily restart..."
CRON_JOB="0 0 * * * /bin/systemctl restart SaaSDemo.service"
(sudo crontab -l | grep -v -F "$CRON_JOB") | sudo crontab -

# Finish
echo "Uninstallation completed. The repository is still available at $INSTALL_DIR."
