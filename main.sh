#!/bin/bash

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

auto-update()
{    
    echo ""
    title "Checking for new script versions: "
    git fetch --all

    if [ $(LC_ALL=C git status -uno | grep -c "Your branch is up to date with 'origin/main'") -eq 1 ];
    then     
        echo -e "Up to date, skipping..."
    else
        echo "" 
        echo -e "${CYAN}New version found, updating...${NC}"
        git reset --hard origin/main
        sh ${1}
        exit 0
    fi
}

apt_req()
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

pip_req()
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

info()
{
    echo ""
    echo -e "${YELLOW}IsardVDI Template Generator:${NC} ${1} (v${2})"
    echo -e "${YELLOW}Copyright © 2022:${NC} Fernando Porrino Serrano"
    echo -e "${YELLOW}Under the AGPL license:${NC} https://github.com/FherStk/isard-scripts/blob/main/LICENSE"
}