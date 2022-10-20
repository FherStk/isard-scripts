#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="IsardVDI Script Installer"


SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh


trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
sudo $SCRIPT_PATH/../run.sh

trap : 0
exit 0