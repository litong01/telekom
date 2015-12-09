#!/usr/bin/env bash
# $1 rabbitmq_password

apt-get -qqy install rabbitmq-server

rabbitmqctl add_user openstack $1

rabbitmqctl set_permissions openstack ".*" ".*" ".*"


