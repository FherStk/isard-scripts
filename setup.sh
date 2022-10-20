#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="App Setup"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
REALUSER=$(echo $DIR | cut -d "/" -f3) #TODO: this fails if not installed within /home/user_name
PROFILE=/home/${REALUSER}/.profile

source $DIR/utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update true `basename "$0"`
check-sudo

apt-req "dialog"

echo ""
title "Setting up the first launch after user logon (just once):"
COMMAND="bash ${DIR}/run.sh"
grep -qxF "${COMMAND}" ${PROFILE} || echo "${COMMAND}" >> ${PROFILE}

echo ""
title "Setting up the auto-update after user logon:"
COMMAND="bash ${DIR}/update.sh"
grep -qxF "${COMMAND}" ${PROFILE} || echo "${COMMAND}" >> ${PROFILE}

#TODO: this does not work...
echo ""
title "Setting up git safe directory:"
git config --global --add safe.directory /home/usuario/isard-scripts

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0