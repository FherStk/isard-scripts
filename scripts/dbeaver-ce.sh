#!/bin/bash
SCRIPT_VERSION="1.2.0"
SCRIPT_NAME="Ubuntu Desktop 22.04 LTS (DBeaver Community Edition)"
HOST_NAME="gantt-project"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

#INFO: Installing the snap package does not allow selecting the pgadmin root folder in order to use pg_resotre, and with the flatpak package it can work by installing aditional packages:
#      1 => io.dbeaver.DBeaverCommunity 
#      2 => io.dbeaver.DBeaverCommunity.Client.mariadb io.dbeaver.DBeaverCommunity.Client.pgsql 
#      3 => setup DBeaver to use as local client the path "/var/lib/flatpak/runtime/io.dbeaver.DBeaverCommunity.Client.pgsql/x86_64/stable/active/files/bin"
#
#      In order to make it simple for the students, the .deb package will be installed manually.
#snap-install "dbeaver-ce"

echo ""
title "Downloading DBeaver .deb package:"
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O dbeaver-ce.deb


echo ""
title "Installing DBeaver:"
dpkg -i dbeaver-ce.deb

run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'dbeaver-ce.desktop']"
done-and-reboot