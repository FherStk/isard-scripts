#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Desktop 22.04 LTS (Default setup)"
HOST_NAME="ubuntu-2204-desktop"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

title "Setting up the desktop:"
echo "Disabling the session timeout..."
run-in-user-session gsettings set org.gnome.desktop.session idle-delay 0

echo "Attaching favourite apps to the dash..."
run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'thunderbird.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"

#clear-and-reboot