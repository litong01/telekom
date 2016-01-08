#!/usr/bin/env bash

apt-get -qqy update
apt-get -qqy install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -qqy update
apt-get -qqy install python-openstackclient
apt-get -qqy install chrony
