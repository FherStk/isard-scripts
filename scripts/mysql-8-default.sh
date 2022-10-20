#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (MySQL v8 - Default setup)"
HOST_NAME="mysql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

startup
base-setup
apt-req "mysql-server-8.0"
clear-and-reboot