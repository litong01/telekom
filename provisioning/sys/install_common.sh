#!/usr/bin/env bash
apt-get -qqy update
apt-get -qqy install software-properties-common
add-apt-repository cloud-archive:liberty
apt-get -qqy update && apt-get dist-upgrade
apt-get -qqy install python-openstackclient
apt-get -qqy install chrony
reboot