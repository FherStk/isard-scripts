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
title "Setting up the first launch after user logon (just once):"
COMMAND="./${DIR}/run.sh"
grep -qxF "'${COMMAND}'" ~/.profile || echo "'${COMMAND}'" >> ~/.profile

grep -qxF "'${COMMAND}'" ~/.profile || echo "'${COMMAND}'"

echo ""
title "Setting up the auto-update after user logon:"
COMMAND="./${DIR}/update.sh"
grep -qxF "'${COMMAND}'" ~/.profile || echo "'${COMMAND}'" >> ~/.profile

#TODO: this does not work...
echo ""
title "Setting up git safe directory:"
git config --global --add safe.directory /home/usuario/isard-scripts

echo ""
echo -e "${GREEN}DONE!${NC}"
echo ""
trap : 0