#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="IsardVDI Script App"

source ./utils/main.sh

trap 'abort' 0
set -e

declare -a scripts
for file in ./scipts/*.sh
do
    scripts=("${scripts[@]}" "$file")
done

while choice=$(dialog --title "$SCRIPT_NAME" \
                 --menu "Please select" 10 40 3 "${scripts[@]}" \
                 2>&1 >/dev/tty)
    do
    case $choice in
        1) ;; # some action on 1
        2) ;; # some action on 2
        *) ;; # some action on other
    esac
done
clear # clear after user pressed Cancel

echo ""
trap : 0