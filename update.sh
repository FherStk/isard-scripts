#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="App Update"

source ./utils/main.sh

trap 'abort' 0
set -e

info "$SCRIPT_NAME" "$SCRIPT_VERSION"
auto-update false

echo ""
trap : 0