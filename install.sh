#!/bin/bash
SCRIPT_VERSION="1.3.2"
SCRIPT_NAME="App Install"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/utils/main.sh

startup
apt-upgrade

echo ""
title "Installing into $INSTALL_PATH:"
rm -rf $INSTALL_PATH

get-branch
git clone https://github.com/FherStk/isard-scripts.git --branch $CURRENT_BRANCH $INSTALL_PATH

sudo-password-disable
auto-login-enable

echo ""
title "Setting up the first launch after user logon (just once):"
if [ $IS_DESKTOP -eq 1 ];
then     
    #Ubuntu Desktop
    echo "Setting up the $DESKTOPFILE entry..."
    mkdir -p $AUTOSTART
    cp $BASE_PATH/install/isard-scripts.desktop $DESKTOPFILE
    sed -i "s|<INSTALL_PATH>|$INSTALL_PATH|g" $DESKTOPFILE
    sed -i "s|<RUN_SCRIPT>|$RUN_SCRIPT|g" $DESKTOPFILE    
else
    #Ubuntu Server
    echo "Setting up the $PROFILE entry..."
    append-no-repeat "$RUN_SCRIPT" "$PROFILE"
fi

done-no-reboot