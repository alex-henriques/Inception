#!/bin/sh
set -e

# Reading secrets
DB_PASS=$(cat /run/secrets/db_pass)
WP_ADMIN_PASS=$(cat /run/secrets/credentials)

# WP mustnt try to connect to MariaDB before it's ready to accept connections
echo "Waiting for MariaDB  "
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${DB_PASS}" --silent; do sleep 2
done
echo "MariaDB is ready"

# WP volume /var/www/html. 
if [ ! -f "/var/www/html/wp-includes/version.php" ]; then

    # download WP core into the volume directory
    wp  core download --path=/var/www/html --allow-root

    # wp-config.php: this file tells wp how to connect to the  database
    wp  config create --path=/var/www/html --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${DB_PASS}" --dbhost=mariadb --allow-root

    # wp installation
    wp  core install --path=/var/www/html --url="https://${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASS}" --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

    # 2nd WP user

    wp  user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${DB_PASS}" --path=/var/www/html --allow-root

    # fix file ownership so php-fpm can write to files
    chown   -R www-data:www-data /var/www/html

fi

# exec and PID-1; exec repalces the shell, making php-fpm PID 1
exec    php-fpm81 -F
