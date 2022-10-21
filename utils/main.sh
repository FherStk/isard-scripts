#!/bin/bash
BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
INSTALL_PATH="/etc/isard-scripts"
AUTOSTART="bash ${INSTALL_PATH}/utils/autostart.sh"
PROFILE="/home/$SUDO_USER/.profile"

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
  echo -e "${RED}An error occurred. Exiting...${NC}" >&2
  exit 1
}

title(){
  echo -e "${LCYAN}${1}${CYAN}${2}${NC}"
}

apt-upgrade()
{
    echo ""
    title "Upgrading the installed apps: "
    #Note: this is needed in order to disable interactive prompts like service-restart...
    sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
    sed -i 's/#$nrconf{kernelhints} = -1;/$nrconf{kernelhints} = -1;/g' /etc/needrestart/needrestart.conf

    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
}

auto-update()
{    
    echo ""
    title "Checking for a new app version: "
    git -C ${BASE_PATH} fetch --all
    BRANCH=$(git -C ${BASE_PATH} rev-parse --abbrev-ref HEAD) 

    if [ $(LC_ALL=C git -C ${BASE_PATH} status -uno | grep -c "Your branch is up to date with 'origin/${BRANCH}'") -eq 1 ];
    then     
        echo -e "Up to date, skipping..."
    else
        echo "" 
        echo -e "${CYAN}New version found, updating...${NC}"
        git -C ${BASE_PATH} reset --hard origin/${BRANCH}
        echo "Update completed." 

        if [ $1 = true ]; 
        then
          echo "Restarting the app..."

          trap : 0
          bash ${SCRIPT_PATH}/${2}          
          exit 0
        fi
    fi
}

apt-req()
{
  echo ""
  if [ $(dpkg-query -W -f='${Status}' ${1} 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then    
    title "Installing requirements: " "${1}"
    apt install -y ${1};    
  else 
    echo -e "${CYAN}Requirement ${LCYAN}${1}${CYAN} already satisfied, skipping...${NC}"
  fi
}

pip-req()
{
  echo ""
  if [ $(pip3 list 2>/dev/null | grep -io -c "${1}") -eq 0 ];
  then        
    if [ -f "$MARK" ]; then 
      title "Installing requirements: " "${1} v${2}"
      pip3 install ${1}==${2};    
    else
      title "Installing requirements: " "${1}"
      pip3 install ${1};      
    fi
    
  else 
    echo -e "${CYAN}Requirement ${LCYAN}${1}${CYAN} already satisfied, skipping...${NC}"
  fi
}

set-hostname()
{
  echo ""
  echo "Setting up hostname..."  

  OLDHOSTNAME=$(hostname)
  NEWHOSTNAME=$(dialog --nocancel --title "Hostname Configuration" --inputbox "\nEnter the hostname:" 8 40 ${1} --output-fd 1) 
  clear
    
  hostnamectl set-hostname ${NEWHOSTNAME}  
  sed -i "s/'${OLDHOSTNAME}'/'${NEWHOSTNAME}'/g" /etc/hosts
}

set-address()
{
  echo ""
  echo "Setting up host address..."

  SELECTED=$(dialog --nocancel --title "Network Configuration: enp3s0" --radiolist "\nSelect a configuration for the 'personal' network interface." 20 70 25 1 DHCP on 2 'Static IP address' off --output-fd 1);
  clear
  
  for f in $SELECTED
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
  cp ${BASE_PATH}/netplan-dhcp-server.yaml /etc/netplan/00-installer-config.yaml
  
  echo "Setting up netplan..."
  netplan apply
}

set-address-static()
{
  #Some scripts could force this (like dhcp-server.sh)  
  request-ip ${1}
  echo "Setting up network data..."

  cp ${BASE_PATH}/netplan-static-server.yaml /etc/netplan/00-installer-config.yaml
  sed -i "s|x.x.x.x/yy|${ADDRESS}|g" /etc/netplan/00-installer-config.yaml

  echo "Setting up netplan..."
  netplan apply
}

request-ip()
{
  ADDRESS=$(dialog --nocancel --title "Network Configuration: enp3s0" --inputbox "\nEnter an IP address:" 8 40 ${1} --output-fd 1)  
  if [ $(ipcalc -b ${ADDRESS} | grep -c "INVALID ADDRESS") -eq 1 ];
  then
    request-ip   
  else
    clear
  fi
}

clear-and-reboot(){
  echo "Clearing bash history..."
  cat /dev/null > ~/.bash_history && history -c

  echo ""
  echo -e "${GREEN}DONE! Rebooting...${NC}"
  trap : 0  
  reboot
}

info()
{
    echo ""
    echo -e "${YELLOW}IsardVDI Template Generator:${NC} ${1} [v${2}]"
    echo -e "${YELLOW}Copyright © 2022:${NC} Fernando Porrino Serrano"
    echo -e "${YELLOW}Under the AGPL license:${NC} https://github.com/FherStk/isard-scripts/blob/main/LICENSE"
}

system-changes()
{
  echo ""
  title "Performing system changes:"
  echo "Disabling auto-upgrades..."
  cp ${BASE_PATH}/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
}

startup(){
  trap 'abort' 0
  set -e

  #Splash "screen"
  info "$SCRIPT_NAME" "$SCRIPT_VERSION"  
  
  #Checking for "sudo"
  if [ "$EUID" -ne 0 ]
    then 
      echo ""
      echo -e "${RED}Please, run with 'sudo'.${NC}"

      trap : 0
      exit 0
  fi  
  echo ""

  #Update if new versions
  auto-update true `basename "$0"`

  #Some packages are needed
  title "Installing dependencies:"
  sudo apt update
  apt-req "dialog"  #for requesting information
  apt-req "ipcalc"  #for static address validation
}

base-setup(){
  #This is the common script setup, but not for all (dhcp-server forces an static host address)  
  set-hostname "${HOST_NAME}"  
  set-address "192.168.1.1/24"

  apt-upgrade
  apt-req "openssh-server"  
  system-changes
}