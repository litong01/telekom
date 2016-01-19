#!/usr/bin/env bash
# $1 sys_password
# $2 public ip eth0
# $3 private ip eth1

echo "Setup public ovs bridge..."
ifconfig eth0 0.0.0.0; ifconfig br-ex $2; ovs-vsctl add-port br-ex eth0;
