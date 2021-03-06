#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1

source /onvm/scripts/ini-config
eval $(parse_yaml '/onvm/conf/nodes.conf.yml' 'leap_')

apt-get install -qqy "$leap_aptopt" cinder-api cinder-scheduler python-cinderclient

echo "Cinder packages are installed!"

iniset /etc/cinder/cinder.conf database connection "mysql+pymysql://cinder:$1@${leap_logical2physical_mysqldb}/cinder"
iniset /etc/cinder/cinder.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/cinder/cinder.conf DEFAULT debug 'True'
iniset /etc/cinder/cinder.conf DEFAULT auth_strategy 'keystone'
iniset /etc/cinder/cinder.conf DEFAULT my_ip $3

iniset /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host $leap_logical2physical_rabbitmq
iniset /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
iniset /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $1

iniset /etc/cinder/cinder.conf keystone_authtoken auth_uri "http://${leap_logical2physical_keystone}:5000"
iniset /etc/cinder/cinder.conf keystone_authtoken auth_url "http://${leap_logical2physical_keystone}:35357"
iniset /etc/cinder/cinder.conf keystone_authtoken auth_plugin 'password'
iniset /etc/cinder/cinder.conf keystone_authtoken project_domain_id 'default'
iniset /etc/cinder/cinder.conf keystone_authtoken user_domain_id 'default'
iniset /etc/cinder/cinder.conf keystone_authtoken project_name 'service'
iniset /etc/cinder/cinder.conf keystone_authtoken username 'cinder'
iniset /etc/cinder/cinder.conf keystone_authtoken password $1

iniset /etc/cinder/cinder.conf keymgr encryption_auth_url http://$leap_logical2physical_keystone:5000/v3

iniset /etc/cinder/cinder.conf 'oslo_concurrency' 'lock_path' '/var/lib/cinder/tmp'

iniremcomment /etc/cinder/cinder.conf

su -s /bin/sh -c "cinder-manage db sync" cinder


service cinder-scheduler restart
service cinder-api restart

rm -f /var/lib/cinder/cinder.sqlite

echo 'Cinder configuration is now complete!'

