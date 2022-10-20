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
  hostnamectl set-hostname ${1}  
  HOST=$(hostname)
  sed -i "s/'${HOST}'/'${1}'/g" /etc/hosts
}

clear-and-reboot(){
  echo "Clearing bash history..."
  cat /dev/null > ~/.bash_history && history -c

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

check-sudo()
{
  if [ "$EUID" -ne 0 ]
    then 
      echo ""
      echo -e "${RED}Please, run with 'sudo'.${NC}"

      trap : 0
      exit 0
  fi
}

base-setup(){
  trap 'abort' 0
  set -e

  info "$SCRIPT_NAME" "$SCRIPT_VERSION"
  auto-update true `basename "$0"`
  check-sudo

  apt-upgrade
  apt-req "openssh-server"

  echo ""
  title "Performing system changes:"
  echo "Disabling auto-upgrades..."
  cp ${BASE_PATH}/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

  echo "Setting up hostname..."
  set-hostname ${HOST_NAME}

  echo "Setting up netplan..."
  cp ${BASE_PATH}/netplan-server.yaml /etc/netplan/00-installer-config.yaml
  netplan apply
  sleep 10s
}