#!/bin/bash
SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Default setup)"
HOST_NAME="dhcp-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup "static-address" 

apt-install "isc-dhcp-server"  

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
cp $SCRIPT_PATH/../utils/dhcpd.conf /etc/dhcp/dhcpd.conf
sed -i 's|INTERFACESv4=""|INTERFACESv4="enp3s0"|g' /etc/default/isc-dhcp-server
systemctl restart isc-dhcp-server.service

done-and-reboot