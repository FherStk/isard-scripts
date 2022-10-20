#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="App Update"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update false

echo ""
trap : 0