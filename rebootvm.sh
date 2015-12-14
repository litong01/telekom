VBoxManage snapshot LVMBoot restore "Snapshot 1"
VBoxManage snapshot vagrantcontrol restore "Snapshot 1"

vboxmanage startvm LVMBoot --type headless
vboxmanage startvm vagrantcontrol --type headless
