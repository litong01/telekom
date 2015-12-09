#!/usr/bin/env bash
# $1 sys_password

source /vagrant/provisioning/ini-config

echo "manual" > /etc/init/keystone.override

apt-get install -qqy keystone apache2 libapache2-mod-wsgi memcached python-memcache

echo "Keyston packages are installed!"

iniset /etc/keystone/keystone.conf DEFAULT admin_token $1
iniset /etc/keystone/keystone.conf database connection "mysql+pymysql://keystone:$1@mysqldb/keystone"
iniset /etc/keystone/keystone.conf memcache servers localhost:11211
iniset /etc/keystone/keystone.conf token provider uuid
iniset /etc/keystone/keystone.conf token driver memcache
iniset /etc/keystone/keystone.conf revoke driver sql
iniset /etc/keystone/keystone.conf DEFAULT verbose "True"

echo "ServerName keystone" >> /etc/apache2/apache2.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone

echo "Keystone configuration is done!"

cp /vagrant/provisioning/wsgi-keystone.conf /etc/apache2/sites-available/
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

service apache2 restart

rm -f /var/lib/keystone/keystone.db

