#!/bin/bash
SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (PostgreSQL v14 - Default setup)"
HOST_NAME="psql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup
apt-install "postgresql-14"

passwords-add "PostgreSQL" "postgres" "N/A"
done-and-reboot