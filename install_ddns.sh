#!/bin/bash

# Prompt users to enter their Namesilo API key
read -p "Enter your Namesilo API key: " API_KEY

# Prompt users to enter their domain name
read -p "Enter your domain name: " DOMAIN

# Prompt users to enter their hostname
read -p "Enter your hostname: " HOSTNAME

# Prompt users to enter their network interface name
read -p "Enter your network interface name (which has IPv6 address): " NETWORK_INTERFACE

# Download the DDNS script and config.json
if curl --insecure -fsSL -O https://raw.githubusercontent.com/Euyug/namesilo_ipv6_ddns/main/ddns.sh && curl --insecure -fsSL -O https://raw.githubusercontent.com/Euyug/namesilo_ipv6_ddns/main/config.json; then
    echo "Files downloaded successfully."
else
    echo "Failed to download files. Please check your internet connection and try again."
    exit 1
fi

# Modify the configuration file with user input
sed -i "s/YOUR_API_KEY/$API_KEY/" config.json
sed -i "s/YOUR_DOMAIN/$DOMAIN/" config.json
sed -i "s/YOUR_HOSTNAME/$HOSTNAME/" config.json
sed -i "s/YOUR_NETWORK_INTERFACE/$NETWORK_INTERFACE/" config.json

# Make the DDNS script executable
chmod +x ddns.sh

# Create the systemd service file
echo -e "[Unit]\nDescription=DDNS Service\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=$(pwd)/ddns.sh\nWorkingDirectory=$(pwd)\nRestart=always\nUser=root\nGroup=root\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/ddns.service > /dev/null

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start the DDNS service
sudo systemctl enable ddns.service
sudo systemctl start ddns.service
