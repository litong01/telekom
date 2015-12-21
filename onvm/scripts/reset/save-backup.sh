#!/usr/bin/env bash
# $1 hostname
# $2 userid
# $3 password
# $4 backuphost
# $5 timestamp

apt-get -qqy install sshpass

dir=`mktemp -d` && cd $dir
mkdir source

sp=$(lvdisplay | grep /dev/vg01/space)
if [ ! "$sp" ];then
   echo 'No backups'
   exit 0
fi

mount /dev/vg01/space source

sshpass -p $3 ssh -o 'StrictHostKeyChecking no' $2@$4 "mkdir -p /storage/backup/$5"
sshpass -p $3 scp -o 'StrictHostKeyChecking no' source/cleansystem.tar.gz $2@$4:/storage/backup/$5/$1-cleansystem.tar.gz

umount source

echo "$1 backup image has been saved!"