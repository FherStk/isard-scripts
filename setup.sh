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
title "Installing into ${INSTALL_PATH}:"
rm -rf ${INSTALL_PATH}
git clone https://github.com/FherStk/isard-scripts.git ${INSTALL_PATH}

echo ""
title "Setting up the first launch after user logon (just once):"
#cp $SCRIPT_PATH/utils/rc.local /etc/rc.local
#echo "Copying rc.local file..."
grep -qxF "${AUTOSTART}" "${PROFILE}" || echo "${AUTOSTART}" >> ${PROFILE}
echo "Setting up the ${PROFILE} entry..."

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0