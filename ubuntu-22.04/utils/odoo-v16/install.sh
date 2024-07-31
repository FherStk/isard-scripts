#!/bin/bash
SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/../core.sh

echo ""
title "Setting up the Odoo repository:"
wget -q -O - https://nightly.odoo.com/odoo.key | sudo gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/16.0/nightly/deb/ ./' | sudo tee /etc/apt/sources.list.d/odoo.list
apt update

apt-install "odoo"
apt-install "xfonts-base"

echo ""
title "Setting up the HTML to PDF prerequisites:"
_file="xfonts-75dpi.deb"
wget http://es.archive.ubuntu.com/ubuntu/pool/universe/x/xfonts-75dpi/xfonts-75dpi_1.0.4+nmu1.1_all.deb -O $_file
dpkg -i $_file
rm -f $_file

_file="libssl1.1.deb"
wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb -O $_file
dpkg -i $_file
rm -f $_file

echo ""
title "Setting up the HTML to PDF component:"
_file="wkhtmltox_0.12.5.deb"
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb -O $_file
dpkg -i $_file
rm -f $_file