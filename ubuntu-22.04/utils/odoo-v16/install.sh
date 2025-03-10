#!/bin/bash
SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../core.sh

echo ""
title "Setting up the HTML to PDF component:"
_file="wkhtmltox.deb"
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb -O $_file
dpkg -i $_file
apt install -f
dpkg -i $_file
rm -f $_file

echo ""
title "Setting up the Odoo repository:"
wget -q -O - https://nightly.odoo.com/odoo.key | sudo gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/16.0/nightly/deb/ ./' | sudo tee /etc/apt/sources.list.d/odoo.list
apt update
apt-install "odoo"