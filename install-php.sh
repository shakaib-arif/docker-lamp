#! /bin/bash

# PHP 7 Initial Compile #
# Author: Maulik Mistry
# Date: Aug 04, 2017
# References:
#   http://www.zimuel.it/install-php-7/
#   http://www.hashbangcode.com/blog/compiling-and-installing-php7-ubuntu
#
# License: BSD License 2.0
# Copyright (c) 2015-2017, Maulik Mistry
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
sudo apt-get install -y git libssl-dev autoconf libicu-dev

#
# Build configuration
#


# PHP version to be cloned
PHP_VERSION="7.1.8"

# Cirectory to store config files
CONFIG_DIR="/etc/php/php7-custom"

# Binaries directory name
BINARY_DIR="/usr/local/php7-custom"

# Alternative symlink path
ALTERNATIVE_PATH="/usr/bin/php"

# OpenSSL lib dev package name 
#PACKAGE_LIBSSL_DEV="libssl-dev"
PACKAGE_LIBSSL_DEV="libssl-dev=1.0.1f-1ubuntu2.27"

#
# Build script
#


# PHP 7 does not recognize these without additional parameters or symlinks for
# Ldap.
sudo ln -sf /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so
sudo ln -sf /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so
sudo ln -sf /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

if [ -d ./php-src ]; then
    cd php-src
    git reset --hard HEAD
    git clean -fd
    git pull origin "php-$PHP_VERSION"

    if [ $? -ne 0 ]; then
       cd ..
       sudo rm -rf php-src
       git clone https://github.com/php/php-src
       cd php-src
    fi
else
    # Obtain latest source
    git clone https://github.com/php/php-src
    cd php-src
fi

# Stop execution if things fail to move forward.
set -e

# Checkout latest release
git checkout "php-$PHP_VERSION"

# Setup Kubuntu with other dependencies for PHP 7. Add any missing ones from
# the configure script.
sudo apt-get update
sudo apt-get install libldap2-dev \
  libldap-2.4-2 \
  libtool libtool-doc \
  libzip-dev \
  lbzip2 \
  libxml2-dev \
  bzip2 \
  re2c \
  libbz2-dev \
  apache2-dev \
  libjpeg-dev \
  libxpm-dev \
  libxpm-dev \
  libgmp-dev \
  libgmp3-dev \
  libmcrypt-dev \
  libmysqlclient-dev \
  libpspell-dev \
  librecode-dev \
  libcurl4-openssl-dev \
  libxft-dev \
  "$PACKAGE_LIBSSL_DEV" \
  pkg-config \
  libbison-dev


# Helped fix configure issues and ignored files needing an update.
./buildconf --force
# Setup compile options for Kubuntu.  If failures occur, check dependencies
# and symlink needs above.
./configure "--prefix=$BINARY_DIR" \
    "--with-config-file-path=$CONFIG_DIR/apache2" \
    "--with-config-file-scan=$CONFIG_DIR/apache2/conf.d" \
    --enable-mbstring \
    --enable-zip \
    --enable-bcmath \
    --enable-pcntl \
    --enable-ftp \
    --enable-fpm \
    --enable-exif \
    --enable-calendar \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-wddx \
    --enable-intl \
    --enable-so \
    --with-curl \
    --with-mcrypt \
    --with-iconv \
    --with-gmp \
    --with-pspell \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib-dir=/usr \
    --with-xpm-dir=/usr \
    --with-freetype-dir=/usr \
    --with-t1lib=/usr \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --with-openssl \
    --with-pdo-mysql=/usr \
    --with-gettext=/usr \
    --with-zlib=/usr \
    --with-bz2 \
    --with-recode=/usr \
    --with-apxs2=/usr/bin/apxs \
    --with-mysqli=/usr/bin/mysql_config \
    --with-ldap \
    --with-xdebug

# Cleanup for previous failures.
sudo make clean

# Using as many threads as possible.
cpunum=$((`cat /proc/cpuinfo | grep processor | wc -l` + 1))
sudo make -j ${cpunum}

# Install it accoridng to the configured path.
sudo make install

# It's own make script said to do this, but it didn't do much on my system.
libtool --finish ./libs

# Work on non-threaded version as compiled for now.
sudo a2dismod mpm_worker
sudo a2dismod mpm_event
sudo a2enmod mpm_prefork
# Since it is built with axps2, it sets things up correctly.
sudo a2enmod php7

# Restart Apache if all went well.
sudo service apache2 restart
# View any errors for Apache startup.
printf "Any errors starting Apache2 with PHP7 can be seen with 'sudo journalctl -xe' .\n"

# Update the paths on th system according to Ubuntu.  Can be later removed and
# switched back.
sudo update-alternatives --install "$ALTERNATIVE_PATH" php "$BINARY_DIR/bin/php" 50 \
  --slave /usr/share/man/man1/php.1.gz php.1.gz \
  "$BINARY_DIR/php/man/man1/php.1"

# Choose your PHP version.
printf "Select the version of PHP you want active in subsequent shells and the \
  system:\n"
sudo update-alternatives --config php

## To help enable Apache 2.4 use of PHP 7. Enable this after writing the file.
## /etc/apache2/mods-available/php7.conf
#<FilesMatch ".+\.ph(p[3457]?|t|tml)$">
#    SetHandler application/x-httpd-php
#</FilesMatch>
#<FilesMatch ".+\.phps$">
#    SetHandler application/x-httpd-php-source
#    # Deny access to raw php sources by default
#    # To re-enable it's recommended to enable access to the files
#    # only in specific virtual host or directory
#    Require all denied
#</FilesMatch>
# Deny access to files without filename (e.g. '.php')
#<FilesMatch "^\.ph(p[345]?|t|tml|ps)$">
#    Require all denied
#</FilesMatch>
#
# Running PHP scripts in user directories is disabled by default
#
# To re-enable PHP in user directories comment the following lines
# (from <IfModule ...> to </IfModule>.) Do NOT set it to On as it
# prevents .htaccess files from disabling it.
#<IfModule mod_userdir.c>
#    <Directory /home/*/public_html>
#        php_admin_flag engine Off
#    </Directory>
#</IfModule>"