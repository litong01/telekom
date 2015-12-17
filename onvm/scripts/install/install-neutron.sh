#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1

source /onvm/scripts/ini-config
eval $(parse_yaml '/onvm/conf/nodes.conf.yml' 'leap_')

apt-get install -qqy neutron-server neutron-plugin-ml2 \
  neutron-plugin-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent \
  neutron-metadata-agent python-neutronclient


echo "Neutron packages are installed!"

# Configre /etc/neutron/neutron.conf
echo "Configure the server component"

iniset /etc/neutron/neutron.conf database connection "mysql+pymysql://neutron:$1@${leap_logical2physical_mysqldb}/neutron"
iniset /etc/neutron/neutron.conf DEFAULT core_plugin 'ml2'
iniset /etc/neutron/neutron.conf DEFAULT service_plugins 'router'
iniset /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips 'True'
iniset /etc/neutron/neutron.conf DEFAULT rpc_backend 'rabbit'
iniset /etc/neutron/neutron.conf DEFAULT debug 'True'
iniset /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host "${leap_logical2physical_rabbitmq}"
iniset /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid 'openstack'
iniset /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $1
iniset /etc/neutron/neutron.conf DEFAULT auth_strategy 'keystone'

iniset /etc/neutron/neutron.conf keystone_authtoken auth_uri "http://${leap_logical2physical_keystone}:5000"
iniset /etc/neutron/neutron.conf keystone_authtoken auth_url "http://${leap_logical2physical_keystone}:35357"
iniset /etc/neutron/neutron.conf keystone_authtoken auth_plugin 'password'
iniset /etc/neutron/neutron.conf keystone_authtoken project_domain_id 'default'
iniset /etc/neutron/neutron.conf keystone_authtoken user_domain_id 'default'
iniset /etc/neutron/neutron.conf keystone_authtoken project_name 'service'
iniset /etc/neutron/neutron.conf keystone_authtoken username 'neutron'
iniset /etc/neutron/neutron.conf keystone_authtoken password $1

inidelete /etc/neutron/neutron.conf keystone_authtoken identity_uri
inidelete /etc/neutron/neutron.conf keystone_authtoken admin_tenant_name
inidelete /etc/neutron/neutron.conf keystone_authtoken admin_user
inidelete /etc/neutron/neutron.conf keystone_authtoken admin_password

iniset /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes 'True'
iniset /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes 'True'
iniset /etc/neutron/neutron.conf DEFAULT nova_url "http://${leap_logical2physical_nova}:8774/v2"

iniset /etc/neutron/neutron.conf nova auth_url "http://${leap_logical2physical_keystone}:35357"
iniset /etc/neutron/neutron.conf nova auth_plugin 'password'
iniset /etc/neutron/neutron.conf nova project_domain_id 'default'
iniset /etc/neutron/neutron.conf nova user_domain_id 'default'
iniset /etc/neutron/neutron.conf nova region_name 'RegionOne'
iniset /etc/neutron/neutron.conf nova project_name 'service'
iniset /etc/neutron/neutron.conf nova username 'nova'
iniset /etc/neutron/neutron.conf nova password $1

# Configure /etc/neutron/plugins/ml2/ml2_conf.ini
echo "Configure Modular Layer 2 (ML2) plug-in"

iniset /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers 'flat,vlan,vxlan'
iniset /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types 'vxlan'
iniset /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers 'linuxbridge,l2population'
iniset /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers 'port_security'

iniset /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks 'public'
iniset /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges '1:1000'
iniset /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset 'True'

# Configure /etc/neutron/plugins/ml2/linuxbridge_agent.ini
echo "COnfigure linuxbridge agent"

iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings 'public:eth0'
iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan 'True'
iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip $3
iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population 'True'
iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini agent prevent_arp_spoofing 'True'
iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group 'True'
iniset /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver'

# Configure /etc/neutron/l3_agent.ini 
echo "Configure the layer-3 agent"

iniset /etc/neutron/l3_agent.ini DEFAULT interface_driver  'neutron.agent.linux.interface.BridgeInterfaceDriver'
iniset /etc/neutron/l3_agent.ini DEFAULT external_network_bridge ''
iniset /etc/neutron/l3_agent.ini DEFAULT debug 'True'


# Configure /etc/neutron/dhcp_agent.ini
echo "Configure the DHCP agent"

iniset /etc/neutron/dhcp_agent.ini DEFAULT interface_driver 'neutron.agent.linux.interface.BridgeInterfaceDriver'
iniset /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver 'neutron.agent.linux.dhcp.Dnsmasq'
iniset /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata 'True'
iniset /etc/neutron/dhcp_agent.ini DEFAULT dnsmasq_config_file '/etc/neutron/dnsmasq-neutron.conf'
echo 'dhcp-option-force=26,1450' > /etc/neutron/dnsmasq-neutron.conf

#Configure /etc/neutron/metadata_agent.ini
echo "Configure the metadata agent"

iniset /etc/neutron/metadata_agent.ini DEFAULT auth_uri "http://${leap_logical2physical_keystone}:5000"
iniset /etc/neutron/metadata_agent.ini DEFAULT auth_url "http://${leap_logical2physical_keystone}:35357"
iniset /etc/neutron/metadata_agent.ini DEFAULT auth_region 'RegionOne'
iniset /etc/neutron/metadata_agent.ini DEFAULT auth_plugin 'password'
iniset /etc/neutron/metadata_agent.ini DEFAULT project_domain_id 'default'
iniset /etc/neutron/metadata_agent.ini DEFAULT user_domain_id 'default'
iniset /etc/neutron/metadata_agent.ini DEFAULT project_name 'service'
iniset /etc/neutron/metadata_agent.ini DEFAULT username 'neutron'
iniset /etc/neutron/metadata_agent.ini DEFAULT password $1
iniset /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip "${leap_logical2physical_neutron}"
iniset /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret $1
iniset /etc/neutron/metadata_agent.ini DEFAULT debug 'True'

inidelete /etc/neutron/metadata_agent.ini DEFAULT admin_tenant_name
inidelete /etc/neutron/metadata_agent.ini DEFAULT admin_user
inidelete /etc/neutron/metadata_agent.ini DEFAULT admin_password

# clean up configuration files

iniremcomment /etc/neutron/neutron.conf
iniremcomment /etc/neutron/plugins/ml2/ml2_conf.ini
iniremcomment /etc/neutron/plugins/ml2/linuxbridge_agent.ini
iniremcomment /etc/neutron/l3_agent.ini
iniremcomment /etc/neutron/dhcp_agent.ini
iniremcomment /etc/neutron/metadata_agent.ini

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

service neutron-server restart
service neutron-plugin-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-l3-agent restart

rm -f /var/lib/neutron/neutron.sqlite

mkdir -p /storage
sp=$(lvdisplay | grep /dev/vg02/storage)
if [ ! "$sp" ];then
  echo 'Ready to create neutron storage'
  lvcreate -l 100%FREE -n storage vg02
  mkfs -t ext4 /dev/vg02/storage
  mount /dev/vg02/storage /storage/
fi

echo "Neutron setup is now complete!"

