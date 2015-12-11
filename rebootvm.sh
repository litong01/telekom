VBoxManage snapshot UbuntuLVM restore "Snapshot 1"
VBoxManage snapshot vagrantcontrol restore "Snapshot 1"

vboxmanage startvm UbuntuLVM --type headless
vboxmanage startvm vagrantcontrol --type headless
