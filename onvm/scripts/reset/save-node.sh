#!/usr/bin/env bash
# $1 hostname
# $2 public ip eth0
# $3 public ip eth1

sp=$(lvdisplay | grep '/dev/vg00/resetpoint')
if [ "$sp" ];then
   echo 'Ready to remove existing resetpoint!'
   lvremove -f "/dev/vg00/resetpoint"
fi

echo "Create a resetpoint"
lvcreate --size 6G -s -n resetpoint /dev/vg00/vg00-lv01

dir=`mktemp -d` && cd $dir
mkdir source target

sp=$(lvdisplay | grep /dev/vg01/space)
if [ ! "$sp" ];then
   echo 'Ready to create space logical volume!'
   lvcreate -l 100%FREE -n space vg01
   mkfs -t ext4 /dev/vg01/space
   mount /dev/vg01/space target
fi

mount /dev/vg00/resetpoint source

cd source
tar -pczf ../target/cleansystem.tar.gz *
cd $dir

umount source
umount target

lvremove -f "/dev/vg00/resetpoint"

echo "System has been saved!"