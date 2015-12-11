#!/usr/bin/env bash
vgname=$(vgdisplay | awk 'NR==2 { print $3 }')
echo $vgname
rm -r -f /space/snap/*
lvcreate --size 20G -s -n resetpoint /dev/$vgname/root
mount /dev/$vgname/resetpoint /space/snap
cd /space/snap
rm -r -f *
tar -xf /space/backup/cleansystem.tar.gz
cd ~

echo "Setting up eth1..."
echo -e "\nauto eth1" >> /space/snap/etc/network/interfaces
echo -e "iface eth1 inet static" >> /space/snap/etc/network/interfaces
echo -e "  address $1" >> /space/snap/etc/network/interfaces
echo -e "  netmask 255.255.255.0" >> /space/snap/etc/network/interfaces

echo -e "" >> /space/snap/etc/hosts
echo -e "192.168.1.132 mysqldb" >> /space/snap/etc/hosts
echo -e "192.168.1.133 keystone horizon rabbitmq" >> /space/snap/etc/hosts
echo -e "192.168.1.134 glance cinder" >> /space/snap/etc/hosts
echo -e "192.168.1.135 neutron" >> /space/snap/etc/hosts
echo -e "192.168.1.136 nova heat" >> /space/snap/etc/hosts
echo -e "192.168.1.137 compute01" >> /space/snap/etc/hosts
echo -e "192.168.1.138 compute02" >> /space/snap/etc/hosts
echo -e "192.168.1.139 compute03" >> /space/snap/etc/hosts
echo -e "192.168.1.140 compute04" >> /space/snap/etc/hosts
echo -e "192.168.1.141 compute05" >> /space/snap/etc/hosts

umount /space/snap
lvconvert --merge /dev/$vgname/resetpoint
reboot
