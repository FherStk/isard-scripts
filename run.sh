#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Script Installer"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/utils/main.sh

trap 'abort' 0
set -e

auto-update true `basename "$0"`
check-sudo

echo ""
trap 'clear' 0

FOLDER="$SCRIPT_PATH/scripts"
OPTIONS=$(find $FOLDER -mindepth 1 -maxdepth 1 -type f -not -name '*.exe' -printf "%f %TY-%Tm-%Td off\n");
SELECTED=$(dialog --title "${SCRIPT_NAME}" --radiolist "\nPick an IsardVDI script in order to install" 60 70 25 $OPTIONS --output-fd 1);
clear

for f in $SELECTED
do
    sed -i "s/'${AUTOSTART}'/'#${AUTOSTART}'/g" ${PROFILE}
    source $SCRIPT_PATH/scripts/$f
done

trap : 0