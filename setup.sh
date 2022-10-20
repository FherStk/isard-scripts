#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="App Setup"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update true `basename "$0"`
check-sudo

apt-req "dialog"

echo ""
title "Installing into /etc/isard-scripts:"
rm -rf /etc/isard-scripts
git clone https://github.com/FherStk/AutoCheck.git /etc/isard-scripts

echo ""
title "Setting up the first launch after user logon (just once):"
cp $SCRIPT_PATH/utils/rc.local /etc/rc.local
echo "Copying rc.local file..."

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0

#TODO: there is a lot of problems with the relative paths, should be installed outside /home???
# or just do "cd /home... and return to cd $HOME when finished?"