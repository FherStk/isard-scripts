#!/bin/bash
SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="App Install"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/utils/main.sh

startup

echo ""
title "Installing into ${INSTALL_PATH}:"
rm -rf ${INSTALL_PATH}

get-branch
git clone https://github.com/FherStk/isard-scripts.git --branch ${CURRENT_BRANCH} ${INSTALL_PATH}

echo ""
title "Setting up the first launch after user logon (just once):"
if [ $(dpkg -l ubuntu-desktop | grep -c "ubuntu-desktop") -eq 1 ];
then     
    #Ubuntu Desktop
    mkdir -p ${AUTOSTART}
    cp ${BASE_PATH}/isard-scripts.desktop ${DESKTOPFILE}
    sed -i "s|<INSTALL_PATH>|${INSTALL_PATH}|g" ${DESKTOPFILE}
    sed -i "s|<RUN_SCRIPT>|${RUN_SCRIPT}|g" ${DESKTOPFILE}
    echo "Setting up the ${DESKTOPFILE} entry..."
else
    #Ubuntu Server
    grep -qxF "${RUN_SCRIPT}" "${PROFILE}" || echo "${RUN_SCRIPT}" >> ${PROFILE}
    echo "Setting up the ${PROFILE} entry..."
fi

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0