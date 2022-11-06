#!/bin/bash
cd /home/<user>
. dmojsite/bin/activate

cd site
python3 manage.py collectstatic --noinput
python3 manage.py compilemessages
python3 manage.py compilejsi18n
dmoj -c /home/<user>/problems/judge.yml localhost