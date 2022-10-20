#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="App Setup"

source ./utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"

echo ""
title "Setting up the isard-scripts-update service:"
cp ./utils/isard-scripts-update.service /etc/systemd/system/isard-scripts-update.service
sed -i "s|<PATH>|${HOME}|g" /etc/systemd/system/isard-scripts-update.service

systemctl daemon-reload
sudo systemctl enable isard-scripts-update.service

echo ""
trap : 0