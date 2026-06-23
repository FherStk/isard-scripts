#!/bin/bash
SCRIPT_VERSION="2.1.0"
SCRIPT_NAME="App Install"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
DEFAULT_PWD="pirineus"
source $SCRIPT_PATH/core.sh

startup

request-data "Main user's credentials" "Please, write the password of the current user ($SUDO_USER) in order to automate the setup:" true $DEFAULT_PWD
MAIN_PASSWORD=$DATA

mkdir -p $CONFIG_PATH
echo $MAIN_PASSWORD > $MAIN_PWD_FILE

mkdir -p /etc/sudoers.d
echo "$SUDO_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopass
chmod 0400 /etc/sudoers.d/nopass

sudo -Hu $SUDO_USER ANSIBLE_CONFIG=$SCRIPT_PATH/scripts/ansible.cfg ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook -i localhost, -c local -e "ansible_become_password=$MAIN_PASSWORD" $SCRIPT_PATH/scripts/install.yml

echo ""
echo -e "${GREEN}Installation completed!$NC"
echo -e "${YELLOW}You can now proceed with additional customizations or just shutdown the computer and template it.$NC"

trap : 0