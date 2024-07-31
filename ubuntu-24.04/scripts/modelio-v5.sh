#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Desktop 24.04 LTS (Modelio v5)"
HOST_NAME="modelio-v5"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/core.sh

startup
script-setup

echo ""
title "Downloading Modelio and dependencies:"
wget https://github.com/ModelioOpenSource/Modelio/releases/download/v5.4.1/modelio-open-source-5.4.1_amd64.deb -O modelio.deb

echo ""
title "Installing Modelio:"
dpkg -i modelio.deb
run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'modelio-open-source5.3.desktop']"

echo ""
title "Cleaning:"
echo "Removing downloaded data..."
rm -f modelio.deb

done-and-reboot