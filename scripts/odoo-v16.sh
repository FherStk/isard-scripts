#!/bin/bash
SCRIPT_VERSION="1.1.2"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (Odoo v16)"
HOST_NAME="odoo-v16"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

source $SCRIPT_PATH/../utils/odoo-v16/install.sh

passwords-add "PostgreSQL" "postgres" "N/A"
passwords-add "Odoo (http://ip:8069)" "N/A" "N/A"
done-and-reboot