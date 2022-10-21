#!/bin/bash
SCRIPT_VERSION="1.0.1"
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
if [ $(dpkg -l ubuntu-desktop | grep -c "ubuntu-desktop") -eq 1 ];
then     
    #Ubuntu Desktop
    mkdir -p ${CONFIG}/autostart
    DESKTOP="${CONFIG}/autostart/isard-scripts.desktop"
    cp ${BASE_PATH}/utils/isard-scripts.desktop ${DESKTOP}
    sed -i "s|SCRIPT_PATH|${AUTOSTART}|g" ${DESKTOP}
else
    #Ubuntu Server
    grep -qxF "${AUTOSTART}" "${PROFILE}" || echo "${AUTOSTART}" >> ${PROFILE}
    echo "Setting up the ${PROFILE} entry..."
fi

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0