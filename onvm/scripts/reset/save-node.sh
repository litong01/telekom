#!/usr/bin/env bash

# clean up the /boot directory

apt-get remove -y `dpkg --list 'linux-image*' |grep ^ii | awk '{print $2}'\ | grep -v \`uname -r\``
apt-get -y autoremove

vgname=$(vgdisplay | awk 'NR==2 { print $3 }')
echo $vgname

sp=$(lvdisplay | grep space)
if [ ! "$sp" ];then
   echo 'Ready to create space logical volume!'
   lvcreate -L 5G -n space $vgname
   mkfs -t ext4 /dev/$vgname/space
   mkdir /space
   mount /dev/$vgname/space /space
   mkdir -p /space/backup
   mkdir -p /space/snap
fi

rm -r -f /space/backup/*
rm -r -f /space/snap/*

sp=$(lvdisplay | grep resetpoint)
if [ "$sp" ];then
   echo 'Ready to remove existing resetpoint!'
   lvremove -f "/dev/${vgname}/resetpoint"
fi

lvcreate --size 5G -s -n resetpoint /dev/$vgname/root
mount /dev/$vgname/resetpoint /space/snap
cd /space/snap
tar -pczf /space/backup/cleansystem.tar.gz *
cd ~
umount /space/snap
lvremove -f "/dev/${vgname}/resetpoint"

cd /boot
tar -pzcf /space/backup/boot.tar.gz *

echo "System has been saved!"