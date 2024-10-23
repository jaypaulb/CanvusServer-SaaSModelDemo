#!/bin/bash

# Script to set up the CanvusServer-SaaSModelDemo on an Ubuntu server
# Downloads, installs, sets up Python environment, and configures the script to run on boot

# Variables
REPO_URL="https://github.com/jaypaulb/CanvusServer-SaaSModelDemo.git"
INSTALL_DIR="/home/azureuser/CanvusServer-SaaSModelDemo"
VENV_DIR="/home/azureuser/user_subscription_venv"
SERVICE_FILE="/etc/systemd/system/SaaSDemo.service"

# Update system
sudo apt-get update -y

# Install required packages
sudo apt-get install -y git python3 python3-venv

# Clone the repository
echo "Cloning repository..."
if [ ! -d "$INSTALL_DIR" ]; then
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  echo "Repository already exists. Pulling latest changes..."
  cd "$INSTALL_DIR" && git pull
fi

# Create virtual environment and install dependencies
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment..."
  python3 -m venv "$VENV_DIR"
fi

# Activate the virtual environment and install Python packages
source "$VENV_DIR/bin/activate"
cd "$INSTALL_DIR"
pip install -r requirements.txt  # Assumes a requirements.txt file exists

# Deactivate the virtual environment
deactivate

# Create a systemd service file
if [ ! -f "$SERVICE_FILE" ]; then
  echo "Creating systemd service file..."
  sudo bash -c "cat > $SERVICE_FILE" << EOL
[Unit]
Description=SaaSDemo User Subscription Service
After=network.target

[Service]
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/SaaSDemo.py
Restart=always
User=azureuser
Group=azureuser

[Install]
WantedBy=multi-user.target
EOL

  # Reload systemd to apply new service configuration
  sudo systemctl daemon-reload

  # Enable and start the service
  sudo systemctl enable SaaSDemo.service
  sudo systemctl start SaaSDemo.service
else
  echo "Service file already exists. Skipping creation..."
fi

# Set up log rotation
echo "Setting up log rotation..."
LOGROTATE_CONFIG="/etc/logrotate.d/SaaSDemo"
if [ ! -f "$LOGROTATE_CONFIG" ]; then
  sudo bash -c "cat > $LOGROTATE_CONFIG" << EOL
/home/azureuser/SaaSDemo_*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0644 azureuser azureuser
}
EOL
else
  echo "Logrotate config already exists. Skipping creation..."
fi

# Set up daily restart of service
echo "Setting up daily restart of the service..."
CRON_JOB="0 0 * * * /bin/systemctl restart SaaSDemo.service"
( sudo crontab -l | grep -v -F "$CRON_JOB"; echo "$CRON_JOB" ) | sudo crontab -

# Finish
echo "Setup completed successfully."
