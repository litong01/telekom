#!/usr/bin/env bash
# $1 sys_password
# $2 management network ip

source /onvm/scripts/ini-config

apt-get -qqy install openstack-dashboard

sed -i -e 's/^OPENSTACK_HOST = \"127.0.0.1\"/OPENSTACK_HOST = \"keystone\"/g' /etc/openstack-dashboard/local_settings.py
sed -i -e 's/^OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"/g' /etc/openstack-dashboard/local_settings.py
sed -i -e 's/^TIME_ZONE = "UTC"/TIME_ZONE = "EST"/g' /etc/openstack-dashboard/local_settings.py

sed -i -e "s/^ALLOWED_HOSTS = '\*'/ALLOWED_HOSTS = ['*', ]/" /etc/openstack-dashboard/local_settings.py

# Do this to make the browser go to the horizon app
cp /onvm/conf/index.html /var/www/html

service apache2 reload

echo 'Horizon installation is now complete'