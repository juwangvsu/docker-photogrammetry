FROM jwang3vsu/lamp:latest-1604
#ADD supporting_files/run2.sh /run2.sh
ADD supporting_files/run3.sh /run3.sh
ADD supporting_files/init_db.sh /init_db.sh
COPY supporting_files/php.ini /etc/php/7.4/apache2/php.ini
RUN sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=staff/" /etc/apache2/envvars
RUN mkdir -p /var/run/mysqld
RUN mkdir -p /var/lib/mysql
RUN chown -R www-data:staff /app
RUN chown -R www-data:staff /var/lib/mysql
RUN chown -R www-data:staff /var/run/mysqld
RUN chmod -R 770 /var/lib/mysql
RUN chmod -R 770 /var/run/mysqld
RUN sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i "s/user.*/user = www-data/" /etc/mysql/my.cnf
RUN mkdir /mysql
#RUN mysqld --initialize
RUN /init_db.sh
RUN echo 'checking /mysql'
RUN ls /mysql 
#COPY supporting_files/mysql.tar /mysql.tar
#RUN tar xfv /mysql.tar -C /var/lib/mysql
RUN echo 'checking /var/lib/mysql'
RUN ls /var/lib/mysql 
RUN echo 'checking /var'
RUN ls /var 
VOLUME  ["/etc/mysql", "/app" ]
CMD ["/run3.sh"]
