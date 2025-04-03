#!/bin/bash
set -e

# Get parameters from command line
CF_EMAIL=$1
CF_KEY=$2
DOMAIN_NAME=$3

# Create directories
sudo mkdir -p /etc/traefik/config
sudo mkdir -p /etc/traefik/acme

# Move configuration files
sudo mv /tmp/traefik.toml /etc/traefik/
sudo mv /tmp/traefik.service /etc/systemd/system/

# Create environment file with Cloudflare credentials
cat << EOF | sudo tee /etc/traefik/cloudflare.env
CF_API_EMAIL=${CF_EMAIL}
CF_API_KEY=${CF_KEY}
EOF

# Secure the credentials file
sudo chmod 600 /etc/traefik/cloudflare.env

# Download Traefik binary
sudo curl -L "https://github.com/traefik/traefik/releases/download/v2.10.4/traefik_v2.10.4_linux_amd64.tar.gz" -o /tmp/traefik.tar.gz
sudo tar -zxvf /tmp/traefik.tar.gz -C /tmp traefik
sudo mv /tmp/traefik /usr/local/bin/
sudo chmod +x /usr/local/bin/traefik

# Create acme.json for Let's Encrypt certificates
sudo touch /etc/traefik/acme/acme.json
sudo chmod 600 /etc/traefik/acme/acme.json

# Start and enable Traefik service
sudo systemctl daemon-reload
sudo systemctl enable traefik
sudo systemctl start traefik

# Verify service is running correctly
if systemctl is-active --quiet traefik; then
  echo "Traefik service started successfully"
else
  echo "Failed to start Traefik service"
  journalctl -xeu traefik
  exit 1
fi







