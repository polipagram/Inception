#!/bin/bash

set -e

echo "Waiting for MariaDB..."
until mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$(cat /run/secrets/user_passwd)" "$MYSQL_DATABASE" -e "SELECT 1;" > /dev/null 2>&1
do
    sleep 2
done
echo "MariaDB is ready!"

cd /var/www/html

if [ ! -f wp-config.php ]; then

    wp core config \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$(cat /run/secrets/user_passwd)" \
        --dbhost="$MYSQL_HOST" \
        --allow-root
fi