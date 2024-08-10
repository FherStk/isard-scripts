#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 24.04 LTS (PostgreSQL v16 - Default setup)"
HOST_NAME="psql-server-v16"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/core.sh

startup
script-setup
apt-install "postgresql-16"

passwords-add "PostgreSQL" "postgres" "N/A"
done-and-reboot