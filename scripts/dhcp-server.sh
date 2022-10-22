#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Default setup)"
HOST_NAME="dhcp-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

startup
system-setup
set-hostname "${HOST_NAME}"  
set-address-static "192.168.1.1/24"

apt-upgrade
apt-req "openssh-server"  
apt-req "isc-dhcp-server"  

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
cp $SCRIPT_PATH/../utils/dhcpd.conf /etc/dhcp/dhcpd.conf
sed -i 's|INTERFACESv4=""|INTERFACESv4="enp3s0"|g' /etc/default/isc-dhcp-server
systemctl restart isc-dhcp-server.service

clear-and-reboot