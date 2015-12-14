#!/usr/bin/env bash
# $1 sys_password
# $2 public net id
# $3 public net start_ip
# $4 public net end_ip
# $5 public net gateway

source /onvm/scripts/ini-config

echo "Setting up public and private network..."

source ~/admin-openrc.sh

neutron net-create public --shared --provider:physical_network public \
  --provider:network_type flat

neutron subnet-create public $2 --name public --allocation-pool \
  start=$3,end=$4 --dns-nameserver 8.8.4.4 --gateway $5

source ~/demo-openrc.sh
neutron net-create private


neutron subnet-create private 10.0.10.0/24 --name private \
  --dns-nameserver 8.8.4.4 --gateway 10.0.10.1

source ~/admin-openrc.sh

neutron net-update public --router:external

source ~/demo-openrc.sh

neutron router-create router

neutron router-interface-add router private

neutron router-gateway-set router public

echo "Ini-node-01 is now complete!"
