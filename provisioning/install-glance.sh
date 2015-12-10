#!/usr/bin/env bash
# $1 sys_password
# $2 public ip

source /vagrant/provisioning/ini-config

apt-get install -qqy glance python-glanceclient

echo "Glance packages are installed!"

iniset /etc/glance/glance-api.conf database connection "mysql+pymysql://glance:$1@mysqldb/glance"
iniset /etc/glance/glance-api.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/glance/glance-api.conf DEFAULT verbose 'True'
iniset /etc/glance/glance-api.conf DEFAULT notification_driver 'noop'

iniset /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_host rabbitmq
iniset /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_userid openstack
iniset /etc/glance/glance-api.conf oslo_messaging_rabbit rabbit_password $1


iniset /etc/glance/glance-api.conf keystone_authtoken auth_uri 'http://keystone:5000'
iniset /etc/glance/glance-api.conf keystone_authtoken auth_url 'http://keystone:35357'
iniset /etc/glance/glance-api.conf keystone_authtoken auth_plugin 'password'
iniset /etc/glance/glance-api.conf keystone_authtoken project_domain_id 'default'
iniset /etc/glance/glance-api.conf keystone_authtoken user_domain_id 'default'
iniset /etc/glance/glance-api.conf keystone_authtoken project_name 'service'
iniset /etc/glance/glance-api.conf keystone_authtoken username 'glance'
iniset /etc/glance/glance-api.conf keystone_authtoken password $1

iniset /etc/glance/glance-api.conf 'paste_deploy' 'flavor' 'keystone'

mkdir -p /space/images
chown glance:glance /space/images
iniset /etc/glance/glance-api.conf 'glance_store' 'default_store' 'file'
iniset /etc/glance/glance-api.conf 'glance_store' 'filesystem_store_datadir' '/space/images/'


iniset /etc/glance/glance-registry.conf database connection "mysql+pymysql://glance:$1@mysqldb/glance"
iniset /etc/glance/glance-registry.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/glance/glance-registry.conf DEFAULT verbose 'True'
iniset /etc/glance/glance-registry.conf DEFAULT notification_driver 'noop'

iniset /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_host 'rabbitmq'
iniset /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_userid 'openstack'
iniset /etc/glance/glance-registry.conf oslo_messaging_rabbit rabbit_password $1

iniset /etc/glance/glance-registry.conf keystone_authtoken auth_uri 'http://keystone:5000'
iniset /etc/glance/glance-registry.conf keystone_authtoken auth_url 'http://keystone:35357'
iniset /etc/glance/glance-registry.conf keystone_authtoken auth_plugin 'password'
iniset /etc/glance/glance-registry.conf keystone_authtoken project_domain_id 'default'
iniset /etc/glance/glance-registry.conf keystone_authtoken user_domain_id 'default'
iniset /etc/glance/glance-registry.conf keystone_authtoken project_name 'service'
iniset /etc/glance/glance-registry.conf keystone_authtoken username 'glance'
iniset /etc/glance/glance-registry.conf keystone_authtoken password $1

iniset /etc/glance/glance-registry.conf 'paste_deploy' 'flavor' 'keystone'

su -s /bin/sh -c "glance-manage db_sync" glance

service glance-registry restart
service glance-api restart

rm -f /var/lib/glance/glance.sqlite

echo "Glance setup is now complete!"

