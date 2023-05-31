#!/bin/bash
SCRIPT_VERSION="1.2.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Taiga.io v6)"
HOST_NAME="taiga"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

request-interface "Taiga Domain" "Select the network interface where Taiga will be listening to:"
get-interface-address $INTERFACE


apt-install "docker"
apt-install "docker-compose"

_path="/etc/taiga"
cd /home/$SUDO_USER

echo ""
title "Downloading Taiga.io:"
git clone https://github.com/kaleidos-ventures/taiga-docker.git
mv -f taiga-docker $_path
cd $_path
git checkout stable

echo ""
title "Setting up the environment:"
echo "Setting up the hostname..."
sed -i "s|localhost|$ADDRESS|g" .env

_user="taiga"
echo "Setting up docker..."
systemctl enable docker
docker-compose up -d

echo "Waiting for taiga services to startup..."
while [ $(docker-compose logs | grep -c "Listening at: http://0.0.0.0:8000") -eq 0 ];
do    
    sleep 1
done
echo "Taiga services are ready..."

echo
title "Setting up the superuser account:"
echo "Creating the superuser account..."
docker-compose -f docker-compose.yml -f docker-compose-inits.yml run --rm taiga-manage createsuperuser --no-input --username $_user --email $_user@$_user.com

echo "Storing the superuser password..."
echo "from django.contrib.auth import get_user_model; User = get_user_model(); u = User.objects.get(username='$_user'); u.set_password('$_user');u.save()" | docker-compose -f docker-compose.yml -f docker-compose-inits.yml run --rm taiga-manage shell

echo "Creating the startup service..."
_service="/etc/systemd/system/taiga.service"
cp $SCRIPT_PATH/../utils/taiga/taiga.service $_service
sed -i "s|<user>|root|g" $_service
sed -i "s|<path>|$_path|g" $_service
sed -i "s|<file>|launch-taiga.sh|g" $_service

echo "Enabling the startup service..."
systemctl enable taiga
systemctl start taiga

passwords-add "Taiga.io (http://ip:9000)" "$_user" "$_user"
done-and-reboot