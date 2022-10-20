#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (PostgreSQL v14 - With remote connections)"
HOST_NAME="psql-server"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh

startup
base-setup
apt-req "postgresql-14"
apt-req "unzip"

echo ""
title "Setting up remote connections:"
echo "Preparing the localhost 'postgres' user..."
sudo -i -u postgres bash -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgres';\""

echo "Opening the binding address to '*'..."
sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" /etc/postgresql/14/main/postgresql.conf

PGHBAFILE="/etc/postgresql/14/main/pg_hba.conf"
PGHBALINE1="host	all		all		192.168.1.1/16		md5" #personal
PGHBALINE2="host	all		all		10.0.0.1/8		    md5" #vpn
grep -qxF "${PGHBALINE1}" "${PGHBAFILE}" || echo "${PGHBALINE1}" >> ${PGHBAFILE}
grep -qxF "${PGHBALINE2}" "${PGHBAFILE}" || echo "${PGHBALINE2}" >> ${PGHBAFILE}

service postgresql restart

echo ""
title "Setting up the demo database:"
wget https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip -O dvdrental.zip
unzip dvdrental.zip
rm -f dvdrental.zip

PGPASSWORD=postgres psql -U postgres -h localhost -c "CREATE DATABASE dvdrental;"
PGPASSWORD=postgres pg_restore -U postgres -h localhost -d dvdrental dvdrental.tar;
rm -f dvdrental.tar

clear-and-reboot