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
append-no-repeat "deb     https://domjudge.org/debian unstable/" /etc/apt/sources.list
append-no-repeat "deb-src     https://domjudge.org/debian unstable/" /etc/apt/sources.list
sudo apt update

apt-install "domjudge-judgehost-dbgsym"
apt-install "domjudge-domserver"

passwords-add "DOMjudge (http://<ip>/domjudge)" "admin" $(cat /etc/domjudge/initial_admin_password.secret)
done-and-reboot