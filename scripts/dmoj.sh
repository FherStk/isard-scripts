#!/bin/bash
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Ubuntu Server 22.04 LTS (DM::OJ)"
HOST_NAME="dmoj"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
source $SCRIPT_PATH/../utils/main.sh

startup
script-setup

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

echo ""
title "Setting up the nodeJS repositories:"
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
echo "Done"

apt-install "nodejs"

echo ""
title "Installing node-js dependencies:"
npm install -g sass postcss-cli postcss autoprefixer

apt-install "mariadb-server"
apt-install "libmysqlclient-dev"

echo ""
title "Setting up the database:"
sudo -H -u root bash -c "mysql -e \"CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;\""
sudo -H -u root bash -c "mysql -e \"GRANT ALL PRIVILEGES ON dmoj.* TO 'dmoj'@'localhost' IDENTIFIED BY 'dmoj';\""

echo ""
title "Setting up the virtual enviroment:"
python3 -m venv dmojsite
. dmojsite/bin/activate

echo ""
title "Downloading DM::OJ:"
git clone https://github.com/DMOJ/site.git
cd site
git submodule init
git submodule update

echo ""
title "Installing the python dependencies:"
pip3 install -r requirements.txt

pip-install mysqlclient
pip-install pymysql
pip-install uwsgi

echo ""
title "Setting up DM::OJ:"
wget https://raw.githubusercontent.com/DMOJ/docs/master/sample_files/local_settings.py -O dmoj/local_settings.py

#TODO: read key from settings.py -> replace $ with \$ and & with \&
sed -i "s|'This key is not very secure and you should change it.'|'5*9f5q57mqmlz2#f\$x1h76\\&jxy#yortjl1v+l*6hd18\$d*yx#0'|g" dmoj/local_settings.py
sed -i "s|'<mariadb user password>'|'dmoj'|g" dmoj/local_settings.py


./make_style.sh
python3 manage.py collectstatic
python3 manage.py compilemessages
python3 manage.py compilejsi18n
python3 manage.py migrate
python3 manage.py loaddata navbar
python3 manage.py loaddata language_small
python3 manage.py loaddata demo

#https://stackoverflow.com/questions/6244382/how-to-automate-createsuperuser-on-django
DJANGO_SUPERUSER_PASSWORD="root"
DJANGO_SUPERUSER_USERNAME="root"
DJANGO_SUPERUSER_EMAIL="root@root.com"
python3 manage.py createsuperuser --noinput

service redis-server start
sed -i "s|#CELERY_BROKER_URL|CELERY_BROKER_URL|g" dmoj/local_settings.py
sed -i "s|#CELERY_RESULT_BACKEND|CELERY_RESULT_BACKEND|g" dmoj/local_settings.py
sed -i "s|#ALLOWED_HOSTS = \['dmoj.ca'\]|ALLOWED_HOSTS = \['\*'\]|g" dmoj/local_settings.py

apt-install "supervisor"

echo ""
title "Setting up web service:"
uwsgi --ini uwsgi.ini


#TODO: judge using https://docs.dmoj.ca/#/judge/setting_up_a_judge?id=through-pypi
#dmoj "localhost" "judge" "shmvr7PNyUMy948fYHCbxmWlkaC5UErKiMWyjofkDp6yHSmPQbhDIV/YX/eDSRb+NpeXvRTeZ/5ZcGQLIEqIpuaEl53JSkNqOMMa" 


# passwords-add "DOMjudge (http://<ip>/domjudge)" "admin" $(cat /etc/domjudge/initial_admin_password.secret)
done-and-reboot