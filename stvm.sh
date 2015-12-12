vboxmanage controlvm UbuntuLVM acpipowerbutton
vboxmanage controlvm vagrantcontrol acpipowerbutton

# This command will show installed kernels except the currently running one sudo
# dpkg --list 'linux-image*'|awk '{ if ($1=="ii") print $2}'|grep -v `uname -r`