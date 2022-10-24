#!/bin/bash
#Global vars:
BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CURRENT_BRANCH="main"
INSTALL_PATH="/etc/isard-scripts"
RUN_SCRIPT="bash $INSTALL_PATH/run.sh only-splash \&\& echo \&\& echo 'The installer needs sudo permissions...' \&\& sudo bash $INSTALL_PATH/run.sh no-splash"
PROFILE="/home/$SUDO_USER/.profile"
AUTOSTART="/home/$SUDO_USER/.config/autostart"
DESKTOPFILE="$AUTOSTART/isard-scripts.desktop"

# Terminal colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

abort()
{
  #Source: https://stackoverflow.com/a/22224317    
  echo ""
  echo -e "${RED}An error occurred. Exiting...$NC" >&2
  exit 1
}

title(){
  echo -e "${LCYAN}${1}${CYAN}${2}${NC}"
}

apt-upgrade()
{              
    _file="/etc/needrestart/needrestart.conf"
    if test -f "$_file"; then
      #Note: this is needed in order to disable interactive prompts like service-restart on server systems
      echo ""
      title "Enabling non-interactive mode:"
      echo "Disabling kernel restart warnings..."
      sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' $_file
      sed -i 's/#$nrconf{kernelhints} = -1;/$nrconf{kernelhints} = -1;/g' $_file
    fi

    echo ""
    title "Upgrading the installed apps: "
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
}

auto-update()
{     
    echo ""
    title "Checking for a new app version: "
    get-branch

    if [ $(LC_ALL=C git -C $BASE_PATH status -uno | grep -c "Your branch is up to date with 'origin/$CURRENT_BRANCH'") -eq 1 ];
    then     
        echo -e "Up to date, skipping..."
    else
        echo "" 
        echo -e "${CYAN}New version found, updating...$NC"
        git -C $BASE_PATH reset --hard origin/$CURRENT_BRANCH
        echo "Update completed." 

        if [ $1 = true ]; 
        then
          echo "Restarting the app..."
        
          trap : 0
          bash $SCRIPT_PATH/$SCRIPT_FILE
          exit 0
        fi
    fi
}

get-branch()
{
  echo -e "Getting the current branch info..."
  git -C $BASE_PATH fetch --all
  CURRENT_BRANCH=$(git -C $BASE_PATH rev-parse --abbrev-ref HEAD)
}

apt-req()
{
  echo ""
  if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then    
    title "Installing requirements: " "$1"
    apt install -y $1;    
  else 
    echo -e "${CYAN}Requirement ${LCYAN}${1}${CYAN} already satisfied, skipping...$NC"
  fi
}

pip-req()
{
  echo ""
  if [ $(pip3 list 2>/dev/null | grep -io -c "$1") -eq 0 ];
  then        
    if [ -f "$MARK" ]; then 
      title "Installing requirements: " "$1 v$2"
      pip3 install $1==$2;    
    else
      title "Installing requirements: " "$1"
      pip3 install $1;      
    fi
    
  else 
    echo -e "${CYAN}Requirement ${LCYAN}${1}${CYAN} already satisfied, skipping...$NC"
  fi
}

snap-req()
{
  #$1: app to install
  #$2: arguments (--classic)
  echo ""
  if [ $(snap list | grep -c $1) -eq 0 ];
  then    
    title "Installing requirements: " "$1"
    snap install $1 $2;
  else 
    echo -e "${CYAN}Requirement ${LCYAN}${1}${CYAN} already satisfied, skipping...$NC"
  fi
}

set-hostname()
{
  echo ""
  echo "Setting up hostname..."  

  _old_hostname=$(hostname)
  _new_hostname=$(dialog --nocancel --title "Hostname Configuration" --inputbox "\nEnter the host name:" 8 40 $1 --output-fd 1) 
  clear
    
  hostnamectl set-hostname $_new_hostname
  sed -i "s/'$_old_hostname'/'$_new_hostname'/g" /etc/hosts
}

set-address()
{
  echo ""
  echo "Setting up host address..."

  _selected=$(dialog --nocancel --title "Network Configuration: enp3s0" --radiolist "\nSelect a configuration for the 'personal' network interface." 20 70 25 1 DHCP off 2 'Static IP address' on --output-fd 1);
  clear
  
  for f in $_selected
  do      
      if [[ "$f" == 1 ]];
      then        
        set-address-dhcp
      else  
        set-address-static ${1}
      fi
  done
}

set-address-dhcp()
{
  #Some scripts could force this
  echo "Setting up network data..."
  if [ $(dpkg -l ubuntu-desktop | grep -c "ubuntu-desktop") -eq 1 ];
  then     
    #Ubuntu Desktop
    cp $BASE_PATH/netplan-dhcp-desktop.yaml /etc/netplan/01-network-manager-all.yaml
  else
    #Ubuntu Server
    cp $BASE_PATH/netplan-dhcp-server.yaml /etc/netplan/00-installer-config.yaml
  fi

  echo "Setting up netplan..."
  netplan apply
}

set-address-static()
{
  #Some scripts could force this (like dhcp-server.sh)  
  request-ip $1
  echo "Setting up network data..."

  if [ $(dpkg -l ubuntu-desktop | grep -c "ubuntu-desktop") -eq 1 ];
  then     
    #Ubuntu Desktop
    cp $BASE_PATH/netplan-static-desktop.yaml /etc/netplan/01-network-manager-all.yaml
    sed -i "s|x.x.x.x/yy|$ADDRESS|g" /etc/netplan/01-network-manager-all.yaml
  else
    #Ubuntu Server
    cp $BASE_PATH/netplan-static-server.yaml /etc/netplan/00-installer-config.yaml
    sed -i "s|x.x.x.x/yy|$ADDRESS|g" /etc/netplan/00-installer-config.yaml
  fi

  echo "Setting up netplan..."
  netplan apply
}

request-ip()
{
  ADDRESS=$(dialog --nocancel --title "Network Configuration: enp3s0" --inputbox "\nEnter the host address:" 8 40 $1 --output-fd 1)  
  if [ $(ipcalc -b $ADDRESS | grep -c "INVALID ADDRESS") -eq 1 ];
  then
    request-ip   
  else
    clear
  fi
}

done-no-reboot(){
  clean

  echo ""
  echo -e "${GREEN}DONE!$NC"
  echo ""
  trap : 0  
}

done-and-reboot(){
  clean

  echo ""
  echo -e "${GREEN}DONE! Rebooting...$NC"
  trap : 0  
  reboot
}

clean()
{
  echo "Clearing bash history..."
  cat /dev/null > /home/$SUDO_USER/.bash_history   
  history -c
}

run-in-user-session() {
  #source: https://stackoverflow.com/a/54720717
  _display_id=":$(find /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
  _username=$(who | grep "\($_display_id\)" | awk '{print $1}')
  _user_id=$(id -u "$_username")
  _environment=("DISPLAY=$_display_id" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$_user_id/bus")
  
  sudo -Hu "$_username" env "${_environment[@]}" "$@"
}

info()
{
    echo ""
    echo -e "${YELLOW}IsardVDI Template Generator:$NC $1 [v$2]"
    echo -e "${YELLOW}Copyright © 2022:$NC Fernando Porrino Serrano"
    echo -e "${YELLOW}Under the AGPL license:$NC https://github.com/FherStk/isard-scripts/blob/main/LICENSE"
}

startup(){
  trap 'abort' 0
  set -e

  #Splash "screen"
  if [ "$1" != "no-splash" ];
  then 
    info "$SCRIPT_NAME" "$SCRIPT_VERSION"  
  fi
  
  #Checking for "sudo"
  if [ "$EUID" -ne 0 ]
    then 
      echo ""
      echo -e "${RED}Please, run with 'sudo'.$NC"

      trap : 0
      exit 0
  fi    

  #Update if new versions  
  auto-update true

  #Some packages are needed
  echo ""
  title "Installing requirements:"
  sudo apt update
  apt-req "dialog"  #for requesting information
  apt-req "ipcalc"  #for static address validation
}

system-setup()
{
  echo ""
  title "Performing system setup:"
  echo "Disabling auto-upgrades..."
  cp $BASE_PATH/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
  dpkg-reconfigure -f noninteractive unattended-upgrades
}

script-setup(){
  #This is the common script setup, but not for all (dhcp-server forces an static host address)  
  system-setup #must be the first one in order to prevent dpkg blockings
  set-hostname "$HOST_NAME"  
  set-address "192.168.1.1/24"

  apt-upgrade
  apt-req "openssh-server"    

  if [ $(dpkg -l ubuntu-desktop | grep -c "ubuntu-desktop") -eq 1 ];
  then     
    #Ubuntu Desktop
    echo ""
    title "Setting up the desktop:"
    echo "Disabling the session timeout..."
    run-in-user-session gsettings set org.gnome.desktop.session idle-delay 0

    echo "Attaching favourite apps to the dash..."
    run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"

  #else
    #Ubuntu Server   
  fi
}