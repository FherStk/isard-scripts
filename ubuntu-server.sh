#!/bin/bash
source ./main.sh

VERSION="1.0.0"
NAME="Ubuntu Server"

trap 'abort' 0
set -e

info "$NAME" "$VERSION"
apt_req "openssh-server"

title "Upgrading the installed apps: "
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

title "Disabling: " "auto-upgrades"
cp ./utils/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

title "Setting up: " "netplan"
cp ./utils/netplan-server.yaml /etc/netplan/00-installer-config.yaml
netplan apply

title "Clearing: " "bash history"
cat /dev/null > ~/.bash_history && history -c

trap : 0
echo -e "${GREEN}DONE!${NC}"