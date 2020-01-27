#!/bin/sh
# upgrade our system followed by update
apt-get update && apt-get -y upgrade
# install required packages for LAMP and supporting packages
apt-get install -y software-properties-common dirmngr vim net-tools sudo wget curl apt-utils
apt-get install -y apache2 mariadb-server
apt-get install -y php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip libapache2-mod-php
# start mysql and sleep for a while, so database can be created
service mysql start &
sleep 5
# creating database for wordpress
echo "UPDATE mysql.user SET password=PASSWORD('MyPassword') WHERE user='root'" | mysql
echo "CREATE DATABASE wordpress_db" | mysql
echo "GRANT ALL ON wordpress_db.* TO wordpress_user @'%' IDENTIFIED BY 'MyPassword'" | mysql
# creating apache v-host for wordpress
touch  /etc/apache2/sites-available/wordpress.conf
cat  <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
ServerAdmin webmaster@localhost
DocumentRoot /var/www/html/wordpress
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF