#!/bin/bash
cd <dmoj-root-path>
. dmojsite/bin/activate

cd site
python3 manage.py collectstatic --noinput
python3 manage.py compilemessages
python3 manage.py compilejsi18n
dmoj -c <dmoj-root-path>/problems/judge.yml localhost