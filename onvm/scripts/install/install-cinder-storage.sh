#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1

source /onvm/scripts/ini-config

apt-get install -qqy cinder-volume python-mysqldb

echo "Compute packages are installed!"

vgname=$(vgdisplay | awk 'NR==2 { print $3 }')

iniset /etc/cinder/cinder.conf database connection "mysql+pymysql://cinder:$1@mysqldb/cinder"
iniset /etc/cinder/cinder.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/cinder/cinder.conf DEFAULT verbose 'True'
iniset /etc/cinder/cinder.conf DEFAULT auth_strategy 'keystone'
iniset /etc/cinder/cinder.conf DEFAULT my_ip $3
iniset /etc/cinder/cinder.conf DEFAULT enabled_backends 'lvm'
iniset /etc/cinder/cinder.conf DEFAULT glance_host 'glance'
inidelete /etc/cinder/cinder.conf DEFAULT volume_group


iniset /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host rabbitmq
iniset /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
iniset /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $1

iniset /etc/cinder/cinder.conf keystone_authtoken auth_uri 'http://keystone:5000'
iniset /etc/cinder/cinder.conf keystone_authtoken auth_url 'http://keystone:35357'
iniset /etc/cinder/cinder.conf keystone_authtoken auth_plugin 'password'
iniset /etc/cinder/cinder.conf keystone_authtoken project_domain_id 'default'
iniset /etc/cinder/cinder.conf keystone_authtoken user_domain_id 'default'
iniset /etc/cinder/cinder.conf keystone_authtoken project_name 'service'
iniset /etc/cinder/cinder.conf keystone_authtoken username 'cinder'
iniset /etc/cinder/cinder.conf keystone_authtoken password $1


iniset /etc/cinder/cinder.conf lvm volume_driver 'cinder.volume.drivers.lvm.LVMVolumeDriver'
iniset /etc/cinder/cinder.conf lvm volume_group "$vgname"
iniset /etc/cinder/cinder.conf lvm iscsi_protocol 'iscsi'
iniset /etc/cinder/cinder.conf lvm iscsi_helper 'tgtadm'

iniset /etc/cinder/cinder.conf 'oslo_concurrency' 'lock_path' '/var/lib/cinder/tmp'


service tgt restart
service cinder-volume restart

rm -f /var/lib/cinder/cinder.sqlite

echo 'Cinder storage install is now complete!'
