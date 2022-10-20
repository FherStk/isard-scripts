#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="App Setup"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update true `basename "$0"`
check-sudo

apt-req "dialog"

echo ""
title "Setting up the isard-scripts-first-run service:"
cp ./utils/isard-scripts-first-run.service /etc/systemd/system/isard-scripts-first-run.service
sed -i "s|<PATH>|${DIR}|g" /etc/systemd/system/isard-scripts-first-run.service
systemctl daemon-reload
sudo systemctl enable isard-scripts-first-run.service

echo ""
title "Setting up the isard-scripts-update service:"
cp ./utils/isard-scripts-update.service /etc/systemd/system/isard-scripts-update.service
sed -i "s|<PATH>|${DIR}|g" /etc/systemd/system/isard-scripts-update.service
systemctl daemon-reload
sudo systemctl enable isard-scripts-update.service

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0