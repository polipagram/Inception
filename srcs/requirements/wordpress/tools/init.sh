#!/bin/bash

set -e

echo "Waiting for MariaDB..."

until mariadb -h"$MYSQL_HOST" \
    -u"$MYSQL_USER" \
    -p"$(cat /run/secrets/user_passwd)" \
    "$MYSQL_DATABASE" \
    -e "SELECT 1;" > /dev/null 2>&1
do
    sleep 2
done

echo "MariaDB is ready!"

cd /var/www/html

if [ ! -f wp-config.php ]; then

    echo "Creating WordPress configuration..."

    wp core config \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$(cat /run/secrets/user_passwd)" \
        --dbhost="$MYSQL_HOST" \
        --allow-root

fi

if ! wp core is-installed --allow-root; then

    echo "Installing WordPress..."

    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_passwd)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    echo "WordPress installation complete!"

else

    echo "WordPress is already installed."

fi

if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then

    echo "Creating WordPress user..."

    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$(cat /run/secrets/wp_user_passwd)" \
        --allow-root

else

    echo "WordPress user already exists."

fi

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F