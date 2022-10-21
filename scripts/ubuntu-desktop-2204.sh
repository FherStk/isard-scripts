#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Desktop 22.04 LTS (Default setup)"
HOST_NAME="ubuntu-2204-desktop"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

#TODO:
#   disable screen energy saving
#   remove some items from the side bar

clear-and-reboot