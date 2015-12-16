#!/usr/bin/env bash
# $1 rabbitmq_password
# $2 public ip eth0
# $3 private ip eth1

apt-get -qqy install rabbitmq-server

rabbitmqctl add_user openstack $1

rabbitmqctl set_permissions openstack ".*" ".*" ".*"


