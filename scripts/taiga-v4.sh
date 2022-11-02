#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Taiga.io v4)"
HOST_NAME="taiga"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

apt-install "docker"
apt-install "docker-compose"
cd /home/$SUDO_USER

echo ""
title "Downloading Taiga.io:"
git clone https://github.com/kaleidos-ventures/taiga-docker.git
cd taiga-docker/
git checkout stable

request-interface
get-interface-address $INTERFACE

echo ""
title "Setting up the environment:"
echo "Setting up the hostname..."
sed -i "s|localhost|$ADDRESS|g" docker-compose.yml

echo "Setting up the environment..."
docker-compose up -d
#TODO: check the username and password setup with DJANGO vars
docker-compose -f docker-compose.yml -f docker-compose-inits.yml run --rm taiga-manage createsuperuser -e DJANGO_SUPERUSER_PASSWORD="taiga" DJANGO_SUPERUSER_USERNAME="taiga" DJANGO_SUPERUSER_EMAIL="taiga@taiga.com"
docker-compose up -d

passwords-add "Taiga.io (http://ip:9000)" "taiga" "taiga"
# done-and-reboot