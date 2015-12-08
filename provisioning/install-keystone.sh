#!/usr/bin/env bash

apt-get install -qqy keystone apache2 libapache2-mod-wsgi memcached python-memcache

echo "manual" > /etc/init/keystone.override
