#!/bin/bash
SCRIPT_VERSION="1.0.3"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Default setup)"
HOST_NAME="ubuntu-2204-server"

echo "AAA"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

echo "BBB"

startup

echo "CCC"

script-setup

echo "DDD"

done-and-reboot