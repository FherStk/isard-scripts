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
lxd init --auto

_container="odoo-v16"
_file="/home/ubuntu/install.sh"
lxc launch ubuntu:22.04 $_container
lxc file push $SCRIPT_PATH/../utils/odoo-v16/install.sh $_container$_file
lxc exec $_container -- /bin/bash $_file

passwords-add "PostgreSQL" "postgres" "N/A"
passwords-add "Odoo (http://ip:8069)" "N/A" "N/A"
done-and-reboot