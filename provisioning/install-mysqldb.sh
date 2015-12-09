#!/usr/bin/env bash
# $1 db_password
# $2 management network ip

source /vagrant/provisioning/ini-config

debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password password $1"
debconf-set-selections <<< "mariadb-server-5.5 mysql-server/root_password_again password $1"

apt-get -qqy install python-pymysql
apt-get -qqy install mariadb-server

wait
echo "Installed MariaDB!"

iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld bind-address $2
iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld performance_schema off
iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld default-storage-engine innodb
iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld innodb_file_per_table on
iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld collation-server utf8_general_ci
iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld init-connect 'SET NAMES utf8'
iniset /etc/mysql/conf.d/mysqld_openstack.cnf mysqld character-set-server utf8

service mysql restart

# Create needed databases
for db in keystone neutron nova glance cinder; do
  mysql -uroot -p$1 -e "CREATE DATABASE $db;"
  mysql -uroot -p$1 -e "use $db; GRANT ALL ON $db TO '$db'@'192.168.1.%' IDENTIFIED BY '$1';"
done