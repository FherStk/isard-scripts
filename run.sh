#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="IsardVDI Script App"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/utils/main.sh

trap 'abort' 0
set -e

auto-update true `basename "$0"`
check-sudo

echo ""
trap : 0

directory="./scripts"
options=$(find $directory -mindepth 1 -maxdepth 1 -type f -not -name '*.exe' -printf "%f %TY-%Tm-%Td off\n");
selected_files=$(dialog --radiolist "Pick files out of $directory" 60 70 25 $options --output-fd 1);
clear

for f in $selected_files
do
    #TODO: change run for update within .profile
    #sed -i "s|<PATH>|${DIR}|g" /etc/systemd/system/isard-scripts-first-run.service
    source ./scripts/$f
done