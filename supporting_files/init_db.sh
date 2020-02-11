#!/bin/bash
VOLUME_HOME="/var/lib/mysql"
echo "init db"
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."

    # Try the 'preferred' solution
    mysqld --initialize-insecure > /dev/null 2>&1

    # IF that didn't work
    if [ $? -ne 0 ]; then
        # Fall back to the 'depreciated' solution
        mysql_install_db > /dev/null 2>&1
    fi
    ls /var/lib/mysql
#    cp -r /var/lib/mysql /mysql
    echo "=> Done!"
    #/create_mysql_users.sh
else
    echo "=> Using an existing volume of MySQL"
fi

