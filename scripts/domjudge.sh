#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (DOMjudge)"
HOST_NAME="domjudge"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

curl -o - https://www.domjudge.org/repokey.asc | sudo apt-key add -
echo "deb     https://domjudge.org/debian unstable/" >> /etc/apt/sources.list
echo "deb-src     https://domjudge.org/debian unstable/" >> /etc/apt/sources.list

apt install domjudge-judgehost-dbgsym domjudge-domserver -y
passwords-add "DOMjudge" "admin" $(cat /etc/domjudge/initial_admin_password.secret)
done-and-reboot