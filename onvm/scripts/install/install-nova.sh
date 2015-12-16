#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1

source /onvm/scripts/ini-config
eval $(parse_yaml '/onvm/conf/nodes.conf.yml' 'leap_')

apt-get install -qqy nova-api nova-cert nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler python-novaclient

echo "Nova packages are installed!"

iniset /etc/nova/nova.conf database connection mysql+pymysql://nova:$1@$leap_logical2physical_mysqldb/nova
iniset /etc/nova/nova.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/nova/nova.conf DEFAULT debug 'True'
iniset /etc/nova/nova.conf DEFAULT auth_strategy 'keystone'
iniset /etc/nova/nova.conf DEFAULT my_ip "$3"
iniset /etc/nova/nova.conf DEFAULT enabled_apis 'osapi_compute,metadata'

iniset /etc/nova/nova.conf DEFAULT network_api_class 'nova.network.neutronv2.api.API'
iniset /etc/nova/nova.conf DEFAULT security_group_api 'neutron'
iniset /etc/nova/nova.conf DEFAULT linuxnet_interface_driver 'nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver'
iniset /etc/nova/nova.conf DEFAULT firewall_driver 'nova.virt.firewall.NoopFirewallDriver'

iniset /etc/nova/nova.conf vnc vncserver_listen '$my_ip'
iniset /etc/nova/nova.conf vnc vncserver_proxyclient_address '$my_ip'

iniset /etc/nova/nova.conf glance host $leap_logical2physical_glance

iniset /etc/nova/nova.conf oslo_concurrency lock_path '/var/lib/nova/tmp'

iniset /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host "${leap_logical2physical_rabbitmq}"
iniset /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
iniset /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $1


iniset /etc/nova/nova.conf keystone_authtoken auth_uri http://$leap_logical2physical_keystone:5000
iniset /etc/nova/nova.conf keystone_authtoken auth_url http://$leap_logical2physical_keystone:35357
iniset /etc/nova/nova.conf keystone_authtoken auth_plugin 'password'
iniset /etc/nova/nova.conf keystone_authtoken project_domain_id 'default'
iniset /etc/nova/nova.conf keystone_authtoken user_domain_id 'default'
iniset /etc/nova/nova.conf keystone_authtoken project_name 'service'
iniset /etc/nova/nova.conf keystone_authtoken username 'nova'
iniset /etc/nova/nova.conf keystone_authtoken password $1

iniremcomment /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

rm -f /var/lib/nova/nova.sqlite

echo "Nova setup is now complete!"

