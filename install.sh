#!/bin/bash
SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="App Install"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/utils/main.sh

startup

echo ""
title "Installing into ${INSTALL_PATH}:"
rm -rf ${INSTALL_PATH}
git clone https://github.com/FherStk/isard-scripts.git ${INSTALL_PATH}

echo ""
title "Setting up the first launch after user logon (just once):"
grep -qxF "${AUTOSTART}" "${PROFILE}" || echo "${AUTOSTART}" >> ${PROFILE}
echo "Setting up the ${PROFILE} entry..."

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0