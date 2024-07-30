#!/bin/bash
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Default setup)"
HOST_NAME="dhcp-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup "static-address" 
apt-install "isc-dhcp-server"  

echo ""
title "Setting up network names:"
bash /usr/local/bin/isard-scripts-network-setup.sh
echo "Waiting to netplan..."
sleep 3 #TODO: This is an ugly workaround. Option 1) use the "50-ifup-hooks" file to continue with the installation. Option 2) implement the reboot-and-continue option. 
echo "Netplan ready!"

_conf="/etc/dhcp/dhcpd.conf"
_server="/etc/default/isc-dhcp-server"

cp $_conf $_conf.bak
cp $_server $_server.bak
cp $SCRIPT_PATH/../utils/dhcp-server/dhcpd.conf $_conf
cp $SCRIPT_PATH/../utils/dhcp-server/isc-dhcp-server $_server

request-interface "DHCP network interface" "Pick the network interface where the DHCP server should manage: "
sed -i "s|INTERFACESv4=\"\"|INTERFACESv4=\"$INTERFACE\"|g" $_server
sed -i "s|<INTERFACE>|$INTERFACE|g" $_conf

request-static-address "DHCP network interface" "Please, set the subname:" "192.168.1.0"
sed -i "s|<SUBNET>|$ADDRESS|g" $_conf

request-static-address "DHCP network interface" "Please, set the netmask:" "255.255.255.0"
sed -i "s|<NETMASK>|$ADDRESS|g" $_conf

request-static-address "DHCP network interface" "Please, set the first range's IP:" "192.168.1.100"
sed -i "s|<FIRST>|$ADDRESS|g" $_conf

request-static-address "DHCP network interface" "Please, set the last range's IP:" "192.168.1.250"
sed -i "s|<LAST>|$ADDRESS|g" $_conf

_file="/etc/networkd-dispatcher/routable.d/50-ifup-hooks"
cp $SCRIPT_PATH/../utils/dhcp-server/50-ifup-hooks $_file
chmod +x $_file

done-and-reboot