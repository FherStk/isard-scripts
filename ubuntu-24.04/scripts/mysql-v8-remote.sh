#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 24.04 LTS (MySQL v8 - With remote connections)"
HOST_NAME="mysql-server-v8"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/core.sh

startup
script-setup
apt-install "mysql-server-8.0"

#TODO: request if populate or not the demo BBDD
#echo ""
#title "Setting up the demo database:"
#rm -Rf test_db
#git clone https://github.com/datacharmer/test_db.git

#cd test_db
#sudo -H -u root bash -c "mysql -t < employees.sql"
#cd ..
#rm -R test_db

echo ""
title "Setting up remote connections:"
echo "Opening the binding address to '*'..."
cp $SCRIPT_PATH/../utils/mysql-v8-remote/mysql.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

echo "Creating the remote user 'root@%'..."
sudo -H -u root bash -c "mysql -e \"CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root'; ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';\""

passwords-add "PostgreSQL" "root" "root"
done-and-reboot