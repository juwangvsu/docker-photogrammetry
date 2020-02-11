FROM phusion/baseimage:0.10.2
MAINTAINER Matthew Rayner <hello@rayner.io>
ENV REFRESHED_AT 2019-06-11

# based on dgraziotin/lamp
# MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

ENV PHPMYADMIN_VERSION=4.9.0.1

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
  apt-get update && \
  apt-get -y --assume-yes --verbose-versions --allow-change-held-packages -o Dpkg::Options::="--force-confdef" upgrade && \
  apt-get -y install imagemagick perlmagick python-yaml python-pip libcgi-application-perl libcgi-application-plugin-dbh-perl libcgi-application-plugin-autorunmode-perl libcgi-application-plugin* libdbd-mysql-perl bash-completion net-tools iputils-ping sudo supervisor wget git apache2 php-xdebug libapache2-mod-php mysql-server php-mysql pwgen php-apcu php7.1-mcrypt php-gd php-xml php-mbstring php-gettext zip unzip php-zip curl php-curl && \
  apt-get -y autoremove && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN python -m pip install appsettings
RUN perl -MCPAN -e 'install IO::String'
RUN perl -MCPAN -e 'install Image::Info'

ARG USER=student
ARG USER2=cc
ARG GROUP=student
RUN addgroup --gid 1000 $GROUP && \
    adduser --uid 1001 --ingroup $USER --home /home/$USER --shell /bin/bash --disabled-password --gecos "" $USER
RUN adduser --uid 1002 --ingroup $GROUP --home /home/$USER2 --shell /bin/bash --disabled-password --gecos "" $USER2

RUN adduser $USER sudo \
 && echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/$USER
RUN adduser $USER2 sudo \
 && echo "$USER2 ALL=NOPASSWD: ALL" >> /etc/sudoers.d/$USER2

RUN echo 'student:student' | chpasswd

# needed for phpMyAdmin
RUN ln -s /etc/php/7.1/mods-available/mcrypt.ini /etc/php/7.3/mods-available/ && \
  phpenmod mcrypt

# Add image configuration and scripts
ADD supporting_files/start-apache2.sh /start-apache2.sh
ADD supporting_files/start-mysqld.sh /start-mysqld.sh
ADD supporting_files/run.sh /run.sh
RUN chmod 755 /*.sh
ADD supporting_files/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supporting_files/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supporting_files/mysqld_innodb.cnf /etc/mysql/conf.d/mysqld_innodb.cnf

# Allow mysql to bind on 0.0.0.0
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
  sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Set PHP timezones to Europe/London
RUN sed -i "s/;date.timezone =/date.timezone = Europe\/London/g" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/;date.timezone =/date.timezone = Europe\/London/g" /etc/php/7.4/cli/php.ini

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD supporting_files/create_mysql_users.sh /create_mysql_users.sh
RUN chmod 755 /*.sh

# Add phpmyadmin
#RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
COPY supporting_files/phpmyadmin.tar.gz /phpmyadmin.tar.gz
RUN tar xfvz /phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

ENV MYSQL_PASS:-$(pwgen -s 12 1)
# config to enable .htaccess
ADD supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN a2enmod cgi.load
RUN a2enmod cgid.load


COPY supporting_files/apache2.conf /etc/apache2/apache2.conf
COPY supporting_files/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY supporting_files/cgi-bin.tar /usr/lib/cgi-bin/cgi-bin.tar
RUN tar xfv /usr/lib/cgi-bin/cgi-bin.tar -C /usr/lib/cgi-bin
COPY supporting_files/htmlfiles.tar /var/www/htmlfiles.tar
RUN tar xfv /var/www/htmlfiles.tar -C /var/www
COPY supporting_files/public_html.tar /home/cc/public_html/public_html.tar
#RUN mkdir /home/cc/public_html
RUN tar xfv /home/cc/public_html/public_html.tar -C /home/cc/public_html
RUN mkdir /home/cc/photogrammetry
RUN mkdir /home/cc/photo
COPY supporting_files/bin.tar /home/cc/bin.tar
RUN tar xfv /home/cc/bin.tar -C /home/cc

RUN chown -R cc /home/cc/photo
RUN chown -R cc /home/cc/photogrammetry
RUN chown -R cc /home/cc/public_html

RUN chmod -R 777 /home/cc/photo
RUN chmod -R 777 /home/cc/photogrammetry
RUN chmod -R 777 /home/cc/public_html
RUN ln -s /home/cc/public_html/photodata /var/www/html/photodata
#RUN ln -s /home/cc/photogrammetry /var/www/html/photogrammetry

COPY supporting_files/sitevariables.pl /usr/lib/cgi-bin/cgi-user1-photo/sitevariables.pl

#COPY supporting_files/opendronemap.tar /home/cc/opendronemap.tar
#RUN tar xfv /home/cc/opendronemap.tar -C /home/cc
#COPY supporting_files/clover-hill-complex-small.tar /home/cc/photogrammetry/clover-hill-complex-small.tar 
#RUN tar xfv /home/cc/photogrammetry/clover-hill-complex-small.tar -C /home/cc/photogrammetry

#RUN bash configure.sh reinstall 1



COPY supporting_files/docker-clean /etc/apt/apt.conf.d/docker-clean
RUN apt-get -y install libjpeg-progs
# Configure /app folder with sample app
RUN mkdir -p /app /app2 
#&& rm -fr /var/www/html && ln -s /app /var/www/html
#ADD app/ /app
#ADD app2 /app2
RUN ln -s /app2/aukerman /home/cc/photogrammetry/aukerman
RUN ln -s /app2/clover-hill-complex /home/cc/photogrammetry/clover-hill-complex

RUN apt-get install -y -qq build-essential \
                         git \
                         cmake \
                         python-pip \
                         libgdal-dev \
                         gdal-bin \
                         libgeotiff-dev \
                         pkg-config
RUN apt-get install -y -qq libgtk2.0-dev \
                         libavcodec-dev \
                         libavformat-dev \
                         libswscale-dev \
                         python-dev \
                         python-numpy \
                         libtbb2 \
                         libtbb-dev \
                         libjpeg-dev \
                         libpng-dev \
                         libtiff-dev \
                         libjasper-dev \
                         libflann-dev \
                         libproj-dev \
                         libxext-dev \
                         liblapack-dev \
                         libeigen3-dev \
                         libvtk5-dev
RUN apt-get install -y -qq python-networkx \
                         libgoogle-glog-dev \
                         libsuitesparse-dev \
                         libboost-filesystem-dev \
                         libboost-iostreams-dev \
                         libboost-regex-dev \
                         libboost-python-dev \
                         libboost-date-time-dev \
                         libboost-thread-dev \
                         python-pyproj
RUN pip install -U PyYAML \
                        exifread \
                        gpxpy==1.1.2 \
                        xmltodict \
                        appsettings

#RUN apt-get install -y  python-empy \
 #                        python-nose \
  #                       python-pyside

RUN apt-get install -y  python-pyexiv2 \
                         python-scipy \
                         jhead \
                         liblas-bin

RUN apt-get install -y  python-empy \
                         python-nose \
                         python-pyside

RUN apt-get install -y  libqhull7
 
#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
#VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 80 3306
CMD ["/run.sh"]
