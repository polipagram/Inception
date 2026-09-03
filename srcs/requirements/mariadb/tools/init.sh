#!/bin/bash

set -e

: "${MYSQL_DATABASE:?Missing database}"
: "${MYSQL_USER:?Missing user}"

if [ ! -f "/run/secrets/root_passwd" ]; then
    exit 1
fi

if [ ! -f "/run/secrets/user_passwd" ]; then
    exit 1
fi

MYSQL_ROOT_PASSWD=$(cat /run/secrets/root_passwd | tr -d '\r\n')
MYSQL_PASSWD=$(cat /run/secrets/user_passwd | tr -d '\r\n')

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

exec "$@"