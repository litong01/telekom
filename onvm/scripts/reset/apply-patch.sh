#!/usr/bin/env bash

mv /etc/grub.d/00_header /etc/grub.d/00_header.orig
mv /onvm/conf/00_header_patched /etc/grub.d/00_header
# Disable the old script and enable the new one
chmod -x /etc/grub.d/00_header.orig
chmod +x /etc/grub.d/00_header
# Update Grub
update-grub
