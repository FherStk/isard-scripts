#!/bin/bash
SCRIPT_VERSION="1.1.1"
SCRIPT_NAME="Ubuntu Desktop 22.04 LTS (Modelio v4)"
HOST_NAME="modelio"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

apt-install "libgdk-pixbuf-xlib-2.0-0"
apt-install "libgdk-pixbuf2.0-0"

echo ""
title "Downloading Modelio and dependencies:"
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=18WmlOhV-qRjSwl-5nBLjCXwTi9wW73DU' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=18WmlOhV-qRjSwl-5nBLjCXwTi9wW73DU" -O modelio_v4.zip && rm -rf /tmp/cookies.txt

echo ""
title "Uncompressing Modelio:"
unzip modelio_v4.zip

echo ""
title "Installing dependencies:"
cd modelio_v4
dpkg -i libicu60_60.2-3ubuntu3_amd64.deb
dpkg -i libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
dpkg -i libegl1-mesa_19.2.8-0ubuntu0~18.04.2_amd64.deb
dpkg -i libhunspell-1.6-0_1.6.2-1_amd64.deb
dpkg -i libenchant1c2a_1.6.0-11.1_amd64.deb
dpkg -i libwebp6_0.6.1-2ubuntu0.18.04.1_amd64.deb
dpkg -i libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb

echo ""
title "Installing Modelio:"
dpkg -i modelio-open-source_4.1.0_ubuntu_amd64.deb
run-in-user-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'modelio-open-source4.1.desktop']"
cd ..

echo ""
title "Cleaning:"
echo "Removing downloaded data..."
rm -f modelio_v4.zip
rm -Rf modelio_v4

done-and-reboot