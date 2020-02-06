FROM ubuntu:16.04
# disable package prompt interaction
ENV DEBIAN_FRONTEND noninteractive
# install required packages
ADD ./setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh
# install and configure wordpress
RUN wget https://wordpress.org/latest.tar.gz
RUN tar xzf latest.tar.gz
RUN mv wordpress /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress/
RUN chmod -R 755 /var/www/html/wordpress/
RUN mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
RUN sed -i -e 's/database_name_here/wordpress_db/g' /var/www/html/wordpress/wp-config.php
RUN sed -i -e 's/username_here/wordpress_user/g' /var/www/html/wordpress/wp-config.php
RUN sed -i -e 's/password_here/MyPassword/g' /var/www/html/wordpress/wp-config.php
# creating apache v-host for wordpress
ADD ./wordpress.conf /etc/apache2/sites-available/wordpress.conf
# update apache configuration
RUN a2enmod rewrite
RUN a2dissite 000-default.conf
RUN ln -s /etc/apache2/sites-available/wordpress.conf /etc/apache2/sites-enabled/wordpress.conf
# install runit (init scheme)
RUN apt-get update && apt-get install -y runit
RUN mkdir -p /etc/runit
ADD runit-1.sh /etc/runit/1
ADD runit-2.sh /etc/runit/2
ADD runit-3.sh /etc/runit/3
RUN chmod +x -R /etc/runit/*
# configure apache service by using runit directive
RUN mkdir -p /etc/service/my_apache/
RUN echo "#!/bin/bash\necho "start apache"\n/etc/init.d/apache2 start" > /etc/service/my_apache/run
RUN chmod +x /etc/service/my_apache/run
# configure mysql service by using runit directive
RUN mkdir -p /etc/service/my_sql/
RUN echo "#!/bin/sh\n/etc/init.d/mysql start" > /etc/service/my_sql/run
RUN chmod +x /etc/service/my_sql/run
# ports and entrypoint configuration
EXPOSE 3306 80
COPY boot /
RUN chmod +x /boot
CMD [ "/boot" ]