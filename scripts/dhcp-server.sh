#!/bin/bash
SCRIPT_VERSION="1.0.1"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Default setup)"
HOST_NAME="dhcp-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

startup
set-hostname "${HOST_NAME}"  
set-address-static "192.168.1.1/24"

apt-upgrade
apt-req "openssh-server"  
system-setup

clear-and-reboot