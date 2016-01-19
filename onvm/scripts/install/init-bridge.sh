#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1


source /onvm/scripts/ini-config
eval $(parse_yaml '/onvm/conf/nodes.conf.yml' 'leap_')

echo "Setup public ovs bridge..."
ovs-vsctl add-port br-ex $leap_pubnic
ifconfig $leap_pubnic 0.0.0.0;ifconfig br-ex $2
