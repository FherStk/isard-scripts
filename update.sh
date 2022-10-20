#!/bin/bash
SCRIPT_VERSION="1.0.1"
SCRIPT_NAME="App Update"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update false

echo ""
trap : 0