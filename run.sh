#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="IsardVDI Script App"

directory="./scripts"
options=$(find $directory -mindepth 1 -maxdepth 1 -type f -not -name '*.exe' -printf "%f %TY-%Tm-%Td off\n");
selected_files=$(dialog --radiolist "Pick files out of $directory" 60 70 25 $options --output-fd 1);
clear

for f in $selected_files
do
 source ./scripts/$f
done