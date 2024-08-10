#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 24.04 LTS (Open-Project v14)"
HOST_NAME="open-project-v14"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/core.sh

startup
script-setup

echo ""
title "Downloading OpenProject's public key:"
wget -qO- https://dl.packager.io/srv/opf/openproject/key | sudo apt-key add -


echo ""
title "Adding the repository:"
wget -O /etc/apt/sources.list.d/openproject.list https://dl.packager.io/srv/opf/openproject/stable/14/installer/ubuntu/24.04.repo

apt update    
apt-install "openproject"

echo ""
title "Copying the auto-setup configuration file:"
cp $SCRIPT_PATH/../utils/open-project-v14/installer.dat /etc/openproject/installer.dat

echo ""
title "Setting up Open-Project:"
openproject configure #non-interactive

passwords-add "Open-Project (http://<ip>)" "admin" "admin"
done-and-reboot