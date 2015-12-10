vboxmanage controlvm vagrantcompute acpipowerbutton
vboxmanage controlvm vagrantcontrol acpipowerbutton

VBoxManage snapshot vagrantcompute restore "Snapshot 1"
VBoxManage snapshot vagrantcontrol restore "Snapshot 1"

vboxmanage startvm vagrantcompute --type headless
vboxmanage startvm vagrantcontrol --type headless
