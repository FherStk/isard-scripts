#!/bin/bash
#Global vars:
BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
IS_DESKTOP=$(dpkg -l ubuntu-desktop 2>/dev/null | grep -c "ubuntu-desktop")
CURRENT_BRANCH="main"
INSTALL_PATH="/etc/isard-scripts"
RUN_SCRIPT="sudo bash $INSTALL_PATH/run.sh"
PROFILE="/home/$SUDO_USER/.profile"
AUTOSTART="/home/$SUDO_USER/.config/autostart"
DESKTOPFILE="$AUTOSTART/isard-scripts.desktop"
PASSWORDS="/home/$SUDO_USER/passwords.info"

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

title(){
  ####################################################################################
  #Description: Displays a title caption using the correct colors. 
  #Input:  $1 => Main caption | $2 => secondary caption
  #Output: N/A
  ####################################################################################

  echo -e "${LCYAN}${1}${CYAN}${2}${NC}"
}

apt-upgrade()
{
  ####################################################################################
  #Description: Updates all the installed apps (apt/snap/flatpak).
  #Input:  N/A
  #Output: N/A
  ####################################################################################   

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
  apt update
  apt upgrade -y
  apt autoremove -y

  if [ $IS_DESKTOP -eq 1 ];
  then   
    snap refresh

    if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then    
      flatpak update -y
    fi
  fi
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

pip-install()
{
  ####################################################################################
  #Description: Installs an app (if not installed) using pip3.
  #Input:  $1 => The app name | $2 (optional) => The app version
  #Output: N/A
  #################################################################################### 

  echo ""
  if [ $(pip3 list 2>/dev/null | grep -io -c "$1") -eq 0 ];
  then    
    _text="Installing pip3 package: "   
    if [ -f "$MARK" ]; then 
      title "$_text" "$1 v$2"
      pip3 install $1==$2;    
    else
      title "$_text" "$1"
      pip3 install $1;      
    fi
    
  else 
    echo -e "${CYAN}Package ${LCYAN}${1}${CYAN} already installed, skipping...$NC"
  fi
}

snap-install()
{
  ####################################################################################
  #Description: Installs an app (if not installed) using snap.
  #Input:  $1 => The app name | $2 (optional) => The snap arguments (like '--classic')
  #Output: N/A
  #################################################################################### 

  echo ""
  if [ $(snap list | grep -c $1) -eq 0 ];
  then    
    title "Installing snap package: " "$1"
    snap install $1 $2;
  else 
    echo -e "${CYAN}Package ${LCYAN}${1}${CYAN} already installed, skipping...$NC"
  fi
}

flatpak-install()
{
  ####################################################################################
  #Description: Installs an app (if not installed) using flatpak.
  #Input:  $1 => The app ID (like 'org.videolan.VLC')
  #Output: N/A
  #################################################################################### 

  echo ""
  if [ $(flatpak list | grep -c $1) -eq 0 ];
  then    
    title "Installing flatpak package: " "$1"
    flatpak install --noninteractive --assumeyes $1;
  else 
    echo -e "${CYAN}Package ${LCYAN}${1}${CYAN} already installed, skipping...$NC"
  fi
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

get-interface-address()
{
  ####################################################################################
  #Description: Displays a graphical prompt with a list of the network interfaces.
  #Input:  $1 => the interface name
  #Output: ADDRESS => the selected network interface.
  #Source: https://stackoverflow.com/a/62578085
  #################################################################################### 
  ADDRESS=$(ip -br -4 a sh | grep "$1" | awk '{print $3}' | cut -d "/" -f 1)
}

setup-network()
{
  ####################################################################################
  #Description: Displays a graphical prompt and sets the current host's address using 
  #             netplan.
  #Input:  $1 => The default new host address
  #Output: N/A
  #################################################################################### 

  request-network-config $1
  
  if [[ "$ADDRESS" == "DHCP" ]];
  then        
    set-network-dhcp
  else  
    set-network-static $ADDRESS
  fi
}

setup-network-static()
{
  ####################################################################################
  #Description: Displays a graphical prompt and sets an static address using netplan.
  #Input:  $1 => The default new host static address
  #Output: N/A
  #################################################################################### 

  #Some scripts could force this (like dhcp-server.sh)  
  request-static-address $1
  set-network-static $ADDRESS
}

setup-hostname()
{
  ####################################################################################
  #Description: Displays a graphical prompt and sets the current host's name.
  #Input:  $1 => The default new host name
  #Output: N/A
  #################################################################################### 

  _new_hostname=$(dialog --nocancel --title "Hostname Configuration" --inputbox "\nEnter the host name:" 8 40 $1 --output-fd 1) 
  clear
    
  set-hostname $_new_hostname
}

set-hostname()
{
  ####################################################################################
  #Description: Sets the current host's name.
  #Input:  $1 => The new host name
  #Output: N/A
  #################################################################################### 

  echo ""
  echo "Setting up hostname..."  

  _old_hostname=$(hostname)     
  hostnamectl set-hostname $1
  sed -i "s/'$_old_hostname'/'$1'/g" /etc/hosts
}

set-network-static()
{
  ####################################################################################
  #Description: Sets an static address using netplan.
  #Input:  $1 => The new host static address
  #Output: N/A
  #################################################################################### 

  #Some scripts could force this (like dhcp-server.sh)    
  echo "Setting up network data..."
  if [ $IS_DESKTOP -eq 1 ];
  then     
    #Ubuntu Desktop
    cp $BASE_PATH/main/netplan-static-desktop.yaml /etc/netplan/01-network-manager-all.yaml
    sed -i "s|x.x.x.x/yy|$1|g" /etc/netplan/01-network-manager-all.yaml
  else
    #Ubuntu Server
    cp $BASE_PATH/main/netplan-static-server.yaml /etc/netplan/00-installer-config.yaml
    sed -i "s|x.x.x.x/yy|$1|g" /etc/netplan/00-installer-config.yaml
  fi

  echo "Setting up netplan..."
  netplan apply
}

set-network-dhcp()
{
  ####################################################################################
  #Description: Setups the netplan for using DHCP (without prompt).
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  #Some scripts could force this2
  echo "Setting up network data..."
  if [ $IS_DESKTOP -eq 1 ];
  then     
    #Ubuntu Desktop
    cp $BASE_PATH/main/netplan-dhcp-desktop.yaml /etc/netplan/01-network-manager-all.yaml
  else
    #Ubuntu Server
    cp $BASE_PATH/main/netplan-dhcp-server.yaml /etc/netplan/00-installer-config.yaml
  fi

  echo "Setting up netplan..."
  netplan apply
}

request-network-config()
{
  ####################################################################################
  #Description: Displays a graphical prompt for the network configuration.
  #Input:  $1 => The default static host address
  #Output: ADDRESS => Returns "DHCP" or a network address
  #################################################################################### 

  echo ""
  echo "Setting up host address..."

  _selected=$(dialog --nocancel --title "Network Configuration: enp3s0" --radiolist "\nSelect a configuration for the 'personal' network interface." 20 70 25 1 DHCP off 2 'Static IP address' on --output-fd 1);
  clear
  
  for f in $_selected
  do      
    if [[ "$f" == 1 ]];
    then        
      ADDRESS="DHCP"
    else  
      request-static-address $1
    fi
  done
}

request-interface()
{
  ####################################################################################
  #Description: Displays a graphical prompt with a list of the network interfaces.
  #Input:  N/A
  #Output: INTERFACE => the selected network interface.
  #Source: https://stackoverflow.com/a/62578085
  #################################################################################### 
  declare –a _interfaces=()
  for iface in $(ip address | grep -oP '(^[\d]+:\s)\K[\d\w]+'); do
    #mac=$(ip address show ${each} | grep -oP '(?<=link/ether\s)\K[\da-f:]+|(?<=link/loopback\s)\K[\da-f:]+')
    #for address in $(ip address show ${iface} | grep -oP '(?<=inet\s)\K[\d.]+|(?<=inet6\s)\K[\da-f:]+'); do
    for address in $(ip address show ${iface} | grep -oP '(?<=inet\s)\K[\d.]+'); do #exclude IPv&      
      _interfaces+=$(echo " $iface $address off")
    done
  done

  _selected=$(dialog --nocancel --title "Network Interfaces" --radiolist "\nSelect a network interface." 20 70 25 $_interfaces --output-fd 1);
  clear
  
  for iface in $_selected
  do      
    INTERFACE=$iface    
  done
}

request-static-address()
{
  ####################################################################################
  #Description: Displays a graphical prompt and requests an static address.
  #Input:  $1 => The default new host static address
  #Output: ADDRESS => The new static address
  #################################################################################### 

  ADDRESS=$(dialog --nocancel --title "Network Configuration: enp3s0" --inputbox "\nEnter the host address:" 8 40 $1 --output-fd 1)  
  if [ $(ipcalc -b $ADDRESS | grep -c "INVALID ADDRESS") -eq 1 ];
  then
    request-static-address   
  else
    clear
  fi
}

done-no-reboot(){
  ####################################################################################
  #Description: Cleans the temp data and the bash history, sets the background
  #             passwords (for desktop only) and prompts an ending message.
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  clean
  passwords-background

  echo ""
  echo -e "${GREEN}DONE!$NC"
  echo ""
  trap : 0  
}

done-and-reboot(){
  ####################################################################################
  #Description: Cleans the temp data and the bash history, sets the background
  #             passwords (for desktop only) and reboots the system.
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  clean
  passwords-background

  echo ""
  echo -e "${GREEN}DONE! Rebooting...$NC"
  trap : 0  
  reboot
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

append-no-repeat()
{
  ####################################################################################
  #Description: Appends a line into a file if does not exist.
  #Input:  $1 => The line to append. | $2 => The file where append.
  #Output: N/A
  ####################################################################################  

  grep -qxF "$1" "$2" || echo "$1" >> $2
}

run-in-user-session() {
  ####################################################################################
  #Description: Runs the given command for the current user (even if sudo)
  #Source: https://stackoverflow.com/a/54720717
  #Input:  $1 => the command to run
  #Output: N/A
  #################################################################################### 
  
  _display_id=":$(find /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
  _username=$(who | grep "\($_display_id\)" | awk '{print $1}')
  _user_id=$(id -u "$_username")
  _environment=("DISPLAY=$_display_id" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$_user_id/bus")
  
  sudo -Hu "$_username" env "${_environment[@]}" "$@"
}

sudo-password-enable()
{
  ####################################################################################
  #Description: Enables the sudo password (the sudo password will be requested).
  #Input:  N/A
  #Output: N/A
  #################################################################################### 
  echo ""
  title "Disabling sudo password..."

  _file="/etc/sudoers"
  echo "Setting up the file '$_file'"
  
  _line="%sudo   ALL=(ALL:ALL) NOPASSWD:ALL"  
  sed -i "s|$_line||g" $_file      
}

sudo-password-disable()
{
  ####################################################################################
  #Description: Disables the sudo password (no sudo password will be requested).
  #Input:  N/A
  #Output: N/A
  ####################################################################################   
  echo ""
  title "Enabling sudo password..."
  
  _file="/etc/sudoers"
  echo "Setting up the file '$_file'"
  
  _line="%sudo   ALL=(ALL:ALL) NOPASSWD:ALL"
  append-no-repeat "$_line" "$_file"
}

auto-login-enable()
{
  ####################################################################################
  #Description: Enables auto-login (no user/password will be prompted).
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  echo ""
  title "Enabling auto-login..."

  if [ $IS_DESKTOP -eq 1 ];
  then    
      #Ubuntu Desktop
      _file="/etc/gdm3/custom.conf"
      echo "Setting up the file '$_file'"
      sed -i "s|#  AutomaticLoginEnable = true|  AutomaticLoginEnable = true|g" $_file
      sed -i "s|#  AutomaticLogin = user1|  AutomaticLogin = $SUDO_USER|g" $_file

  else
      #Ubuntu Server    
      echo "Creating the folder..."
      mkdir -p /etc/systemd/system/getty@tty1.service.d        

      _file="/etc/systemd/system/getty@tty1.service.d/override.conf"
      echo "Creating the file '$_file'"      
      cp $BASE_PATH/main/auto-login.conf $_file
      sed -i "s|<USERNAME>|$SUDO_USER|g" $_file    
  fi
}

auto-login-disable()
{
  ####################################################################################
  #Description: Disables auto-login (user/password will be prompted).
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  echo ""
  title "Disabling auto-login..."

  if [ $IS_DESKTOP -eq 1 ];
  then    
      #Ubuntu Desktop
      _file="/etc/gdm3/custom.conf"
      echo "Setting up the file '$_file'"
      sed -i "s|  AutomaticLoginEnable = true|#  AutomaticLoginEnable = true|g" $_file
      sed -i "s|  AutomaticLogin = $SUDO_USER|  AutomaticLogin = user1|g" $_file

  else
      #Ubuntu Server  
      _file="/etc/systemd/system/getty@tty1.service.d"  
      echo "Removing the file '$_file'"
      rm -Rf $_file
  fi
}

passwords-background()
{
  ####################################################################################
  #Description: Writes the passwords file content into the background image
  #             on desktop systems.
  #Input:  N/A
  #Output: N/A
  #################################################################################### 
  echo ""
  title "Setting up the system credentials information:"
  
  if [ $IS_DESKTOP -eq 1 ];
  then   
    #Manual generation through terminal
    #sudo convert /usr/share/backgrounds/warty-final-ubuntu.png -font helvetica -fill white -pointsize 36 -gravity SouthEast -annotate +50+100 "@/home/usuario/passwords.info" /usr/share/backgrounds/warty-final-ubuntu-text.png  

    #Desktop
    echo "Creating the background image..."
    _source="/usr/share/backgrounds/warty-final-ubuntu.png"
    _dest="/usr/share/backgrounds/warty-final-ubuntu-text.png"
    rm -f $_dest
    convert $_source -font helvetica -fill white -pointsize 36 -gravity SouthEast -annotate +50+100 "@$PASSWORDS" $_dest

    echo "Setting up the background image..."
    run-in-user-session gsettings set org.gnome.desktop.background picture-uri file:///$_dest    

  else
    #Server
    _source="$BASE_PATH/main/50-landscape-sysinfo"
    _dest="/etc/update-motd.d/50-landscape-sysinfo"
    echo "Creating entry into '$_dest'..."    
    cp $_source $_dest
    sed -i "s|<PASSWORDS>|$PASSWORDS|g" $_dest
  fi  
}

passwords-add(){
  ####################################################################################
  #Description: Adds a password entry to the passwords file
  #Input:  $1 => Header | $2 => Username | $3 => Password
  #Output: N/A
  #################################################################################### 
  
  echo "" >> $PASSWORDS
  echo "$1" >> $PASSWORDS
  echo "Username: $2" >> $PASSWORDS
  echo "Password: $3" >> $PASSWORDS
}

info()
{
  ####################################################################################
  #Description: Displays the "slash screen"
  #Input:  N/A
  #Output: N/A
  #################################################################################### 

  echo ""
  echo -e "${YELLOW}IsardVDI Template Generator:$NC $1 [v$2]"
  echo -e "${YELLOW}Copyright © 2023:$NC Fernando Porrino Serrano"
  echo -e "${YELLOW}Under the AGPL license:$NC https://github.com/FherStk/isard-scripts/blob/main/LICENSE"
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
  apt-install "dialog"  #for requesting information
  apt-install "ipcalc"  #for static address validation

  if [ $IS_DESKTOP -eq 1 ];
  then    
    apt-install "imagemagick-6.q16" #background passwords
    sed -i "s|<policy domain=\"path\" rights=\"none\" pattern=\"@|<policy domain=\"path\" rights=\"all\" pattern=\"@|g" /etc/ImageMagick-6/policy.xml
  fi
}

script-setup(){
  ####################################################################################
  #Description: This method should be executed by any script at some point. 
  #               1. Calls system-setup
  #               2. Setups the host name and address
  #               3. Updates all the installed apps
  #               4. Install the common base apps.
  #               5. For desktop systems: disabled the lockdown time and setups the
  #                  dash favourites icons.
  #
  #Input:  $1 => If 'ignore-address' the address setup will be ignored
  #Output: N/A
  #################################################################################### 

  #must be the first one in order to prevent dpkg blockings
  echo ""
  title "Performing system setup:"
  echo "Disabling auto-upgrades..."
  cp $BASE_PATH/main/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
  dpkg-reconfigure -f noninteractive unattended-upgrades  
    
  setup-hostname "$HOST_NAME"  

  _address="192.168.1.1/24"
  if [ "$1" == "static-address" ];
  then       
    setup-network-static $_address
  elif [ "$1" == "dhcp-address" ];
  then       
    set-network-dhcp
  else
    setup-network $_address
  fi

  apt-upgrade

  if [ $IS_DESKTOP -eq 1 ];
  then     
    apt-install "openssh-server"    
    apt-install "curl"

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

  echo ""
  title "Setting up the passwords file:"
  echo "Creating the file..."
  rm -f $PASSWORDS
  touch $PASSWORDS

  echo "Storing basic data..."
  if [ $IS_DESKTOP -eq 1 ];
  then
    #Desktop
    #Printing to an image unaligns the text :(    
    echo "#########################" >> $PASSWORDS
    echo "#   SYSTEM CREDENTIALS   #" >> $PASSWORDS
    echo "#########################" >> $PASSWORDS
  else
    #Server
    echo "##########################" >> $PASSWORDS
    echo "#   SYSTEM CREDENTIALS   #" >> $PASSWORDS
    echo "##########################" >> $PASSWORDS
  fi
  
  passwords-add "Ubuntu" "usuario" "usuario"
}