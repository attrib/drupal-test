#!/usr/bin/env bash

PATH=$PATH:/var/www/html/vendor/bin/

if [ ! -z "$1" ]; then
    # a cmd is given so run (e.g. composer/drush)
    CMD=$1
    shift
    echo "Running $CMD $@"
    if [[ "$CMD" == *"phpunit" ]]; then
        /etc/init.d/apache2 start
        mkdir /var/www/html/web/sites/simpletest
        chown www-data:wwwadmin /var/www/html/web/sites/default/files
        chown www-data:wwwadmin /var/www/html/web/sites/simpletest
        chown www-data:wwwadmin /tmp/tests
        sudo -Eu www-data $CMD $@
    else
        $CMD $@
    fi
else
    # make files accessible for www-data
    chown www-data:wwwadmin /var/www/html/web/sites/default/files

    # wait till db is up
    while ! mysql -hdb -udocker -pdocker  -e ";" ; do
        echo "Waiting DB container db not up yet"
        sleep 5
    done

    # start apache
    apache2-foreground
fi
