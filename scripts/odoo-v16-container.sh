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
_path="/home/ubuntu/"
lxc launch ubuntu:22.04 $_container
lxc file push --recursive $SCRIPT_PATH/../ $_container$_path
lxc exec $_container -- /bin/bash $_path/utils/odoo-v16/install.sh

#TODO: en fer login, mostrar que cal connectar-se via SSH amb port forwarding per a accedir a Odoo
#TODO: mirar si es pot fer una redirecció automàtica perquè no calgui fer la connexió SSH, sinó posar el port
#8069 a la màquina d'isard i que aquesta l'envii cap al contenidor. Serà més fàcil per l'usuari.
#`ssh -L 8069:$_addr:8069 $SUDO_USER@<ip-isard>`

#TODO: port forwarding => https://www.cyberciti.biz/faq/how-to-configure-ufw-to-forward-port-80443-to-internal-server-hosted-on-lan/
#edit /etc/sysctl.conf
#append net.ipv4.ip_forward=1

#sudo sysctl -p
#sudo systemctl restart ufw

#_addr=$(lxc list "odoo-v16" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
#iptables -t nat -A PREROUTING -p tcp --dport 8069 -j DNAT --to-destination $_addr:8069

passwords-add "PostgreSQL" "postgres" "N/A"
passwords-add "Odoo (http://ip:8069)" "N/A" "N/A"
done-and-reboot