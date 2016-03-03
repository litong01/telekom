
if [ "$VAGRANT_VAGRANTFILE" == 'Vagrantfile' ];then
    export VAGRANT_VAGRANTFILE=ResetNodes
else
    export VAGRANT_VAGRANTFILE=Vagrantfile
fi
export VAGRANT_DEFAULT_PROVIDER=managed
echo 'Env is now '$VAGRANT_VAGRANTFILE

#apt-get install --reinstall linux-image-3.13.0-63-gene
#apt-get install --reinstall linux-image-3.13.0-65-gene
#
# List all the menuentry in the grub cfg
# awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg

# grub-reboot
# grub-set-default

# This command will show installed kernels except the currently running one sudo
# dpkg --list 'linux-image*'|awk '{ if ($1=="ii") print $2}'|grep -v `uname -r`