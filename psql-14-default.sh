#!/bin/bash
source ./ubuntu-server-2204.sh

if [ "$ASTEMPLATE"="FALSE" ]; then
    SCRIPT_VERSION="1.0.0"
    SCRIPT_NAME="Ubuntu Server"
    HOST_NAME="ubuntu-2204-server"

    trap 'abort' 0
    set -e
fi

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update `basename "$0"`

apt-upgrade
apt-req "openssh-server"

echo ""
title "Performing system changes:"
echo "Disabling auto-upgrades..."
cp ./utils/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

echo "Setting up hostname..."
set-hostname ${HOST_NAME}

echo "Setting up netplan..."
#cp ./utils/netplan-server.yaml /etc/netplan/00-installer-config.yaml
netplan apply

if [ "$ASTEMPLATE"="FALSE" ]; then
    clear-and-reboot
fi