#!/usr/bin/env bash

if [ ! -f  /var/log/os_setup ]; then
	echo "<<< Vagrant OS setup started..."

	export DEBIAN_FRONTEND=noninteractive

	# Configurable settings
	MYSQL_ROOT_PASS="vagrant"
	PHPMYADMIN_PASS="vagrant"
	PROVISION_DIR="/vagrant/provision"

	apt-get update
	apt-get upgrade -y

	# Pre-configure mysql
	echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS" | debconf-set-selections
	echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS" |debconf-set-selections

	# Pre-configure phpmyadmin
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASS" |debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_PASS" | debconf-set-selections

	# Install required packages
	apt-get install -y \
		wget curl bash-completion tofrodos vim mc \
	 	apache2 mysql-server mysql-client mplayer \
	 	php5 php5-mysql phpmyadmin libapache2-mod-php5 php-pear php5-cgi php5-xcache php5-curl

	echo "silent" > /home/vagrant/.curlrc
	chown vagrant:vagrant /home/vagrant/.curlrc

    # Configure fake sendmail to save sent mails into /vagrant/mail-log.html
    cp ${PROVISION_DIR}/phpsendmail /usr/local/bin/phpsendmail
    # Make sure that line endings are OK in this file on Windows
    fromdos /usr/local/bin/phpsendmail
    chmod +x /usr/local/bin/phpsendmail
    # Tweak PHP settings
    sed -i 's/;sendmail_path =/sendmail_path = \/usr\/local\/bin\/phpsendmail/g' /etc/php5/apache2/php.ini

    # Configure Apache
    mv /var/www/html /var/www/html.bak
    ln -fs /vagrant/majordomo /var/www/html
	# Set AllowOverride to All
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
	a2enmod rewrite
	service apache2 restart

	# Sound settings
	usermod -a -G audio vagrant
	usermod -a -G audio www-data

	# Avoid strange vagrant+virtualbox caching issue:
	# http://stackoverflow.com/questions/9479117/vagrant-virtualbox-apache2-strange-cache-behaviour
	echo "EnableSendfile off" > /etc/apache2/conf-available/disable-sendfile

	echo ">>> Vagrant OS setup complete."

	touch /var/log/os_setup
fi
