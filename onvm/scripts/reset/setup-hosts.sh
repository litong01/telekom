#!/usr/bin/env bash
# $1 hostname
# $2 public ip eth0
# $3 public ip eth1
# $4 chrony server hostname

echo "Setting up eth1..."

sp=$(grep $1 /etc/hosts)
if [ ! "$sp" ];then
  echo -e "\nauto eth1" >> /etc/network/interfaces
  echo -e "iface eth1 inet static" >> /etc/network/interfaces
  echo -e "  address $3" >> /etc/network/interfaces
  echo -e "  netmask 255.255.255.0" >> /etc/network/interfaces

  sed -i '/^127.0.1.1/d' /etc/hosts
  cat /onvm/conf/hosts >> /etc/hosts

  echo 'Setting up hostname'
  echo -e "$1" > /etc/hostname

  sed -i '/^server /d' /etc/chrony/chrony.conf

  if [ "$1" = "$4" ]; then
    echo 'server 1.us.pool.ntp.org iburst' >> /etc/chrony/chrony.conf
  else
    echo "server $4 iburst" >> /etc/chrony/chrony.conf
  fi

service chrony restart
fi

