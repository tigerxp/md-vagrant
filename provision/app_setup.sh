#!/usr/bin/env bash

echo "<<< Vagrant App setup started..."

# Set up database
DATA_PATH='/vagrant/majordomo'
SQL_FILE='db_terminal.sql'
MYSQL_USER='dev'
MYSQL_PASS='dev'
MYSQL_HOST='localhost'
MYSQL_DB='majordomo'
DB_PREFIX=''

mysql -u root -p"vagrant" -e "DROP DATABASE IF EXISTS $MYSQL_DB;"
mysql -u root -p"vagrant" -e "CREATE DATABASE $MYSQL_DB DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"vagrant" -e "GRANT ALL ON $MYSQL_DB.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASS';GRANT ALL ON $MYSQL_DB.* TO '$MYSQL_USER'@'10.0.%' IDENTIFIED BY '$MYSQL_PASS';"
mysql -u root -p"vagrant" -e "GRANT ALL ON $MYSQL_DB.* TO 'dev'@'%' IDENTIFIED BY 'dev'"

if [ -f "$DATA_PATH/$SQL_FILE" ]; then
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" ${MYSQL_DB} < "$DATA_PATH/$SQL_FILE"
fi

# Set up application
cp /vagrant/majordomo/config.php.sample /vagrant/majordomo/config.php
sed -i "s/'DB_NAME', 'db_terminal'/'DB_NAME', '$MYSQL_DB'/g" /vagrant/majordomo/config.php
sed -i "s/'DB_USER', 'root'/'DB_USER', '$MYSQL_USER'/g" /vagrant/majordomo/config.php
sed -i "s/'DB_PASSWORD', ''/'DB_PASSWORD', '$MYSQL_PASS'/g" /vagrant/majordomo/config.php

cd /vagrant/majordomo

folders=( cached cms debmes modules templates objects rc saverestore)
for i in "${folders[@]}"
do
    mkdir -p ${i}
    find ${i}/ -type d -exec chmod 777 {} \;
    find ${i}/ -type f -exec chmod 666 {} \;
done

echo ">>> Vagrant App setup complete."
