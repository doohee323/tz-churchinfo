#!/usr/bin/env bash

set -x

export USER=vagrant  # for vagrant
export PROJ_NAME=churchinfo
export HOME_DIR=/home/$USER
export PROJ_DIR=/vagrant
export SRC_DIR=/vagrant/resources  # for vagrant

sudo sh -c "echo '' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export HOME_DIR='$HOME_DIR >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export SRC_DIR='$SRC_DIR >> $HOME_DIR/.bashrc"
source $HOME_DIR/.bashrc

sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/mysql-5.6 -y
sudo apt-get update

### [install mysql] ############################################################################################################
echo "mysql-server-5.6 mysql-server/root_password password passwd123" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password passwd123" | sudo debconf-set-selections
sudo apt-get install mysql-server-5.6 -y

if [ -f "/etc/mysql/my.cnf" ];then
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
    sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
fi

if [ -f "/etc/mysql/mysql.conf.d/mysqld.cnf" ];then
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
fi

sudo mysql -u root -ppasswd123 -e \
"use mysql; \
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"
sudo mysql -u root -ppasswd123 -e \
"CREATE DATABASE churchinfo; \
CREATE USER churchinfo@localhost; \
SET PASSWORD FOR churchinfo@localhost= PASSWORD('passwd123'); \
GRANT ALL PRIVILEGES ON churchinfo.* TO root@localhost IDENTIFIED BY 'passwd123'; \
GRANT ALL PRIVILEGES ON *.* TO 'churchinfo'@'%' IDENTIFIED BY 'passwd123'; \
GRANT ALL PRIVILEGES ON *.* TO churchinfo@localhost IDENTIFIED BY 'passwd123'; \
SET SQL_SAFE_UPDATES=0;
FLUSH PRIVILEGES; \
"

### [install php] ############################################################################################################
sudo apt-get install php5.6 libapache2-mod-php5.6 php5.6-common php5.6-mbstring php5.6-xmlrpc php5.6-soap php5.6-gd -y
sudo apt-get install php5.6-fpm php5.6-xml php5.6-intl php5.6-mysql php5.6-cli php5.6-mcrypt php5.6-zip php5.6-curl -y
sudo apt-get install libapache2-mod-php5.6 -y

sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/;error_log = php_errors.log/error_log = php_errors.log/g" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 200M/g" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 200M/g" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/max_execution_time = 30/max_execution_time = 360/g" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/max_input_time = 300/max_input_time = 24000/g" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/memory_limit = 128MB/memory_limit = 2048M/g" /etc/php/5.6/fpm/php.ini
sudo service php5.6-fpm stop 

### [install apache2] ############################################################################################################
apt-get install apache2 -y
sudo sh -c "echo '' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '<Directory /var/www/html/>' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '    AllowOverride All' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '</Directory>' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '' >> /etc/apache2/apache2.conf"

cat <<EOT > /etc/apache2/sites-available/churchinfo.conf

<VirtualHost *:80>
     ServerAdmin admin@local.com
     DocumentRoot /var/www/html/
     ServerName local.com
     ServerAlias vm.local.com

     <Directory /var/www/html/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

	<Directory /var/www/html/churchinfo/SQL>
	 Order deny,allow
	 Deny from all
	</Directory>

     ErrorLog /var/log/error.log
     CustomLog /var/log/access.log combined
</VirtualHost>

EOT

rm -Rf /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/churchinfo.conf /etc/apache2/sites-enabled/churchinfo.conf

rm -rf /var/www/html/index.html

sudo a2ensite churchinfo.conf
sudo a2enmod rewrite
sudo a2enmod php5.6

service apache2 restart

### [open firewalls] ############################################################################################################

### [install churchinfo] ############################################################################################################
su - $USER

sudo mkdir -p $PROJ_DIR
cd $PROJ_DIR

sudo cp $SRC_DIR/churchinfo-1.2.14.tar.gz $PROJ_DIR
tar xvfz churchinfo-1.2.14.tar.gz

echo sudo sed -i "s|\$sPASSWORD = 'churchinfo'|\$sPASSWORD = 'passwd123'|g" $PROJ_DIR/churchinfo/Include/Config.php
sudo sed -i "s|\$sPASSWORD = 'churchinfo'|\$sPASSWORD = 'passwd123'|g" $PROJ_DIR/churchinfo/Include/Config.php

echo mysql churchinfo --user=churchinfo --password=passwd123 < $PROJ_DIR/churchinfo/SQL/Install.sql
mysql churchinfo --user=churchinfo --password=passwd123 < $PROJ_DIR/churchinfo/SQL/Install.sql


cd $PROJ_DIR/churchinfo

#sudo rsync -avP /vagrant/churchinfo/ /var/www/html/churchinfo/
sudo rsync -avP $PROJ_DIR/churchinfo/ /var/www/html/churchinfo/
cat <(crontab -l) <(echo "* * * * * sudo rsync -avP $PROJ_DIR/churchinfo/ /var/www/html/churchinfo/ && sudo chown -Rf www-data:www-data /var/www/html") | crontab -

#sudo userdel www-data
#sudo useradd -c "www-data" -m -d $PROJ_DIR/churchinfo/ -s /bin/bash -G sudo www-data
sudo usermod -a -G www-data www-data
sudo usermod --home $PROJ_DIR/churchinfo/ www-data
echo -e "www-data\nwww-data" | sudo passwd www-data

sudo chown -R www-data:www-data /var/www/html/

### [start services] ############################################################################################################

sudo /etc/init.d/mysql restart  
#mysql -h localhost -P 3306 -u root -p

sudo service php5.6-fpm restart

#curl http://192.168.82.170

exit 0

/tz-churchinfo/churchinfo/Include/Config.php
//error_reporting(0);
error_reporting(-1);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log','/tmp/churchinfo.log');

/tz-churchinfo/churchinfo/Include/LoadConfigs.php
syslog(LOG_INFO, '1-----------------------sSERVERNAME'.$sSERVERNAME);


#vi /etc/php/5.6/fpm/php.ini
display_errors = On
display_startup_errors = On
log_errors = On
error_reporting = E_ALL
display_errors = On

sudo service php5.6-fpm restart
#tail -f /var/log/syslog
