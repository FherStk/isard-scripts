#!/bin/bash
SCRIPT_VERSION="2.1.0"
SCRIPT_NAME="Script Installer"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/core.sh

startup

MAIN_PASSWORD=$(cat $MAIN_PWD_FILE)
sudo -Hu $SUDO_USER ANSIBLE_CONFIG=$SCRIPT_PATH/scripts/ansible.cfg ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook -i localhost, -c local -e "ansible_become_password=$MAIN_PASSWORD" $SCRIPT_PATH/scripts/run.yml

trap : 0
#reboot