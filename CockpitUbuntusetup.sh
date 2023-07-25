#!/bin/bash

# Update system
echo "Updating system..."
apt update -y && apt upgrade -y

# Install Cockpit if not already installed
if ! dpkg -l | grep -q cockpit; then
  echo "Installing Cockpit..."
  apt install -y cockpit
fi

# List of Cockpit plugins
plugins=("cockpit-bridge" "cockpit-networkmanager" "cockpit-packagekit" "cockpit-storaged" "cockpit-system" "cockpit-ws" "cockpit-machines" "cockpit-podman" "cockpit-389-ds")

# Install each plugin if not already installed
for plugin in "${plugins[@]}"; do
  if ! dpkg -l | grep -q $plugin; then
    echo "Installing $plugin..."
    apt install -y $plugin
  fi
done

# Allow Cockpit through the firewall
echo "Configuring firewall for Cockpit..."
ufw allow 9090

# Configure static IP
echo "Configuring static IP address..."
cat << EOF > /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [XXX.XXX.XXX.XXX/24]
      routes:
      - to: 0.0.0.0/0
        via: XXX.X.X.X
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF

# Apply the network configuration
echo "Applying network configuration..."
netplan apply

# Enable and start Cockpit
echo "Enabling and starting Cockpit..."
systemctl enable --now cockpit.socket

echo "All done!"
