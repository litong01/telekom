#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1

source /onvm/scripts/ini-config

apt-get install -qqy nova-compute sysfsutils

echo "Compute packages are installed!"

iniset /etc/nova/nova.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/nova/nova.conf DEFAULT verbose 'True'
iniset /etc/nova/nova.conf DEFAULT auth_strategy 'keystone'
iniset /etc/nova/nova.conf DEFAULT my_ip "$3"
iniset /etc/nova/nova.conf DEFAULT enabled_apis 'osapi_compute,metadata'

iniset /etc/nova/nova.conf DEFAULT network_api_class 'nova.network.neutronv2.api.API'
iniset /etc/nova/nova.conf DEFAULT security_group_api 'neutron'
iniset /etc/nova/nova.conf DEFAULT linuxnet_interface_driver 'nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver'
iniset /etc/nova/nova.conf DEFAULT firewall_driver 'nova.virt.firewall.NoopFirewallDriver'

iniset /etc/nova/nova.conf vnc vncserver_listen '0.0.0.0'
iniset /etc/nova/nova.conf vnc vncserver_proxyclient_address '$my_ip'
iniset /etc/nova/nova.conf vnc enabled 'True'
iniset /etc/nova/nova.conf vnc novncproxy_base_url 'http://nova:6080/vnc_auto.html'

iniset /etc/nova/nova.conf glance host 'glance'

iniset /etc/nova/nova.conf oslo_concurrency lock_path '/var/lib/nova/tmp'

iniset /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host rabbitmq
iniset /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
iniset /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $1


iniset /etc/nova/nova.conf keystone_authtoken auth_uri 'http://keystone:5000'
iniset /etc/nova/nova.conf keystone_authtoken auth_url 'http://keystone:35357'
iniset /etc/nova/nova.conf keystone_authtoken auth_plugin 'password'
iniset /etc/nova/nova.conf keystone_authtoken project_domain_id 'default'
iniset /etc/nova/nova.conf keystone_authtoken user_domain_id 'default'
iniset /etc/nova/nova.conf keystone_authtoken project_name 'service'
iniset /etc/nova/nova.conf keystone_authtoken username 'nova'
iniset /etc/nova/nova.conf keystone_authtoken password $1

# This is only for development
iniset /etc/nova/nova.conf libvirt virt_type 'qemu'

service nova-compute start

rm -f /var/lib/nova/nova.sqlite

echo "Compute setup is now complete!"

