#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (PostgreSQL v14 - Default setup)"
HOST_NAME="psql-server"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/../utils/main.sh
base-setup
apt-req "postgresql-14"
clear-and-reboot