#!/bin/bash
# cleanup_treafik.sh - Script to remove all Traefik components

# Stop services first
echo "Stopping Traefik service..."
sudo systemctl stop traefik || true
sudo systemctl disable traefik || true

# Stop Docker container if exists
echo "Stopping test containers..."
sudo docker stop whoami || true
sudo docker rm whoami || true

# Remove Traefik files
echo "Removing Traefik configuration files..."
sudo rm -rf /etc/traefik
sudo rm -f /etc/systemd/system/traefik.service
sudo rm -f /usr/local/bin/traefik

# Reload systemd to forget about the service
echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Cleanup completed successfully!"