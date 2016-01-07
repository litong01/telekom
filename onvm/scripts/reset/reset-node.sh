#!/usr/bin/env bash
# $1 hostname
# $2 public ip eth0
# $3 public ip eth1

dir=`mktemp -d` && cd $dir
mkdir source target

mount /dev/vg01/space source

sp=$(lvdisplay | grep /dev/vg00/resetpoint)
if [ "$sp" ];then
   echo 'Ready to remove older resetpoint'
   lvremove -f "/dev/vg00/resetpoint"
fi

lvcreate --size 6G -s -n resetpoint /dev/vg00/vg00-lv01

mount /dev/vg00/resetpoint target

rm -r -f target/*
cd target
tar -xf ../source/cleansystem.tar.gz
cd $dir

echo "Setting up eth1..."

sp=$(grep $1 /etc/hosts)
if [ ! "$sp" ];then
  echo -e "\nauto eth1" >> target/etc/network/interfaces
  echo -e "iface eth1 inet static" >> target/etc/network/interfaces
  echo -e "  address $3" >> target/etc/network/interfaces
  echo -e "  netmask 255.255.255.0" >> target/etc/network/interfaces

  sed -i '/^127.0.1.1/d' target/etc/hosts
  cat /onvm/conf/hosts >> target/etc/hosts

  echo 'Setting up hostname'
  echo -e "$1" > target/etc/hostname
fi

umount source/
umount target/

lvconvert --merge /dev/vg00/resetpoint

shutdown -r +1 &

