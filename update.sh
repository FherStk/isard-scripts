#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Update"

source ./main.sh

trap 'abort' 0
set -e
auto-update false
trap : 0