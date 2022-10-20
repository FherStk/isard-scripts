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
rm -Rf test_db
git clone https://github.com/datacharmer/test_db.git

cd test_db
sudo -H -u root bash -c "mysql -t < employees.sql"
rm -R test_db

echo ""
title "Setting up remote connections:"
echo "Opening the binding address to '*'..."
cp $SCRIPT_PATH/../utils/mysql.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

echo "Creating the remote user 'root@%'..."
sudo -H -u root bash -c "mysql -e \"CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root'; ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';\""

clear-and-reboot