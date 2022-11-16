#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Odoo v16 - Within an LXC/LXD container)"
HOST_NAME="odoo"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup
apt-install lxc

echo ""
title "Setting up the LXC/LXD container:"
lxd init --auto

_container="odoo-v16"
_path="/home/ubuntu/"
lxc launch ubuntu:22.04 $_container
lxc file push --recursive $SCRIPT_PATH/../ ${_container}${_path}
lxc exec $_container -- /bin/bash $_path/isard-scripts/utils/odoo-v16/install.sh

#WARNING:  The container requests the IP address using its MAC address as the identifier, so, in theory, should be the same on any scenario.
#          If the container's IP address changes, the following lines should be invoked on startup.
#          TIP: this also works -> ssh -L 8069:$_addr:8069 $SUDO_USER@<ip-isard>        

echo ""
title "Setting up port forwarding to the LXC/LXD container:"

#Source: https://www.cyberciti.biz/faq/how-to-configure-ufw-to-forward-port-80443-to-internal-server-hosted-on-lan/
append-no-repeat "net.ipv4.ip_forward=1" "/etc/sysctl.conf"

_addr=$(lxc list "odoo-v16" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
iptables -t nat -A PREROUTING -p tcp --dport 8069 -j DNAT --to-destination $_addr:8069

sysctl -p
systemctl restart ufw

echo ""
title "Performing the initial LXC/LXD snapshot:"
lxc snapshot odoo-v16 $_container initial
echo "Done"

passwords-add "PostgreSQL" "postgres" "N/A"
passwords-add "Odoo (http://ip:8069)" "N/A" "N/A"
#done-and-reboot