#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Taiga.io v4)"
HOST_NAME="taiga"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

request-interface
get-interface-address $INTERFACE

apt-install "docker"
apt-install "docker-compose"
cd /home/$SUDO_USER

echo ""
title "Downloading Taiga.io:"
git clone https://github.com/kaleidos-ventures/taiga-docker.git
cd taiga-docker/
git checkout stable

echo ""
title "Setting up the environment:"
echo "Setting up the hostname..."
sed -i "s|localhost|$ADDRESS|g" docker-compose.yml

_user="taiga"
echo "Setting up docker..."
systemctl enable docker
docker-compose up -d

while [ $(docker-compose logs | grep -c "Listening at: http://0.0.0.0:8000") -eq 0 ];
do
    echo "Waiting for taiga services to startup..."
    sleep 5
done
echo "Taiga services are ready..."

echo
title "Setting up the superuser account:"
echo "Creating the superuser account..."
docker-compose -f docker-compose.yml -f docker-compose-inits.yml run --restart unless-stopped --rm taiga-manage createsuperuser --no-input --username $_user --email $_user@$_user.com

echo "Storing the superuser password..."
echo "from django.contrib.auth import get_user_model; User = get_user_model(); u = User.objects.get(username='$_user'); u.set_password('$_user');u.save()" | docker-compose -f docker-compose.yml -f docker-compose-inits.yml run --rm taiga-manage shell

passwords-add "Taiga.io (http://ip:9000)" "$_user" "$_user"
done-and-reboot