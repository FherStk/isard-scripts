#!/bin/bash
SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="App Install"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/utils/main.sh

startup

echo ""
title "Installing into $INSTALL_PATH:"
rm -rf $INSTALL_PATH

get-branch
git clone https://github.com/FherStk/isard-scripts.git --branch $CURRENT_BRANCH $INSTALL_PATH

title "Disabling sudo password..."
_file="/etc/sudoers"
_line="%sudo   ALL=(ALL:ALL) NOPASSWD:ALL"
grep -qxF "$_line" "$_file" || echo "$_line" >> $_file
echo "Done"

echo ""
title "Setting up the first launch after user logon (just once):"
if [ $(dpkg -l ubuntu-desktop | grep -c "ubuntu-desktop") -eq 1 ];
then     
    #Ubuntu Desktop
    echo "Setting up the $DESKTOPFILE entry..."
    mkdir -p $AUTOSTART
    cp $BASE_PATH/isard-scripts.desktop $DESKTOPFILE
    sed -i "s|<INSTALL_PATH>|$INSTALL_PATH|g" $DESKTOPFILE
    sed -i "s|<RUN_SCRIPT>|$RUN_SCRIPT|g" $DESKTOPFILE    
else
    #Ubuntu Server
    echo "Setting up the $PROFILE entry..."
    grep -qxF "$RUN_SCRIPT" "$PROFILE" || echo "$RUN_SCRIPT" >> $PROFILE
    sed -i "s|\\\\&|\&|g" $PROFILE    
fi

done-no-reboot