#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (MySQL v8 - With remote connections)"
HOST_NAME="mysql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

base-setup
apt-req "mysql-server-8.0"
apt-req "unzip"

echo ""
title "Setting up the demo database:"
#wget https://github.com/datacharmer/test_db/archive/refs/heads/master.zip -O master.zip
unzip master.zip
rm master.zip

sudo -H -u root bash -c "mysql -t < ${PWD}/test_db-master/employees.sql"
rm -R ${PWD}/test_db-master

#sed -i "s|#bind-address|g" /etc/mysql/mysql.conf.d/mysqld.cnf 

#sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf 

#clear-and-reboot