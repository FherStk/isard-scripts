#!/bin/bash
SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

trap : 0
sudo $SCRIPT_PATH/../run.sh
exit 0