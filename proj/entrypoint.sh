#!/bin/bash
set -x
set -e

# Define help message
show_help() {
    echo """
    Commands
    manage        : Invoke django manage.py commands
    setupdb       : Set initial db user and tables
    test_coverage : runs tests with coverage output
    start         : start webserver behind nginx (prod for serving static files)
    pip_freeze    : freeze pip dependencies and write to requirements.txt
    """
}

setup_db() {
    cd /code/
    /var/env/bin/python manage.py sqlcreate | psql -U $DATABASE_USERNAME -h $DATABASE_HOSTNAME -p $DATABASE_PORT
    /var/env/bin/python manage.py createcachetable
    /var/env/bin/python manage.py migrate
}


pip_freeze() {
    rm -rf /tmp/env
    mkdir -p /root/.cache/pip/
    sudo chown root:root -R /root/.cache/pip/
    virtualenv -p python3 /tmp/env/
    /tmp/env/bin/pip install -f /code/dependencies -r ./primary-requirements.txt --upgrade
    set +x
    echo -e "###\n# frozen requirements DO NOT CHANGE\n# To update this update 'primary-requirements.txt' then run ./entrypoint.sh pip_freeze\n###" | tee requirements.txt
    /tmp/env/bin/pip freeze --local | grep -v appdir | tee -a requirements.txt
}

case "$1" in
    manage )
        cd /code/
        /var/env/bin/python manage.py "${@:2}"
    ;;
    setupdb )
        setup_db
    ;;
    test_coverage)
        source /var/env/bin/activate
        flake8
        coverage run --rcfile="/code/.coveragerc" /code/manage.py test  "${@:2}"
        coverage annotate --rcfile="/code/.coveragerc"
        coverage report --rcfile="/code/.coveragerc"
        cat << "EOF"
  ____                 _     _       _     _
 / ___| ___   ___   __| |   (_) ___ | |__ | |
| |  _ / _ \ / _ \ / _` |   | |/ _ \| '_ \| |
| |_| | (_) | (_) | (_| |   | | (_) | |_) |_|
 \____|\___/ \___/ \__,_|  _/ |\___/|_.__/(_)
                          |__/

EOF
    ;;
    start_server )
        cd /code/
        setup_db
        /var/env/bin/python manage.py collectstatic --noinput
        /var/env/bin/uwsgi --ini /code/uwsgi.ini
    ;;
    start_worker )
        cd /code/
        setup_db
	C_FORCE_ROOT=1 /var/env/bin/celery -A project worker -l info
    ;;
    pip_freeze )
        pip_freeze
    ;;
    bash )
        exec bash "${@:2}"
    ;;
    help)
        show_help
    ;;
    *)
        show_help
    ;;
esac
