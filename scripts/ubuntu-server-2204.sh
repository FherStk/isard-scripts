#!/bin/bash
SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Default setup)"
HOST_NAME="ubuntu-2204-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)

source $SCRIPT_PATH/../utils/main.sh

startup
script-setup
done-and-reboot