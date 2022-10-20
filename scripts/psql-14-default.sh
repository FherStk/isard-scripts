#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (PostgreSQL v14 - Default setup)"
HOST_NAME="psql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

startup
base-setup
apt-req "postgresql-14"
clear-and-reboot