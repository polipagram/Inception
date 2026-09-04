#!/bin/bash

set -e

: "${MYSQL_DATABASE:?Missing database}"
: "${MYSQL_USER:?Missing user}"

if [ ! -f "/run/secrets/root_passwd" ]; then
    echo "Error: root_passwd secret missing" >&2
    exit 1
fi

if [ ! -f "/run/secrets/user_passwd" ]; then
    echo "Error: user_passwd secret missing" >&2
    exit 1
fi

MYSQL_ROOT_PASSWD=$(cat /run/secrets/root_passwd | tr -d '\r\n')
MYSQL_PASSWD=$(cat /run/secrets/user_passwd | tr -d '\r\n')

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    mariadbd --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWD}';
DELETE FROM mysql.global_priv WHERE User=''; 
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

exec "$@"