#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 24.04 LTS (MySQL v8 - Default setup)"
HOST_NAME="mysql-server-v8"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/core.sh

startup
script-setup
apt-install "mysql-server-8.0"

passwords-add "PostgreSQL" "root" "root"
done-and-reboot