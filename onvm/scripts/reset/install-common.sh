#!/usr/bin/env bash
# $1 server hostname
# $2 chrony server hostname

apt-get -qqy update
apt-get -qqy install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -qqy update
apt-get -qqy install python-openstackclient
apt-get -qqy install chrony

sed -i '/^server /d' /etc/chrony/chrony.conf

if [ "$1" = "$2" ]; then
  echo 'server 1.us.pool.ntp.org iburst' >> /etc/chrony/chrony.conf
else
  echo "server $2 iburst" >> /etc/chrony/chrony.conf
fi

service chrony restart