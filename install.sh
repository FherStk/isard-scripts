#!/bin/bash
SCRIPT_VERSION="1.2.0"
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

title "Enabling auto-login..."
if [ $IS_DESKTOP -eq 1 ];
then    
    #Ubuntu Desktop
    _file="/etc/gdm3/custom.conf"
    echo "Setting up the file '$1'"
    sed -i "s|#  AutomaticLoginEnable = true|  AutomaticLoginEnable = true|g" $_file
    sed -i "s|#  AutomaticLogin = user1|  AutomaticLogin = user1|g" $_file

else
    #Ubuntu Server    
    echo "Creating the folder..."
    mkdir -p /etc/systemd/system/getty@tty1.service.d        

    echo "Creating the file '$1'"
    _file="/etc/systemd/system/getty@tty1.service.d/override.conf"
    cp $BASE_PATH/auto-login.conf $_file
    sed -i "s|<USERNAME>|$SUDO_USER|g" $_file    
fi

echo ""
title "Setting up the first launch after user logon (just once):"
if [ $IS_DESKTOP -eq 1 ];
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
    sed -i "s|\\\\&|\&|g" $PROFILE    #TODO: this must be done also in the prior line to detect it
fi

done-no-reboot