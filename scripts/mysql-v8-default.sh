#!/bin/bash
SCRIPT_VERSION="1.1.1"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (MySQL v8 - Default setup)"
HOST_NAME="mysql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup
apt-install "mysql-server-8.0"

passwords-add "PostgreSQL" "root" "root"
done-and-reboot