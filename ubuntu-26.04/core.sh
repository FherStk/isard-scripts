#!/bin/bash
#Global vars:
CORE_VERSION="2.1.0"
CORE_DISTRO="Ubuntu 26.04 LTS"
BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CURRENT_BRANCH="main"
CONFIG_PATH=/etc/isard-scripts/config
MAIN_PWD_FILE="$CONFIG_PATH/main-password"

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

info()
{
  ####################################################################################
  #Description: Displays the "slash screen"
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  echo ""
  echo -e "${YELLOW}IsardVDI Template Generator:$NC $1 [v$2]"
  echo -e "${YELLOW}Core distro:$NC ${CORE_DISTRO} [v${CORE_VERSION}]"
  echo -e "${YELLOW}Copyright © 2026:$NC Fernando Porrino Serrano, Oscar Torrente Artero"
  echo -e "${YELLOW}Under the AGPL license:$NC https://github.com/FherStk/isard-scripts/blob/core/LICENSE"
}

title(){
  ####################################################################################
  #Description: Displays a title caption using the correct colors. 
  #Input:  $1 => Main caption | $2 => secondary caption
  #Output: N/A
  ####################################################################################

  echo -e "${LCYAN}${1}${CYAN}${2}${NC}"
}

get-branch()
{
  ####################################################################################
  #Description: Loads the current git branch.
  #Input:  N/A
  #Output: CURRENT_BRANCH => The current git branch
  #################################################################################### 

  echo -e "Getting the current branch info..."
  git -C $BASE_PATH fetch --all
  CURRENT_BRANCH=$(git -C $BASE_PATH rev-parse --abbrev-ref HEAD)
}

auto-update()
{
  ####################################################################################
  #Description: Updates this app and restarts it.
  #Input:  $1 => If 'true' then restarts the app
  #Output: N/A
  ####################################################################################     

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
    git pull
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

apt-install()
{
  ####################################################################################
  #Description: Unnatended package install (if not installed) using apt.
  #Input:  $1 => The app name
  #Output: N/A
  ####################################################################################  

  echo ""
  if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then    
    title "Installing apt package: " "$1"
    DEBIAN_FRONTEND=noninteractive apt install -y $1;    
  else 
    echo -e "${CYAN}Package ${LCYAN}${1}${CYAN} already installed, skipping...$NC"
  fi
}

abort()
{ 
  ####################################################################################
  #Description: Used by "trap" in order to display the error message in red. 
  #Source: https://stackoverflow.com/a/22224317      
  #Input:  N/A
  #Output: N/A
  ####################################################################################

  echo ""
  echo -e "${RED}An error occurred. Exiting...$NC" >&2
  exit 1
}

clean()
{
  ####################################################################################
  #Description: Cleans the temp data and the bash history, no message prompted.
  #Input:  N/A
  #Output: N/A
  #################################################################################### 
  
  echo "Clearing bash history..."
  cat /dev/null > /home/$SUDO_USER/.bash_history   
  history -c
}

startup(){
  ####################################################################################
  #Description: This method must be executed at the begining of each script: 
  #               1. Displays the splash
  #               2. Checks for sudo
  #               3. Updates to the lastest current app version
  #               4. Updates all the installed apps
  #               5. Install the installer requirements.
  #
  #Input:  $1 => first-launch: when 0, avoids some redundant calls (like apt-update, etc.)
  #Output: N/A
  #################################################################################### 
  
  trap 'abort' 0

  #Splash "screen"  
  info "$SCRIPT_NAME" "$SCRIPT_VERSION"    
  
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
  apt update
  apt-install "ansible"  #for setting up apps and config
}