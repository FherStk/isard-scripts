#!/bin/bash
SCRIPT_VERSION="1.4.3"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (DMOJ v4.0)"
HOST_NAME="dmoj-v4"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
DMOJ_USER="dmoj"
DMOJ_PATH="/etc/dmoj"
DMOJ_SITE="$DMOJ_PATH/site"
DMOJ_MEDIA="$DMOJ_PATH/media"
DMOJ_VENV="$DMOJ_PATH/dmojsite"

source $SCRIPT_PATH/../utils/core.sh

startup
script-setup

#################################
#     DM:OJ FRONTEND (SITE)     #
#################################

apt-install "gcc"
apt-install "g++"
apt-install "make"
apt-install "python3-dev"
apt-install "python3-pip"
apt-install "python3-venv"
apt-install "libxml2-dev"
apt-install "libxslt1-dev"
apt-install "zlib1g-dev"
apt-install "gettext"
apt-install "curl"
apt-install "redis-server"
apt-install "pkg-config"

echo ""
title "Setting up the nodeJS repositories:"
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
echo "Done"

apt-install "nodejs"

echo ""
title "Installing node-js dependencies:"
npm install -g sass postcss-cli postcss autoprefixer

apt-install "mariadb-server"
apt-install "libmysqlclient-dev"

echo ""
title "Setting up the database:"
echo "Creating the dmoj database..."
sudo -H -u root bash -c "mysql -e \"CREATE DATABASE IF NOT EXISTS dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;\""

echo "Granting privileges to the dmoj user..."
sudo -H -u root bash -c "mysql -e \"GRANT ALL PRIVILEGES ON dmoj.* TO 'dmoj'@'localhost' IDENTIFIED BY 'dmoj';\""

echo "Populating timezones..."
sudo -H -u root bash -c "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql"

echo ""
title "Creating the installation folder at $DMOJ_PATH:"
mkdir -p $DMOJ_PATH
echo "Done"

echo ""
title "Setting up the virtual environment:"
cd $DMOJ_PATH
python3 -m venv dmojsite
. dmojsite/bin/activate
echo "Done"

echo ""
title "Downloading DM::OJ:"
git clone https://github.com/DMOJ/site.git
cd site
git checkout v4.0.0
git submodule init
git submodule update

echo ""
title "Installing the python dependencies:"
pip3 install -r requirements.txt

pip-install "websocket-client"
pip-install "mysqlclient"
pip-install "pymysql"
pip-install "lxml_html_clean"

echo ""
title "Creating the DMOJ user:"
useradd -m -p $DMOJ_USER $DMOJ_USER

echo ""
title "Setting up DM::OJ:"
_file="dmoj/local_settings.py"
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/local_settings.py -O $_file
sed -i "s|'This key is not very secure and you should change it.'|'5*9f5q57mqmlz2#f\$x1h76\\&jxy#yortjl1v+l*6hd18\$d*yx#0'|g" $_file
sed -i "s|'<mariadb user password>'|'$DMOJ_USER'|g" $_file
sed -i "s|#EVENT_DAEMON_USE = True|EVENT_DAEMON_USE = True|g" $_file
sed -i "s|#EVENT_DAEMON_POST = 'ws://127.0.0.1:15101/'|EVENT_DAEMON_POST = 'ws://127.0.0.1:15101/'|g" $_file
sed -i "s|#EVENT_DAEMON_GET = 'ws://<your domain>/event/'|EVENT_DAEMON_GET = 'ws://127.0.0.1/event/'|g" $_file
sed -i "s|#EVENT_DAEMON_POLL = '/channels/''|EVENT_DAEMON_POLL = '/channels/'|g" $_file

./make_style.sh
python3 manage.py collectstatic
python3 manage.py compilemessages
python3 manage.py compilejsi18n
python3 manage.py migrate
python3 manage.py loaddata navbar
python3 manage.py loaddata language_small
python3 manage.py loaddata demo

pip-install "redis"
service redis-server start


_file="dmoj/local_settings.py"
sed -i "s|#CELERY_BROKER_URL|CELERY_BROKER_URL|g" $_file
sed -i "s|#CELERY_RESULT_BACKEND|CELERY_RESULT_BACKEND|g" $_file
sed -i "s|#ALLOWED_HOSTS = \['dmoj.ca'\]|ALLOWED_HOSTS = \['\*'\]|g" $_file
sed -i "s|<desired bridge log path>|bridge.log|g" $_file
echo "DMOJ_PROBLEM_DATA_ROOT = '$DMOJ_PATH/problems/'" >> $_file
echo "REGISTRATION_OPEN = False" >> $_file
echo "DEFAULT_USER_LANGUAGE = 'JAVA8'" >> $_file
echo "DMOJ_SUBMISSION_SOURCE_VISIBILITY = 'only-own'" >> $_file
echo "MEDIA_ROOT = '$DMOJ_MEDIA/'" >> $_file
echo "MEDIA_URL = '/media/'" >> $_file

pip-install "uwsgi"
echo ""
title "Setting up uwsgi:"

_file="dmoj/uwsgi.ini" 
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/uwsgi.ini -O $_file
sed -i "s|chdir = <dmoj repo dir>|chdir = $DMOJ_VENV|g" $_file #TEST THIS LINE
sed -i "s|<dmoj repo dir>|$DMOJ_SITE|g" $_file
sed -i "s|<virtualenv path>|$DMOJ_VENV|g" $_file

apt-install "supervisor"
echo ""
title "Setting up supervisor:"

_file="/etc/supervisor/conf.d/site.conf"
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/site.conf -O $_file
sed -i "s|command=<path to virtualenv>/bin/uwsgi --ini uwsgi.ini|command=$DMOJ_VENV/bin/uwsgi --ini $DMOJ_SITE/dmoj/uwsgi.ini|g" $_file
sed -i "s|<path to site>|$DMOJ_SITE|g" $_file

echo ""
title "Setting up bridged:"

_file="/etc/supervisor/conf.d/bridged.conf"
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/bridged.conf -O $_file
sed -i "s|<path to virtualenv>|$DMOJ_VENV|g" $_file
sed -i "s|<path to site>|$DMOJ_SITE|g" $_file
sed -i "s|<user to run under>|$DMOJ_USER|g" $_file

echo ""
title "Setting up celery:"

_file="/etc/supervisor/conf.d/celery.conf"
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/celery.conf -O $_file
sed -i "s|<path to virtualenv>|$DMOJ_VENV|g" $_file
sed -i "s|<path to site>|$DMOJ_SITE|g" $_file
sed -i "s|<user to run under>|$DMOJ_USER|g" $_file

echo ""
title "Reloading supervisor:"
supervisorctl update
supervisorctl status

echo ""
title "Setting up nginx:"
apt-install "nginx"

_file="/etc/nginx/sites-available/default"
cp $SCRIPT_PATH/../utils/dmoj/nginx.conf $_file
sed -i "s|<site code path>|$DMOJ_SITE|g" $_file
sed -i "s|<site media path>|$DMOJ_MEDIA/|g" $_file

echo ""
title "Setting up the event server:"
npm install qu ws simplesets
pip-install websocket-client

_file="$DMOJ_SITE/websocket/config.js"
cp $SCRIPT_PATH/../utils/dmoj/config.js $_file

_file="/etc/supervisor/conf.d/wsevent.conf"
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/wsevent.conf -O $_file
sed -i "s|<site repo path>|$DMOJ_SITE|g" $_file
sed -i "s|<username>|$DMOJ_USER|g" $_file

echo ""
title "Setting up the problems:"
echo "Creating the media folder..."
mkdir $DMOJ_PATH/media
echo "Done!"

echo "Creating the problems folder..."
mkdir $DMOJ_PATH/problems
echo "Done!"

echo "Creating the aplusb problem folder..."
_path=$DMOJ_PATH/problems/aplusb 
mkdir $_path
echo "Done!"

echo "Downloading the aplusb problem data..."
wget https://github.com/DMOJ/docs/raw/master/problem_examples/standard/aplusb/aplusb.zip -O $_path/aplusb.zip
wget https://raw.githubusercontent.com/DMOJ/docs/master/problem_examples/standard/aplusb/init.yml -O $_path/init.yml
echo "Done!"

echo "Restarting services..."
service nginx reload
supervisorctl update
supervisorctl restart bridged
supervisorctl restart site
service nginx restart
echo "Done!"

#################################
#     DM:OJ BACKEND (JUDGE)     #
#################################

echo ""
title "Setting up the judge:"

apt-install "build-essential"
apt-install "libseccomp-dev"
apt-install "default-jdk"
apt-install "openjdk-11-jdk"
apt-install "openjdk-8-jdk"

cd $DMOJ_PATH
git clone --recursive https://github.com/DMOJ/judge-server.git
cd judge-server
pip3 install -e .
cd ..

_judge_name="default";
_judge_key="5qwU1VFlfiv1wi1PHsXG7Z2nQika73VyLOvk3Dcd3Ma/PajJw/VRzNHc7o7lg5CfRvPvGfLOmjjmGmT1im6D3dSu0FwsQyINANhW"
sudo -H -u root bash -c "mysql -D dmoj -e \"INSERT INTO judge_judge (name, auth_key, created, is_blocked, online, description, is_disabled) VALUES ('$_judge_name', '$_judge_key', now(), 0, 0, '', false);\""

_file="$DMOJ_PATH/problems/judge.yml"
cp $SCRIPT_PATH/../utils/dmoj/judge.yml $_file
sed -i "s|<judge name>|$_judge_name|g" $_file
sed -i "s|<judge authentication key>|$_judge_key|g" $_file
sed -i "s|<judge problems>|$DMOJ_PATH/problems/*|g" $_file
echo "" >>  $_file #new line
dmoj-autoconf >>  $_file

echo ""
title "Setting up the startup service:"
echo "Creating the startup script..."
_startup="$DMOJ_PATH/startup.sh"
cp $SCRIPT_PATH/../utils/dmoj/startup.sh $_startup
sed -i "s|<dmoj-root-path>|$DMOJ_PATH|g" $_startup
chmod +x $_startup

echo "Creating the startup service..."
_service="/etc/systemd/system/dmoj-judge.service"
cp $SCRIPT_PATH/../utils/dmoj/dmoj-judge.service $_service
sed -i "s|<user>|$DMOJ_USER|g" $_service
sed -i "s|<file>|$_startup|g" $_service

echo "Setting up permissions..."
cd $DMOJ_PATH
chown -R $DMOJ_USER:$DMOJ_USER dmojsite
chown -R $DMOJ_USER:$DMOJ_USER judge-server
chown -R $DMOJ_USER:$DMOJ_USER problems
chown -R $DMOJ_USER:$DMOJ_USER site
chown -R $DMOJ_USER:$DMOJ_USER media
chown -R $DMOJ_USER:$DMOJ_USER /tmp/static
chown $DMOJ_USER:$DMOJ_USER startup.sh

echo "Enabling the startup service..."
systemctl enable dmoj-judge
systemctl start dmoj-judge

passwords-add "DM::OJ (http://<ip>)" "admin" "admin"
done-and-reboot

#INFO: for checking possible promlems during the execution
#sudo supervisorctl status => all must be running
#
#Logs:
#cat /var/log/nginx/error.log 
#cat /var/log/supervisor/supervisord.log
#cat /tmp/bridge.stderr.log
#cat /tmp/site.stderr.log
#cat /tmp/celery.stderr.log
#cat /tmp/wsevent.stderr.log
