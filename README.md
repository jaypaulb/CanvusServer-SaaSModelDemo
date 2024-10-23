# CanvusServer-SaaSModelDemo

## Overview
The **CanvusServer-SaaSModelDemo** repository contains everything you need to set up a SaaS model demonstration server for Canvus. This includes a script (`SaaSDemo.py`) that automates user subscription, group creation, user assignments, and approvals, as well as a setup script (`Install-SaaSDemo.sh`) for easy deployment.

The repository includes:
- **Install-SaaSDemo.sh**: A shell script to automate the installation and setup process, including creating a virtual environment, installing dependencies, and setting up a systemd service to run the demo continuously.
- **requirements.txt**: A list of Python dependencies required to run the script.
- **config.env**: An environment file for storing sensitive settings like API keys and URLs.
- **saas_scripts/**: A subfolder containing the core Python script (`SaaSDemo.py`).

## Repository Structure
```
CanvusServer-SaaSModelDemo/
  |-- Install-SaaSDemo.sh       # Setup script to automate the installation and service configuration
  |-- requirements.txt          # Python dependencies
  |-- config.env                # Configuration file (not to be committed with real keys)
  |-- saas_scripts/             # Subfolder for the Python script
      |-- SaaSDemo.py           # Main script for managing Canvus SaaS operations
```

## Prerequisites
- **Ubuntu server** with `git`, `python3`, and `python3-venv` installed.
- Ensure you have a valid API token and URLs to fill in the `config.env` file.

## Quick Start Guide
### 1. Clone the Repository
To get started, clone the repository to your server:
```bash
cd /home/azureuser
git clone https://github.com/jaypaulb/CanvusServer-SaaSModelDemo.git
```

### 2. Set Up the Configuration File
Before running the setup script, update the `config.env` file in the root of the repository with the correct values:
```env
API_TOKEN=your_api_token_here
SUBSCRIBE_URL=https://demo.canvusmultisite.com/api/v1/users?subscribe
BASE_URL=https://demo.canvusmultisite.com/api/v1
```
Ensure that **real API keys** and URLs are not committed to the public repository.

### 3. Run the Installation Script
The `Install-SaaSDemo.sh` script will handle everything from setting up the virtual environment, installing dependencies, and configuring the script to run continuously:
```bash
cd CanvusServer-SaaSModelDemo
chmod +x Install-SaaSDemo.sh
./Install-SaaSDemo.sh
```
This script will:
- Install the required dependencies.
- Set up a Python virtual environment.
- Install the Python requirements listed in `requirements.txt`.
- Configure a systemd service to automatically run the `SaaSDemo.py` script at boot.
- Set up log rotation and a daily service restart.

## Configuration Details
- **config.env**: This file contains sensitive settings, such as the API token and URLs. Make sure to fill in the necessary values and **keep this file secure**.

## Log Management
- Logs are created daily, with filenames including the current date (e.g., `SaaSDemo_YYYYMMDD.log`).
- Log rotation is set up using `logrotate` to keep the logs manageable. Logs are rotated daily, compressed, and kept for 7 days.

## Systemd Service
The `SaaSDemo` script is configured to run as a systemd service:
- **Service file**: Located at `/etc/systemd/system/SaaSDemo.service`.
- The service is set to **restart automatically** on failure.
- A **daily cron job** restarts the service to ensure stability.

## Notes
- **Security**: Do not commit your `config.env` with real API keys to a public repository.
- **Customization**: Adjust the paths and service configurations as needed for your environment.

## Troubleshooting
- **Service Issues**: Check the status of the service using:
  ```bash
  sudo systemctl status SaaSDemo.service
  ```
- **Logs**: Inspect the log files located in `/home/azureuser` for any issues or errors.
- **Virtual Environment**: Ensure the virtual environment is activated if troubleshooting manually:
  ```bash
  source /home/azureuser/user_subscription_venv/bin/activate
  ```

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contributions
Feel free to create issues or submit pull requests for enhancements, bug fixes, or general improvements.

## Contact
For any questions or support, reach out at **jaypaulb@effectivetech.co.uk**.

