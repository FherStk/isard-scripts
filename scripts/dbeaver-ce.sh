#!/bin/bash
SCRIPT_VERSION="1.0.1"
SCRIPT_NAME="Ubuntu Desktop 22.04 LTS (GanttProject v3)"
HOST_NAME="gantt-project"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

snap-req "dbeaver-ce"
run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'io.dbeaver.DBeaverCommunity.desktop']"
done-and-reboot