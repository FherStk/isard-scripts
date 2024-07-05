#!/bin/bash
SCRIPT_VERSION="1.0.2"
SCRIPT_NAME="Ubuntu Desktop & Server 22.04 LTS (pgAdmin v4)"
HOST_NAME="pgadmin-v4"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

echo ""
title "Setting up the pgAdmin4 repository:"
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg --yes
sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
apt update

if [ $IS_DESKTOP -eq 1 ];
then     
    #Ubuntu Desktop
    apt-install "pgadmin4-desktop"

else
    #Ubuntu Server   
    _user="admin@admin.com"
    _pass="admin"
    apt-install "pgadmin4-web"
    PGADMIN_SETUP_PASSWORD=$_pass PGADMIN_SETUP_EMAIL=$_user /usr/pgadmin4/bin/setup-web.sh --yes
    passwords-add "pgAdmin4 (http://<ip>/pgadmin4)" "$_user" "$_pass"
fi

run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'pgadmin4.desktop']"
done-and-reboot