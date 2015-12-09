#!/usr/bin/env bash
# $1 sys_password
# $2 public ip

source /vagrant/provisioning/ini-config

echo "manual" > /etc/init/keystone.override

apt-get install -qqy keystone apache2 libapache2-mod-wsgi memcached python-memcache

echo "Keyston packages are installed!"

iniset /etc/keystone/keystone.conf DEFAULT admin_token $1
iniset /etc/keystone/keystone.conf DEFAULT rpc_backend rabbit
iniset /etc/keystone/keystone.conf DEFAULT verbose "True"

iniset /etc/keystone/keystone.conf database connection "mysql+pymysql://keystone:$1@mysqldb/keystone"
iniset /etc/keystone/keystone.conf memcache servers localhost:11211
iniset /etc/keystone/keystone.conf token provider uuid
iniset /etc/keystone/keystone.conf token driver memcache
iniset /etc/keystone/keystone.conf revoke driver sql

iniset /etc/keystone/keystone.conf oslo_messaging_rabbit rabbit_host rabbitmq
iniset /etc/keystone/keystone.conf oslo_messaging_rabbit rabbit_userid openstack
iniset /etc/keystone/keystone.conf oslo_messaging_rabbit rabbit_password $1

echo "ServerName keystone" >> /etc/apache2/apache2.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone

echo "Keystone configuration is done!"

cp /vagrant/provisioning/wsgi-keystone.conf /etc/apache2/sites-available/
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

service apache2 restart

rm -f /var/lib/keystone/keystone.db

wait
echo "Ready to create endpoints"

export OS_TOKEN=$1
export OS_URL=http://keystone:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://keystone:5000/v2.0
openstack endpoint create --region RegionOne identity internal http://keystone:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://keystone:35357/v2.0

openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password $1 admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default --description "Service Project" service

openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password $1 demo

openstack role create user
openstack role add --project demo --user demo user


# Now setup two files for testing
echo "export OS_PROJECT_DOMAIN_ID=default" > ~/admin-openrc.sh
echo "export OS_USER_DOMAIN_ID=default" >> ~/admin-openrc.sh
echo "export OS_PROJECT_NAME=admin" >> ~/admin-openrc.sh
echo "export OS_TENANT_NAME=admin" >> ~/admin-openrc.sh
echo "export OS_USERNAME=admin" >> ~/admin-openrc.sh
echo "export OS_PASSWORD=$1" >> ~/admin-openrc.sh
echo "export OS_AUTH_URL=http://keystone:35357/v3" >> ~/admin-openrc.sh
echo "export OS_IDENTITY_API_VERSION=3" >> ~/admin-openrc.sh

echo "export OS_PROJECT_DOMAIN_ID=default" > ~/demo-openrc.sh
echo "export OS_USER_DOMAIN_ID=default" >> ~/demo-openrc.sh
echo "export OS_PROJECT_NAME=demo" >> ~/demo-openrc.sh
echo "export OS_TENANT_NAME=demo" >> ~/demo-openrc.sh
echo "export OS_USERNAME=demo" >> ~/demo-openrc.sh
echo "export OS_PASSWORD=$1" >> ~/demo-openrc.sh
echo "export OS_AUTH_URL=http://keystone:35357/v3" >> ~/demo-openrc.sh
echo "export OS_IDENTITY_API_VERSION=3" >> ~/demo-openrc.sh

for key in 'pipeline:public_api' 'pipeline:admin_api' 'pipeline:api_v3'; do
  val1=$(iniget /etc/keystone/keystone-paste.ini $key pipeline)
  val1=${val1/admin_token_auth/}
  iniset /etc/keystone/keystone-paste.ini $key pipeline "$val1"
done

echo "Keystone setup is now complete!"
