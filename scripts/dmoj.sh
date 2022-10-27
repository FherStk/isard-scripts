#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (DM::OJ)"
HOST_NAME="dmoj"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup




# apt-install "docker"
# apt-install "docker-compose"

# echo ""
# title "Setiing up the grub entry:"
# sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\"|GRUB_CMDLINE_LINUX_DEFAULT=\"quiet cgroup_enable=memory swapaccount=1\"|g" /etc/default/grub
# update-grub

# echo ""
# title "Installing the database container:"
# _container="dj-mariadb"
# if [ $(docker container ls -a $1 2>/dev/null | grep -c "$_container") -eq 0 ];
# then    
#     docker run -d -it --name $_container -e MYSQL_ROOT_PASSWORD=rootpw -e MYSQL_USER=domjudge -e MYSQL_PASSWORD=djpw -e MYSQL_DATABASE=domjudge -p 13306:3306 mariadb --max-connections=1000
# else 
#     echo -e "${CYAN}Container ${LCYAN}${_container}${CYAN} already installed, skipping...$NC"
# fi

# echo ""
# title "Installing the DOMjudge container:"
# _container="domserver"
# if [ $(docker container ls -a $1 2>/dev/null | grep -c "$_container") -eq 0 ];
# then    
#     docker run -d --link dj-mariadb:mariadb -it -e MYSQL_HOST=mariadb -e MYSQL_USER=domjudge -e MYSQL_DATABASE=domjudge -e MYSQL_PASSWORD=djpw -e MYSQL_ROOT_PASSWORD=rootpw -p 12345:80 --name $_container domjudge/domserver:latest
# else 
#     echo -e "${CYAN}Container ${LCYAN}${_container}${CYAN} already installed, skipping...$NC"
# fi

# echo ""
# title "Installing the judgehost container:"
# _container="judgehost-0"
# if [ $(docker container ls -a $1 2>/dev/null | grep -c "$_container") -eq 0 ];
# then    
#     docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name $_container --link domserver:domserver --hostname judgedaemon-0 -e DAEMON_ID=0 domjudge/judgehost:latest
# else 
#     echo -e "${CYAN}Container ${LCYAN}${_container}${CYAN} already installed, skipping...$NC"
# fi






# passwords-add "DOMjudge (http://<ip>/domjudge)" "admin" $(sudo docker exec -it domserver cat /opt/domjudge/domserver/etc/initial_admin_password.secret)

#10.2.151.180




# echo ""
# title "Setting up the DOMjudge repositories:"
# curl -o - https://www.domjudge.org/repokey.asc | sudo apt-key add -
# append-no-repeat "deb     https://domjudge.org/debian unstable/" /etc/apt/sources.list
# append-no-repeat "deb-src     https://domjudge.org/debian unstable/" /etc/apt/sources.list
# sudo apt update

# echo ""
# title "Downloading DOMjudge:"
# apt-install "domjudge-domserver"

# echo ""
# title "Downloading judgehosts:"
# apt-install "domjudge-judgehost-dbgsym"
# apt-install "make"
# apt-install "pkg-config"
# apt-install "sudo"
# apt-install "debootstrap"
# apt-install "libcgroup-dev"
# apt-install "lsof"
# apt-install "procps"

# wget https://www.domjudge.org/download -O domjudge.tar.gz
# tar -xvzf domjudge.tar.gz

# echo ""
# title "Setting up judgehosts:"
# ./configure --prefix=/home/$SUDO_USER/domjudge
# make judgehost
# make install-judgehost






# echo ""
# title "Setting up user permissions:"
# echo "Adding the current user to the domjudge group"
# usermod -a -G domjudge $SUDO_USER

# echo ""
# title "Setiing up the chroot:"
# dj_make_chroot

# echo ""
# title "Setiing up the grub entry:"
# sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\"|GRUB_CMDLINE_LINUX_DEFAULT=\"quiet cgroup_enable=memory swapaccount=1\"|g" /etc/default/grub
# update-grub


# passwords-add "DOMjudge (http://<ip>/domjudge)" "admin" $(cat /etc/domjudge/initial_admin_password.secret)
done-and-reboot