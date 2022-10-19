#!/bin/bash
source ./main.sh

VERSION="1.0.0"
NAME="Ubuntu Server"

trap 'abort' 0
set -e

info "$NAME" "$VERSION"
auto-update `basename "$0"`

apt-upgrade
apt-req "openssh-server"

echo ""
title "Performing system changes:"
echo "Disabling auto-upgrades..."
cp ./utils/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

echo "Setting up hostname..."
set-hostname "ubuntu-2204-server"

echo "Setting up netplan..."
#cp ./utils/netplan-server.yaml /etc/netplan/00-installer-config.yaml
netplan apply

echo "Clearing bash history..."
cat /dev/null > ~/.bash_history && history -c

trap : 0
echo ""
echo -e "${GREEN}DONE! Rebooting...${NC}"
reboot