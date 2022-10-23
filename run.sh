#!/bin/bash
SCRIPT_VERSION="1.3.0"
SCRIPT_NAME="Script Installer"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/utils/main.sh

if [ "$1" == "only-splash" ];
then
    info "$SCRIPT_NAME" "$SCRIPT_VERSION"
else
    startup $1    

    echo ""
    trap 'clear' 0

    unset _options
    _folder="$SCRIPT_PATH/scripts"
    _options=$(find ${_folder} -mindepth 1 -maxdepth 1 -type f -name '*.sh' -printf "%f %TY-%Tm-%Td off\n" | sort -t '\0' -n | awk -F '\0' '{print $1}');
    _options+=$(echo " NONE 1900-01-01 off")

    _selected=$(dialog --title "${SCRIPT_NAME} v${SCRIPT_VERSION}" --radiolist "\nPick an IsardVDI script in order to install" 60 70 25 $_options --output-fd 1);
    clear

    for f in $_selected
    do        
        #For Ubuntu Server
        sed -i "s|${RUN_SCRIPT}|#${RUN_SCRIPT}|g" ${PROFILE}

        #For Ubuntu Desktop
        rm -f ${DESKTOPFILE}

        source $SCRIPT_PATH/scripts/$f
    done

    trap : 0
fi