#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Desktop 24.04 LTS (GanttProject v3)"
HOST_NAME="gantt-project-v3"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/core.sh

startup
script-setup

apt-install "default-jre"

echo ""
title "Downloading GanttProject:"
wget https://www.ganttproject.biz/dl/3.3.3309/lin -O ganttproject.deb

echo ""
title "Installing GanttProject:"
dpkg -i ganttproject.deb
run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'ganttproject.desktop']"

echo ""
title "Cleaning:"
echo "Removing downloaded data..."
rm -f ganttproject.deb

done-and-reboot