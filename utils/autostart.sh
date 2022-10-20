#!/bin/bash
SCRIPT_VERSION="1.0.1"
SCRIPT_NAME="Script Installer"


SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../utils/main.sh


trap : 0
info "$SCRIPT_NAME" "$SCRIPT_VERSION"
echo ""

sudo $SCRIPT_PATH/../run.sh
exit 0