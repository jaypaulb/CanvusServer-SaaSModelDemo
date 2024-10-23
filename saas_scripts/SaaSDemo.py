#!/usr/bin/env python3

# Python script to subscribe to user registration feed, create groups, assign users, and approve them
# Running continuously on Ubuntu in a virtual environment for best practices

import requests
import json
import time
import logging
import socket
import os
from dotenv import load_dotenv

# Load environment variables from config.env
load_dotenv('/home/azureuser/CanvusServer-SaaSModelDemo/config.env')

# Set up logging
fqdn = socket.getfqdn()
logging.basicConfig(filename=f'/home/azureuser/SaaSDemo_{time.strftime("%Y%m%d")}.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')
logging.info(f"Running and monitoring Server FQDN: {fqdn}")

# Variables from environment
API_TOKEN = os.getenv("API_TOKEN")
SUBSCRIBE_URL = os.getenv("SUBSCRIBE_URL")
BASE_URL = os.getenv("BASE_URL")

HEADERS = {
    "Private-Token": API_TOKEN,
    "Content-Type": "application/json"
}

# Function to handle creating groups and assigning users
def handle_user(user):
    try:
        user_id = user["id"]
        email = user["email"]

        # Extract domain from email address
        domain = email.split("@")[1]
        group_name = f"{domain.split('.')[0]}_group"

        # Check if group already exists
        logging.info(f"New user found: {email}")
        group_list_response = requests.get(f"{BASE_URL}/groups", headers=HEADERS)
        group_list_response.raise_for_status()
        group_list = group_list_response.json()

        group_id = None
        for group in group_list:
            if group["name"] == group_name:
                group_id = group["id"]
                logging.info(f"Group {group_name} already exists with ID {group_id}")
                break

        # If group doesn't exist, create it
        if group_id is None:
            group_data = {"name": group_name, "description": "Auto-created group"}
            group_response = requests.post(f"{BASE_URL}/groups", headers=HEADERS, data=json.dumps(group_data))
            group_response.raise_for_status()
            group_id = group_response.json().get("id")
            logging.info(f"Created group: {group_name} with ID {group_id}")

        # Assign the user to the group
        member_data = {"id": user_id}
        assign_response = requests.post(f"{BASE_URL}/groups/{group_id}/members", headers=HEADERS, data=json.dumps(member_data))
        if assign_response.status_code == 200:
            logging.info(f"Added user {user_id} to group {group_name}")
        else:
            logging.error(f"Error adding user {user_id} to group {group_name}: {assign_response.status_code} - {assign_response.text}")
        assign_response.raise_for_status()

        # Approve the user
        approve_response = requests.post(f"{BASE_URL}/users/{user_id}/approve", headers=HEADERS)
        if approve_response.status_code == 200:
            logging.info(f"User {user_id} approved")
        else:
            logging.error(f"Error approving user {user_id}: {approve_response.status_code} - {approve_response.text}")
        approve_response.raise_for_status()

    except requests.RequestException as e:
        logging.error(f"Error handling user {user.get('id')} with email {user.get('email')}: {e}")

# Main function to listen to the API feed
def subscribe():
    while True:
        try:
            with requests.get(SUBSCRIBE_URL, headers=HEADERS, stream=True) as response:
                response.raise_for_status()
                for line in response.iter_lines():
                    if line:
                        try:
                            user_entries = json.loads(line.decode('utf-8'))
                            for user in user_entries:
                                # Skip users that are already approved
                                if user.get("approved", True) is False:
                                    handle_user(user)
                        except json.JSONDecodeError:
                            logging.warning("Received malformed JSON line, skipping.")
        except requests.RequestException as e:
            logging.error(f"Subscription request error: {e}")
        time.sleep(5)  # Sleep before attempting to reconnect to reduce server load

if __name__ == "__main__":
    subscribe()
