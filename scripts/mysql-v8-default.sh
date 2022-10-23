#!/bin/bash
SCRIPT_VERSION="1.0.2"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (MySQL v8 - Default setup)"
HOST_NAME="mysql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup
apt-req "mysql-server-8.0"
done-and-reboot